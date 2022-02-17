module Cell
#(
    parameter logic[31:0] default_val = 0,
    parameter WORD_SIZE = 8
)
(
    input logic clk, rst,
    input logic Addr, WE,
    input logic[WORD_SIZE - 1:0] DataIn,

    output logic[WORD_SIZE - 1:0] DataOut
);

logic[WORD_SIZE - 1:0] ff;
always_ff @(posedge clk) begin
    if(rst)
        ff <= default_val;
    else if(Addr & WE)
        ff <= DataIn;
end

assign DataOut = Addr ? ff : 0;

endmodule
