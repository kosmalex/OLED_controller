module Decoder
#(
    parameter nOuts = 12'h200 //1kibi Output bits
)
(
    input logic[$clog2(nOuts) - 1:0] In,
    output logic[nOuts - 1:0] Out
);

always_comb begin
    for(int i = 0; i < nOuts; i++) begin
        Out[i] = In == i; 
    end
end

endmodule
