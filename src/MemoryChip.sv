module MemoryChip
#(
    parameter nCells = 8,
    parameter WORD_SIZE = 8
)
(
    input logic clk, rst,
    input logic WE_bar, CS_bar,
    input logic[$clog2(nCells) - 1:0] Address,
    input logic[WORD_SIZE - 1:0] DataIn, 
  
    output logic[WORD_SIZE - 1:0] DataOut 
);

logic WE;
assign WE = ~(WE_bar | CS_bar);

logic[nCells - 1:0] PTR;
Decoder #(.nOuts(nCells)) pnt2row(.In(Address), .Out(PTR));

defparam mem_core.nCells = nCells;
defparam mem_core.WORD_SIZE = WORD_SIZE;
MemoryCore mem_core(.clk(clk), .rst(rst), .WE(WE), .PTR(PTR), .ADDR(Address), .DataIn(DataIn), .DataOut(DataOut));

endmodule
