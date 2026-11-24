module bin_to_sseg (
    input  wire [3:0] bin,
    output reg  [6:0] sseg
);

    always @(*) begin
        case (bin)
            4'h0: sseg = 7'b1000000; // 0
            4'h1: sseg = 7'b1111001; // 1
            4'h2: sseg = 7'b0100100; // 2
            4'h3: sseg = 7'b0110000; // 3
            4'h4: sseg = 7'b0011001; // 4
            4'h5: sseg = 7'b0010010; // 5
            4'h6: sseg = 7'b0000010; // 6
            4'h7: sseg = 7'b1111000; // 7
            4'h8: sseg = 7'b0000000; // 8
            4'h9: sseg = 7'b0010000; // 9
            4'hA: sseg = 7'b0001000; // A
            4'hB: sseg = 7'b0000011; // b
            4'hC: sseg = 7'b1000110; // C
            4'hD: sseg = 7'b0100001; // d
            4'hE: sseg = 7'b0000110; // E
            4'hF: sseg = 7'b0001110; // F
            default: sseg = 7'b1111111;
        endcase
    end

endmodule
