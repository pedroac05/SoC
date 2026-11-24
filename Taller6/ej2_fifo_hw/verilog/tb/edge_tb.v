`timescale 1ns / 1ps

module edge_tb;
    reg  clk   = 1'b0;
    reg  async = 1'b0;
    wire rise, fall, rise2, fall2;

    edge_detect DUT (
        .async_sig(async),
        .clk      (clk),
        .rise     (rise),
        .fall     (fall)
    );

    edge_detect DUT2 (
        .async_sig(rise),
        .clk      (clk),
        .rise     (rise2),
        .fall     (fall2)
    );

    initial begin
        while ($time < 1000) begin
            #10 clk = ~clk;
        end
    end

    // Secuencia pseudoaleatoria equivalente a edge_tb.vhd (intervalos entre 50 y 150 ns)
    integer delays [0:11];
    integer i;
    initial begin
        delays[0]  = 84;
        delays[1]  = 112;
        delays[2]  = 67;
        delays[3]  = 131;
        delays[4]  = 95;
        delays[5]  = 73;
        delays[6]  = 120;
        delays[7]  = 88;
        delays[8]  = 64;
        delays[9]  = 105;
        delays[10] = 79;
        delays[11] = 90;

        for (i = 0; i < 12; i = i + 1) begin
            if ($time < 1000) begin
                @(negedge clk);
                #(delays[i]);
                async = ~async;
            end
        end
    end
endmodule
