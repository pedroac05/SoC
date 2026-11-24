module register_file #(
    parameter integer DATA_WIDTH = 8,
    parameter integer ADDR_WIDTH = 2
) (
    input  wire                  clk,
    input  wire                  wr_en,
    input  wire [ADDR_WIDTH-1:0] w_addr,
    input  wire [ADDR_WIDTH-1:0] r_addr,
    input  wire [DATA_WIDTH-1:0] w_data,
    output wire [DATA_WIDTH-1:0] r_data
);

    reg [DATA_WIDTH-1:0] array_reg [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (wr_en) begin
            array_reg[w_addr] <= w_data;
        end
    end

    assign r_data = array_reg[r_addr];

endmodule
