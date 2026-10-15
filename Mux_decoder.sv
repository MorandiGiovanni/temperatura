module mux_decoder (
    input  logic [2:0] contador,

    input  logic [7:0] AN_pos0,
    input  logic [7:0] AN_pos1,
    input  logic [7:0] AN_pos2,
    input  logic [7:0] AN_pos3,
    input  logic [7:0] AN_pos4,
    input  logic [7:0] AN_pos5,
    input  logic [7:0] AN_pos6,
    input  logic [7:0] AN_pos7,

    output logic [7:0] display // Saída dos segmentos
);

    logic [7:0] valor;

    // Seleciona o scancode da posição atual
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
            default: valor = 8'h00;
        endcase
    end

    // Decodifica para Display de 7 segmentos 
    always_comb begin
        case (valor)
            //NÚMEROS
            8'h45: display = 8'b1000_0001; // '0'
            8'h16: display = 8'b1100_1111; // '1'
            8'h1E: display = 8'b1001_0010; // '2'
            8'h26: display = 8'b10000110; // '3'
            8'h25: display = 8'b11001100; // '4'
            8'h2E: display = 8'b10100100; // '5'
            8'h36: display = 8'b10100000; // '6'
            8'h3D: display = 8'b10001111; // '7'
            8'h3E: display = 8'b10000000; // '8'
            8'h46: display = 8'b10000100; // '9'

            //LETRAS
            8'h1C: display = 8'b1000_1000; // 'A'
            8'h32: display = 8'b11100000; // 'b'
            8'h21: display = 8'b10110001; // 'C'
            8'h23: display = 8'b11000010; // 'd'
            8'h24: display = 8'b10110000; // 'E'
            8'h2B: display = 8'b10111000; // 'F'
            8'h34: display = 8'b10000100; // 'G'
            8'h33: display = 8'b11001000; // 'h'
            8'h43: display = 8'b11001111; // 'I'
            8'h3B: display = 8'b11000111; // 'J'
            8'h42: display = 8'b10110000; // 'K'
            8'h4B: display = 8'b11110001; // 'L'
            8'h3A: display = 8'b11101010; // 'M'
            8'h31: display = 8'b11101010; // 'n'
            8'h44: display = 8'b10000001; // 'O'
            8'h4D: display = 8'b10011000; // 'P'
            8'h15: display = 8'b10000001; // 'Q'
            8'h2D: display = 8'b10111001; // 'r'
            8'h1B: display = 8'b10100100; // 'S'
            8'h2C: display = 8'b10111001; // 't'
            8'h3C: display = 8'b11000001; // 'U'
            8'h2A: display = 8'b11000001; // 'v'
            8'h1D: display = 8'b1100_0001; // 'W'
            8'h22: display = 8'b1000_1001; // 'X'
            8'h35: display = 8'b11001100; // 'Y'
            8'h1A: display = 8'b1010_0100; // 'Z'

            default: display = 8'b1111_1111; // Apagado, reset
        endcase
    end

endmodule