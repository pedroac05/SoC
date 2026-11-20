// ==============================================================================
// Testbench Verilog para univ_bin_counter
// Parametros modificados en testbench: N = 4, MAX_COUNT = 4'd9 (4'b1001)
// Frecuencia de reloj simulada: 50 MHz (T_clk = 20 ns)
// ==============================================================================
// Escenarios verificados:
//   1. Reset asincrono inicial (rst = 1) -> counter = 0, min_tick = 1
//   2. Conteo ascendente completo (0 -> 9 -> 0) -> verifica max_tick y rollover
//   3. Pausa (ena = 0) y reanudacion (ena = 1)
//   4. Carga paralela sincrona (load = 1 por 1 ciclo, d = 6) -> cuenta 6..9..0
//   5. Conteo descendente (up = 0) -> verifica decremento, min_tick y underflow (0 -> 9)
//   6. Reinicio sincrono (syn_clr = 1) -> vuelve a 0 en flanco de subida de clk
//   7. Reset asincrono en mitad de ciclo (fuera de flanco de clk) -> efecto inmediato
// ==============================================================================

`timescale 1ns / 1ps

module univ_bin_counter_tb;

    // Parametros modificados para el testbench (contador modulo 10: 0..9)
    localparam integer C_N         = 4;
    localparam [C_N-1:0] C_MAX_COUNT = 4'b1001; // 9 decimal
    localparam integer T_CLK       = 20;        // 50 MHz

    // Senales de estimulo y observacion
    reg              clk_tb;
    reg              rst_tb;
    reg              ena_tb;
    reg              syn_clr_tb;
    reg              load_tb;
    reg              up_tb;
    reg  [C_N-1:0]   d_tb;
    wire             max_tick_tb;
    wire             min_tick_tb;
    wire [C_N-1:0]   counter_tb;

    integer i;
    integer errors = 0;

    // Instanciacion del DUT con parametros personalizados
    univ_bin_counter #(
        .N(C_N),
        .MAX_COUNT(C_MAX_COUNT)
    ) dut (
        .clk(clk_tb),
        .rst(rst_tb),
        .ena(ena_tb),
        .syn_clr(syn_clr_tb),
        .load(load_tb),
        .up(up_tb),
        .d(d_tb),
        .max_tick(max_tick_tb),
        .min_tick(min_tick_tb),
        .counter(counter_tb)
    );

    // Generador de reloj de 50 MHz (periodo = 20 ns)
    initial clk_tb = 1'b0;
    always #(T_CLK / 2) clk_tb = ~clk_tb;

    // Secuencia de pruebas y autoverificacion
    initial begin
        // ----------------------------------------------------------------------
        // 1. Reset asincrono inicial
        // ----------------------------------------------------------------------
        rst_tb     = 1'b1;
        ena_tb     = 1'b0;
        syn_clr_tb = 1'b0;
        load_tb    = 1'b0;
        up_tb      = 1'b1;
        d_tb       = 4'd0;
        #25;
        if (counter_tb !== 4'd0 || min_tick_tb !== 1'b1 || max_tick_tb !== 1'b0) begin
            $display("[ERROR] Fase 1: Reset asincrono inicial");
            errors = errors + 1;
        end

        rst_tb = 1'b0;
        @(negedge clk_tb);

        // ----------------------------------------------------------------------
        // 2. Conteo ascendente completo: 0 -> 9 (max_tick) -> 0 (rollover) -> 2
        // ----------------------------------------------------------------------
        ena_tb = 1'b1;
        up_tb  = 1'b1;
        for (i = 1; i <= 9; i = i + 1) begin
            @(posedge clk_tb);
            #2;
            if (counter_tb !== i[C_N-1:0]) begin
                $display("[ERROR] Fase 2 (ascendente): esperado %0d, obtenido %0d", i, counter_tb);
                errors = errors + 1;
            end
        end

        if (max_tick_tb !== 1'b1 || min_tick_tb !== 1'b0) begin
            $display("[ERROR] Fase 2: max_tick debe ser 1 en MAX_COUNT (9)");
            errors = errors + 1;
        end

        // Rollover 9 -> 0
        @(posedge clk_tb);
        #2;
        if (counter_tb !== 4'd0 || min_tick_tb !== 1'b1 || max_tick_tb !== 1'b0) begin
            $display("[ERROR] Fase 2: rollover 9 -> 0 fallido");
            errors = errors + 1;
        end

        // Avanzar hasta 2
        repeat (2) @(posedge clk_tb);
        #2;
        if (counter_tb !== 4'd2) begin
            $display("[ERROR] Fase 2: esperado 2, obtenido %0d", counter_tb);
            errors = errors + 1;
        end

        // ----------------------------------------------------------------------
        // 3. Pausa (ena = 0) durante 3 ciclos y reanudacion (ena = 1)
        // ----------------------------------------------------------------------
        @(negedge clk_tb);
        ena_tb = 1'b0;
        repeat (3) begin
            @(posedge clk_tb);
            #2;
            if (counter_tb !== 4'd2) begin
                $display("[ERROR] Fase 3: el contador no mantuvo pausa en 2");
                errors = errors + 1;
            end
        end

        // Reanudar conteo por 2 ciclos: 2 -> 3 -> 4
        @(negedge clk_tb);
        ena_tb = 1'b1;
        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd3) begin $display("[ERROR] Fase 3: esperado 3"); errors = errors + 1; end
        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd4) begin $display("[ERROR] Fase 3: esperado 4"); errors = errors + 1; end

        // ----------------------------------------------------------------------
        // 4. Carga paralela sincrona (load = 1 por 1 ciclo, d = 6) y conteo hasta 9
        // ----------------------------------------------------------------------
        @(negedge clk_tb);
        d_tb    = 4'd6;
        load_tb = 1'b1;
        @(posedge clk_tb);
        #2;
        if (counter_tb !== 4'd6) begin
            $display("[ERROR] Fase 4: carga paralela d = 6 fallida");
            errors = errors + 1;
        end

        @(negedge clk_tb);
        load_tb = 1'b0;
        d_tb    = 4'd0;

        for (i = 7; i <= 9; i = i + 1) begin
            @(posedge clk_tb);
            #2;
            if (counter_tb !== i[C_N-1:0]) begin
                $display("[ERROR] Fase 4: esperado %0d tras load, obtenido %0d", i, counter_tb);
                errors = errors + 1;
            end
        end
        if (max_tick_tb !== 1'b1) begin
            $display("[ERROR] Fase 4: max_tick debe ser 1 en 9");
            errors = errors + 1;
        end

        // Rollover y avance: 9 -> 0 -> 1 -> 2
        repeat (3) @(posedge clk_tb);
        #2;
        if (counter_tb !== 4'd2) begin
            $display("[ERROR] Fase 4: esperado 2 antes de invertir direccion");
            errors = errors + 1;
        end

        // ----------------------------------------------------------------------
        // 5. Conteo descendente (up = 0): 2 -> 1 -> 0 (min_tick) -> 9 (underflow) -> 7
        // ----------------------------------------------------------------------
        @(negedge clk_tb);
        up_tb = 1'b0;

        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd1) begin $display("[ERROR] Fase 5: esperado 1"); errors = errors + 1; end

        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd0 || min_tick_tb !== 1'b1) begin
            $display("[ERROR] Fase 5: esperado 0 y min_tick = 1");
            errors = errors + 1;
        end

        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd9 || max_tick_tb !== 1'b1) begin
            $display("[ERROR] Fase 5: underflow 0 -> 9 (MAX_COUNT) fallido");
            errors = errors + 1;
        end

        repeat (2) @(posedge clk_tb); #2; // 8 -> 7
        if (counter_tb !== 4'd7) begin $display("[ERROR] Fase 5: esperado 7"); errors = errors + 1; end

        // ----------------------------------------------------------------------
        // 6. Reinicio sincrono (syn_clr = 1)
        // ----------------------------------------------------------------------
        @(negedge clk_tb);
        syn_clr_tb = 1'b1;
        #4;
        if (counter_tb !== 4'd7) begin
            $display("[ERROR] Fase 6: syn_clr no debe actuar antes del flanco de clk");
            errors = errors + 1;
        end

        @(posedge clk_tb); #2;
        if (counter_tb !== 4'd0 || min_tick_tb !== 1'b1) begin
            $display("[ERROR] Fase 6: syn_clr fallo al reiniciar en flanco de clk");
            errors = errors + 1;
        end

        @(negedge clk_tb);
        syn_clr_tb = 1'b0;
        up_tb      = 1'b1;

        repeat (3) @(posedge clk_tb); #2; // 1 -> 2 -> 3
        if (counter_tb !== 4'd3) begin $display("[ERROR] Fase 7: esperado 3"); errors = errors + 1; end

        // ----------------------------------------------------------------------
        // 7. Reset asincrono en mitad de ciclo (efecto inmediato)
        // ----------------------------------------------------------------------
        #5;
        rst_tb = 1'b1;
        #2;
        if (counter_tb !== 4'd0 || min_tick_tb !== 1'b1) begin
            $display("[ERROR] Fase 7: rst asincrono debe limpiar inmediatamente");
            errors = errors + 1;
        end

        @(negedge clk_tb);
        @(negedge clk_tb);
        rst_tb = 1'b0;
        ena_tb = 1'b0;
        #20;

        if (errors == 0)
            $display("=== SIMULACION VERILOG COMPLETADA EXITOSAMENTE (0 ERRORES) ===");
        else
            $display("=== SIMULACION VERILOG FINALIZADA CON %0d ERRORES ===", errors);
    end

endmodule
