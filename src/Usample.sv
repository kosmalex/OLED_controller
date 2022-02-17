module Usample
(
    input logic[3:0] In,
    output logic[7:0] Out
);

int base4 = 4'hF;
int base8 = 8'hFF;

always_comb begin
    Out = base8 * In / base4;
end

endmodule