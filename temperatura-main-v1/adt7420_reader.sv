module adt7420_reader (
    input  logic        clk,        // 400 kHz 
    input  logic        rst,
    inout  tri          sda,
    output tri          scl,
    output logic [11:0] temp_raw,   // cada LSB = 0,0625 °C
    output logic        valid
);

    typedef enum logic [3:0] {
        S_WAIT   = 4'd0,
        S_START  = 4'd1,
        S_ADDRW  = 4'd2,
        S_ACK1   = 4'd3,
        S_PTR    = 4'd4,
        S_ACK2   = 4'd5,
        S_RSTART = 4'd6,
        S_ADDRR  = 4'd7,
        S_ACK3   = 4'd8,
        S_MSB    = 4'd9,
        S_MACK   = 4'd10,
        S_LSB    = 4'd11,
        S_NACK   = 4'd12,
        S_STOP   = 4'd13
    } state_t;

    localparam logic [18:0] WAIT_MAX = 19'd399999;   // ~1 s a 400 kHz

    state_t       state;
    logic [1:0]   ph;                // fase do bit (0..3)
    logic [2:0]   bc;                // contador de bits
    logic [7:0]   sh;                // shift register
    logic [7:0]   msb;
    logic [18:0]  wcnt;
    logic         scl_r, sda_r;      // 1 = solto (alto), 0 = puxa para baixo

    // open-drain
    assign scl = scl_r ? 1'bz : 1'b0;
    assign sda = sda_r ? 1'bz : 1'b0;

    always_ff @(posedge clk) begin
        valid <= 1'b0;

        if (rst) begin
            state <= S_WAIT;
            wcnt  <= '0;
            ph    <= '0;
            bc    <= '0;
            sh    <= '0;
            msb   <= '0;
            scl_r <= 1'b1;
            sda_r <= 1'b1;
        end else begin
            case (state)

            // espera ~1 s com o barramento livre
            S_WAIT: begin
                scl_r <= 1'b1;
                sda_r <= 1'b1;
                ph    <= '0;
                bc    <= '0;
                if (wcnt == WAIT_MAX) begin
                    wcnt  <= '0;
                    state <= S_START;
                end else begin
                    wcnt <= wcnt + 1'b1;
                end
            end

            // START: SDA cai com SCL alto
            S_START: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b1; sda_r <= 1'b1; end
                    2'd1: sda_r <= 1'b0;
                    2'd3: begin
                        scl_r <= 1'b0;
                        sh    <= 8'h90;          // 0x48 << 1 | W
                        state <= S_ADDRW;
                    end
                    default: ;
                endcase
            end

            // enviar byte (endereço+W, ponteiro, endereço+R)
            S_ADDRW, S_PTR, S_ADDRR: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= sh[7]; end
                    2'd1: scl_r <= 1'b1;
                    2'd3: begin
                        scl_r <= 1'b0;
                        sh    <= {sh[6:0], 1'b0};
                        bc    <= bc + 1'b1;
                        if (bc == 3'd7) state <= state_t'(state + 1'b1);
                    end
                    default: ;
                endcase
            end

            // ACK do sensor (mestre solta SDA)
            S_ACK1, S_ACK2, S_ACK3: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= 1'b1; end
                    2'd1: scl_r <= 1'b1;
                    2'd3: begin
                        scl_r <= 1'b0;
                        state <= state_t'(state + 1'b1);
                        if (state == S_ACK1) sh <= 8'h00;   // ponteiro = 0x00
                    end
                    default: ;
                endcase
            end

            // REPEATED START
            S_RSTART: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= 1'b1; end
                    2'd1: scl_r <= 1'b1;
                    2'd2: sda_r <= 1'b0;
                    2'd3: begin
                        scl_r <= 1'b0;
                        sh    <= 8'h91;          // 0x48 << 1 | R
                        state <= S_ADDRR;
                    end
                    default: ;
                endcase
            end

            // ler byte do sensor
            S_MSB, S_LSB: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= 1'b1; end
                    2'd1: scl_r <= 1'b1;
                    2'd2: sh <= {sh[6:0], sda};          // amostra
                    2'd3: begin
                        scl_r <= 1'b0;
                        bc    <= bc + 1'b1;
                        if (bc == 3'd7) begin
                            if (state == S_MSB) begin
                                msb <= sh;
                            end else begin
                                temp_raw <= {msb[6:0], sh[7:3]};   // bits [14:3]
                                valid    <= 1'b1;
                            end
                            state <= state_t'(state + 1'b1);
                        end
                    end
                    default: ;
                endcase
            end

            // mestre responde ACK (após MSB) ou NACK (após LSB)
            S_MACK, S_NACK: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= (state == S_NACK); end
                    2'd1: scl_r <= 1'b1;
                    2'd3: begin
                        scl_r <= 1'b0;
                        state <= state_t'(state + 1'b1);
                    end
                    default: ;
                endcase
            end

            // STOP: SDA sobe com SCL alto
            S_STOP: begin
                ph <= ph + 1'b1;
                case (ph)
                    2'd0: begin scl_r <= 1'b0; sda_r <= 1'b0; end
                    2'd1: scl_r <= 1'b1;
                    2'd2: sda_r <= 1'b1;
                    2'd3: state <= S_WAIT;
                    default: ;
                endcase
            end

            default: state <= S_WAIT;
            endcase
        end
    end

endmodule