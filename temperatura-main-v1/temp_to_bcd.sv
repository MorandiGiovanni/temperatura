module temp_to_bcd (
    input  logic [11:0]      temp_raw,   // cada LSB = 0,0625 °C
    output logic [7:0][3:0]  digits      // digits[0] = display mais à direita
);

    localparam logic [3:0] BLANK = 4'hF;   // código de "apagado"

    logic [7:0]  int_part;
    logic [3:0]  frac_part;
    logic [3:0]  hund, tens, unit;
    logic [15:0] frac_bcd;                 // 4 dígitos BCD da fração

    assign int_part  = temp_raw[11:4];
    assign frac_part = temp_raw[3:0];

    // parte inteira -> BCD (divisões por constante, 8 bits: sintetiza sem problema)
    assign hund = int_part / 100;
    assign tens = (int_part % 100) / 10;
    assign unit = int_part % 10;

    // parte fracionária: frac/16 com 4 casas, tabela exata
    always_comb begin
        case (frac_part)
            4'd0:    frac_bcd = 16'h0000;
            4'd1:    frac_bcd = 16'h0625;
            4'd2:    frac_bcd = 16'h1250;
            4'd3:    frac_bcd = 16'h1875;
            4'd4:    frac_bcd = 16'h2500;
            4'd5:    frac_bcd = 16'h3125;
            4'd6:    frac_bcd = 16'h3750;
            4'd7:    frac_bcd = 16'h4375;
            4'd8:    frac_bcd = 16'h5000;
            4'd9:    frac_bcd = 16'h5625;
            4'd10:   frac_bcd = 16'h6250;
            4'd11:   frac_bcd = 16'h6875;
            4'd12:   frac_bcd = 16'h7500;
            4'd13:   frac_bcd = 16'h8125;
            4'd14:   frac_bcd = 16'h8750;
            4'd15:   frac_bcd = 16'h9375;
            default: frac_bcd = 16'h0000;
        endcase
    end

    always_comb begin
        // 4 displays da direita: fração (sempre mostra os 4 dígitos)
        digits[0] = frac_bcd[3:0];
        digits[1] = frac_bcd[7:4];
        digits[2] = frac_bcd[11:8];
        digits[3] = frac_bcd[15:12];

        // 4 displays da esquerda: parte inteira, sem zeros à esquerda
        digits[4] = unit;                                   // unidade sempre aparece
        digits[5] = (int_part >= 8'd10)  ? tens : BLANK;
        digits[6] = (int_part >= 8'd100) ? hund : BLANK;
        digits[7] = BLANK;                                  // máx. 255, nunca usado
    end

endmodule