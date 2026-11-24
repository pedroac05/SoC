module edge_detect (
    input  wire clk,
    input  wire async_sig,
    output reg  rise = 1'b0,
    output reg  fall = 1'b0
);

    reg [1:3] resync  = 3'b000;
    reg [1:3] shifter = 3'b000;

    always @(posedge clk) begin
        // Detect rising and falling edges
        rise <= resync[2] & (~resync[3]);
        fall <= resync[3] & (~resync[2]);
        // Update history shifter
        resync  = {async_sig, resync[1:2]};
        shifter <= resync;
    end

endmodule
