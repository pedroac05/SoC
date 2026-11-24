`timescale 1ns / 1ps

module fifo_hw_tb;
    localparam time T_CLK = 20; // 50 MHz

    reg        clk_tb    = 1'b0;
    reg        reset_tb  = 1'b0;
    reg        rd_tb     = 1'b0;
    reg        wr_tb     = 1'b0;
    reg  [3:0] w_data_tb = 4'b0000;
    wire       empty_tb;
    wire       full_tb;
    wire [6:0] r_data_hex_tb;

    integer i;
    integer errors = 0;

    fifo_hw_top #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(4)
    ) dut (
        .clk       (clk_tb),
        .reset     (reset_tb),
        .rd        (rd_tb),
        .wr        (wr_tb),
        .w_data    (w_data_tb),
        .empty     (empty_tb),
        .full      (full_tb),
        .r_data_hex(r_data_hex_tb)
    );

    always #(T_CLK/2) clk_tb = ~clk_tb;

    task press_push_button(input [3:0] val);
        begin
            w_data_tb = val;
            #13;
            wr_tb = 1'b1;
            #70;
            wr_tb = 1'b0;
            #37;
        end
    endtask

    task press_pop_button;
        begin
            #13;
            rd_tb = 1'b1;
            #70;
            rd_tb = 1'b0;
            #37;
        end
    endtask

    initial begin
        reset_tb  = 1'b1;
        wr_tb     = 1'b0;
        rd_tb     = 1'b0;
        w_data_tb = 4'h0;
        #45;
        reset_tb  = 1'b0;
        #35;
        if (empty_tb !== 1'b1 || full_tb !== 1'b0) errors = errors + 1;

        for (i = 0; i < 16; i = i + 1) begin
            press_push_button(i[3:0]);
        end
        if (full_tb !== 1'b1 || empty_tb !== 1'b0 || r_data_hex_tb !== 7'b1000000)
            errors = errors + 1;

        for (i = 0; i < 16; i = i + 1) begin
            press_pop_button();
        end
        if (empty_tb !== 1'b1 || full_tb !== 1'b0)
            errors = errors + 1;

        #40;
        if (errors == 0)
            $display("=== SIMULACION VERILOG FIFO_HW_TOP (16x4 + EDGE_DETECT + 7SEG) EXITOSA (0 ERRORES) ===");
        else
            $display("=== SIMULACION VERILOG FINALIZO CON %0d ERRORES ===", errors);
    end
endmodule
