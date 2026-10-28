module mux_decoder (
    input  logic [2:0] contador,

    input  logic [3:0] AN_pos0,
    input  logic [3:0] AN_pos1,
    input  logic [3:0] AN_pos2,
    input  logic [3:0] AN_pos3,
    input  logic [3:0] AN_pos4,
    input  logic [3:0] AN_pos5,
    input  logic [3:0] AN_pos6,
    input  logic [3:0] AN_pos7,

    output logic [7:0] display   // {DP, a,b,c,d,e,f,g}, ativo em baixo
);

    logic [3:0] valor;

    // Seleciona o dígito da posição atual
    always_comb begin
        case (contador)
            3'b000: valor = AN_pos0;
            3'b001: valor = AN_pos1;
            3'b010: valor = AN_pos2;
            3'b011: valor = AN_pos3;
            3'b100: valor = AN_pos4;
            3'b101: valor = AN_pos5;
            3'b110: valor = AN_pos6;
            3'b111: valor = AN_pos7;
            default: valor = 4'hF;
        endcase
    end

    // Decodifica BCD direto para a saída (DP começa apagado = 1)
    always_comb begin
        case (valor)
            4'd0:    display = 8'b1000_0001; // '0'
            4'd1:    display = 8'b1100_1111; // '1'
            4'd2:    display = 8'b1001_0010; // '2'
            4'd3:    display = 8'b1000_0110; // '3'
            4'd4:    display = 8'b1100_1100; // '4'
            4'd5:    display = 8'b1010_0100; // '5'
            4'd6:    display = 8'b1010_0000; // '6'
            4'd7:    display = 8'b1000_1111; // '7'
            4'd8:    display = 8'b1000_0000; // '8'
            4'd9:    display = 8'b1000_0100; // '9'
            default: display = 8'b1111_1111; // apagado (4'hF)
        endcase

        // Ponto decimal fixo na posição 4 (unidade), ativo em baixo
        if (contador == 3'd4)
            display[7] = 1'b0;
    end

endmodule