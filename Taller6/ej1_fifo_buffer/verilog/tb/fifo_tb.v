`timescale 1ns / 1ps

module fifo_tb;
    localparam integer C_ADDR_WIDTH = 3; // 8 posiciones (Figura 2)
    localparam integer C_DATA_WIDTH = 8; // 8 bits por palabra
    localparam time    T_CLK        = 20; // 50 MHz (20 ns)

    reg                     clk_tb    = 1'b0;
    reg                     reset_tb  = 1'b0;
    reg                     rd_tb     = 1'b0;
    reg                     wr_tb     = 1'b0;
    reg  [C_DATA_WIDTH-1:0] w_data_tb = 8'h00;
    wire                    empty_tb;
    wire                    full_tb;
    wire [C_DATA_WIDTH-1:0] r_data_tb;

    reg [8*18-1:0] fig2_step = "(a) Init (empty)  ";
    integer errors = 0;

    fifo #(
        .ADDR_WIDTH(C_ADDR_WIDTH),
        .DATA_WIDTH(C_DATA_WIDTH)
    ) dut (
        .clk   (clk_tb),
        .reset (reset_tb),
        .rd    (rd_tb),
        .wr    (wr_tb),
        .w_data(w_data_tb),
        .empty (empty_tb),
        .full  (full_tb),
        .r_data(r_data_tb)
    );

    always #(T_CLK/2) clk_tb = ~clk_tb;

    task push_word(input [C_DATA_WIDTH-1:0] val);
        begin
            @(negedge clk_tb);
            wr_tb     = 1'b1;
            rd_tb     = 1'b0;
            w_data_tb = val;
            @(posedge clk_tb);
            #2;
            @(negedge clk_tb);
            wr_tb     = 1'b0;
        end
    endtask

    task pop_word;
        begin
            @(negedge clk_tb);
            rd_tb = 1'b1;
            wr_tb = 1'b0;
            @(posedge clk_tb);
            #2;
            @(negedge clk_tb);
            rd_tb = 1'b0;
        end
    endtask

    initial begin
        // (a) Estado inicial (empty)
        fig2_step = "(a) Init (empty)  ";
        reset_tb  = 1'b1;
        wr_tb     = 1'b0;
        rd_tb     = 1'b0;
        w_data_tb = 8'h00;
        #25;
        @(negedge clk_tb);
        reset_tb = 1'b0;
        #2;
        if (empty_tb !== 1'b1 || full_tb !== 1'b0) begin
            $display("Error en (a)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (b) Despues de 1 escritura
        fig2_step = "(b) 1 write       ";
        push_word(8'hA0);
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA0) begin
            $display("Error en (b)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (c) Despues de 3 escrituras mas
        fig2_step = "(c) +3 writes     ";
        push_word(8'hA1);
        push_word(8'hA2);
        push_word(8'hA3);
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA0) begin
            $display("Error en (c)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (d) Despues de 1 lectura
        fig2_step = "(d) 1 read        ";
        pop_word();
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA1) begin
            $display("Error en (d)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (e) 4 escrituras mas
        fig2_step = "(e) +4 writes     ";
        push_word(8'hA4);
        push_word(8'hA5);
        push_word(8'hA6);
        push_word(8'hA7);
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA1) begin
            $display("Error en (e)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (f) 1 escritura mas (full)
        fig2_step = "(f) +1 write(full)";
        push_word(8'hA8);
        if (empty_tb !== 1'b0 || full_tb !== 1'b1 || r_data_tb !== 8'hA1) begin
            $display("Error en (f)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (g) 2 lecturas
        fig2_step = "(g) 2 reads       ";
        pop_word();
        pop_word();
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA3) begin
            $display("Error en (g)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (h) 5 lecturas mas
        fig2_step = "(h) +5 reads      ";
        pop_word();
        pop_word();
        pop_word();
        pop_word();
        pop_word();
        if (empty_tb !== 1'b0 || full_tb !== 1'b0 || r_data_tb !== 8'hA8) begin
            $display("Error en (h)"); errors = errors + 1;
        end
        @(posedge clk_tb);

        // (i) 1 lectura (empty)
        fig2_step = "(i) +1 read(empty)";
        pop_word();
        if (empty_tb !== 1'b1 || full_tb !== 1'b0) begin
            $display("Error en (i)"); errors = errors + 1;
        end
        @(posedge clk_tb);
        #20;

        if (errors == 0)
            $display("=== SIMULACION VERILOG FIFO (FIGURA 2: a..i) COMPLETADA EXITOSAMENTE (0 ERRORES) ===");
        else
            $display("=== SIMULACION VERILOG FINALIZO CON %0d ERRORES ===", errors);
    end
endmodule
