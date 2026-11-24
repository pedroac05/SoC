module fifo #(
    parameter integer ADDR_WIDTH = 2,
    parameter integer DATA_WIDTH = 8
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  rd,
    input  wire                  wr,
    input  wire [DATA_WIDTH-1:0] w_data,
    output wire                  empty,
    output wire                  full,
    output wire [DATA_WIDTH-1:0] r_data
);

    wire                  full_s;
    wire                  wr_en;
    wire [ADDR_WIDTH-1:0] w_addr_s;
    wire [ADDR_WIDTH-1:0] r_addr_s;

    assign wr_en = wr & (~full_s);
    assign full  = full_s;

    fifo_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ctrl_unit (
        .clk   (clk),
        .reset (reset),
        .rd    (rd),
        .wr    (wr),
        .empty (empty),
        .full  (full_s),
        .w_addr(w_addr_s),
        .r_addr(r_addr_s)
    );

    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) reg_file_unit (
        .clk   (clk),
        .wr_en (wr_en),
        .w_addr(w_addr_s),
        .r_addr(r_addr_s),
        .w_data(w_data),
        .r_data(r_data)
    );

endmodule
