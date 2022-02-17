module MemoryCore
#(
    parameter nCells = 8,
    parameter WORD_SIZE = 8
)
(
    input logic clk, rst,
    input logic WE,
    input logic[nCells - 1:0] PTR,
    input logic[$clog2(nCells) - 1:0] ADDR,
    input logic[WORD_SIZE - 1:0] DataIn,

    output logic[WORD_SIZE - 1:0] DataOut
);

logic[nCells - 1:0][WORD_SIZE - 1:0] cell_out;

Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h0_0000_F00)) c0(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[0]), .DataIn(DataIn), .DataOut(cell_out[0]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h1_0000_000)) c1(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[1]), .DataIn(DataIn), .DataOut(cell_out[1]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h3_0000_0F0)) c2(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[2]), .DataIn(DataIn), .DataOut(cell_out[2]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h2_0000_00F)) c3(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[3]), .DataIn(DataIn), .DataOut(cell_out[3]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h4_0000_F0F)) c4(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[4]), .DataIn(DataIn), .DataOut(cell_out[4]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h5_0000_F00)) c5(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[5]), .DataIn(DataIn), .DataOut(cell_out[5]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h6_3030_000)) c6(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[6]), .DataIn(DataIn), .DataOut(cell_out[6]));        
Cell #(.WORD_SIZE(WORD_SIZE), .default_val(32'h7_0000_000)) c7(.clk(clk), .rst(rst), .WE(WE), .Addr(PTR[7]), .DataIn(DataIn), .DataOut(cell_out[7]));        

assign DataOut = cell_out[ADDR];

endmodule
