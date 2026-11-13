// ============================================================================
// Modulo: comparator_signed
// Descripcion: Comparador combinacional de 4 bits para enteros con signo y sin signo.
//              Arquitectura paralela con evaluacion concurrente bit a bit
//              y selectores priorizados (operador ternario anidado).
// Puertos:
//   a   : Operando de entrada A (4 bits).
//   b   : Operando de entrada B (4 bits).
//   sig : Modo de operacion:
//         1'b0 => Sin signo (0 a 15).
//         1'b1 => Con signo en complemento a 2 (-8 a +7).
//   lg  : Nivel alto (1'b1) si A > B (larger).
//   eq  : Nivel alto (1'b1) si A = B (equal).
//   ls  : Nivel alto (1'b1) si A < B (less).
// ============================================================================
module comparator_signed (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       sig,
    output wire       lg,
    output wire       eq,
    output wire       ls
);

    // 1. Evaluacion paralela bit a bit
    wire [3:0] eq_bits = ~(a ^ b);       // XNOR: 1 si a[i] == b[i]
    wire [3:0] gt_bits = a & (~b);       // 1 si a[i]=1 y b[i]=0
    wire [3:0] lt_bits = (~a) & b;       // 1 si a[i]=0 y b[i]=1

    // 2. Condicion de igualdad total
    assign eq = &eq_bits;                // AND reduction de todos los bits de igualdad

    // 3. Selector priorizado para LG (A > B)
    assign lg = (~eq_bits[3] && sig)  ? lt_bits[3] : // Signo distinto: bit_signo(A)=0 y bit_signo(B)=1 => A > B
                (~eq_bits[3] && !sig) ? gt_bits[3] : // Sin signo: bit3(A)=1 y bit3(B)=0 => A > B
                (~eq_bits[2])         ? gt_bits[2] : // Bit 3 igual, decide Bit 2
                (~eq_bits[1])         ? gt_bits[1] : // Bits 3..2 iguales, decide Bit 1
                (~eq_bits[0])         ? gt_bits[0] : // Bits 3..1 iguales, decide Bit 0
                1'b0;

    // 4. Selector priorizado para LS (A < B)
    assign ls = (~eq_bits[3] && sig)  ? gt_bits[3] : // Signo distinto: bit_signo(A)=1 y bit_signo(B)=0 => A < B
                (~eq_bits[3] && !sig) ? lt_bits[3] : // Sin signo: bit3(A)=0 y bit3(B)=1 => A < B
                (~eq_bits[2])         ? lt_bits[2] : // Bit 3 igual, decide Bit 2
                (~eq_bits[1])         ? lt_bits[1] : // Bits 3..2 iguales, decide Bit 1
                (~eq_bits[0])         ? lt_bits[0] : // Bits 3..1 iguales, decide Bit 0
                1'b0;

endmodule

