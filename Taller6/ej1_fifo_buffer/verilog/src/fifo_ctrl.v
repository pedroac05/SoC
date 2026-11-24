module fifo_ctrl #(
    parameter integer ADDR_WIDTH = 4
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  rd,
    input  wire                  wr,
    output wire                  empty,
    output wire                  full,
    output wire [ADDR_WIDTH-1:0] w_addr,
    output wire [ADDR_WIDTH-1:0] r_addr
);

    reg  [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next;
    reg  [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next;
    wire [ADDR_WIDTH-1:0] w_ptr_succ;
    wire [ADDR_WIDTH-1:0] r_ptr_succ;
    reg                   full_reg, full_next;
    reg                   empty_reg, empty_next;

    // Registro de estado para apuntadores y banderas
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_ptr_reg <= {ADDR_WIDTH{1'b0}};
            r_ptr_reg <= {ADDR_WIDTH{1'b0}};
            full_reg  <= 1'b0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

    // Valores sucesivos de los apuntadores
    assign w_ptr_succ = w_ptr_reg + 1'b1;
    assign r_ptr_succ = r_ptr_reg + 1'b1;

    // Logica de estado siguiente
    always @(*) begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;

        case ({wr, rd})
            2'b00: begin // no op
            end
            2'b01: begin // read
                if (!empty_reg) begin
                    r_ptr_next = r_ptr_succ;
                    full_next  = 1'b0;
                    if (r_ptr_succ == w_ptr_reg)
                        empty_next = 1'b1;
                end
            end
            2'b10: begin // write
                if (!full_reg) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_reg)
                        full_next = 1'b1;
                end
            end
            2'b11: begin // write / read simultaneo
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end
        endcase
    end

    // Salidas
    assign w_addr = w_ptr_reg;
    assign r_addr = r_ptr_reg;
    assign full   = full_reg;
    assign empty  = empty_reg;

endmodule
