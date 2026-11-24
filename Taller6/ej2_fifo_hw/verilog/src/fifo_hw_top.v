module fifo_hw_top #(
    parameter integer ADDR_WIDTH = 4,
    parameter integer DATA_WIDTH = 4
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  rd,
    input  wire                  wr,
    input  wire [DATA_WIDTH-1:0] w_data,
    output wire                  empty,
    output wire                  full,
    output wire [6:0]            r_data_hex
);

    wire                  rd_tick;
    wire                  wr_tick;
    wire [DATA_WIDTH-1:0] r_data_s;

    edge_detect pop_tick_gen (
        .clk      (clk),
        .async_sig(rd),
        .rise     (rd_tick),
        .fall     ()
    );

    edge_detect push_tick_gen (
        .clk      (clk),
        .async_sig(wr),
        .rise     (wr_tick),
        .fall     ()
    );

    fifo #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_buffer (
        .clk   (clk),
        .reset (reset),
        .rd    (rd_tick),
        .wr    (wr_tick),
        .w_data(w_data),
        .empty (empty),
        .full  (full),
        .r_data(r_data_s)
    );

    bin_to_sseg bin2sseg (
        .bin (r_data_s),
        .sseg(r_data_hex)
    );

endmodule
