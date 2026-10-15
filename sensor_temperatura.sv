module sensor_temperatura(
    input  logic clock,
    input  logic reset,
    input  logic sda,
    input  logic scl,

    output logic [7:0] display,     
    output logic [7:0] display_en
);


    //variaveis inteirnas
    //div_clk
    logic       clock_div;
    //FSM
    logic       fsm_out;
    //detectores
    logic       data_ready;
    logic [7:0] data_out;
    //trasformador
    logic [7:0] dado_montado;
    //desmontador

    divisor_clock div_clk (
        .clk_in  (clock),
        .clk_out (clock_div)
    );

    fsm FSM (
        .reset       (reset),
        .ps2_clk     (ps2_clk),
        .ps2_data    (ps2_data),
        .fsmoutdetin (fsm_out)
    );

    detector_borda detectores (
        .rst         (reset),
        .fsmoutdetin (fsm_out),
        .ps2_data    (ps2_data),
        .toggle_data_ready(data_ready),   // flag de 1 bit
        .novo_dado   (data_out)      // byte de 8 bits
    );

    transformador_ps2_ascii trasformador (
        .Dado_montado_ps2 (data_out),
        .dado_ascii_montado(dado_montado)
    );

    desmontador_ascii desmontador(
        .dado_ascii_montado(dado_montado),
        .reset (reset),
        .toggle_data_ready(data_ready),
        .clock9600(clock_div),
        .tx_data(tx_data),
        .tx_done(tx_done)
    );

endmodule
