module Memory
(
    input logic clk, rst,
    input logic WE_bar, CS_bar,
    input logic[2:0] Address,
    input logic[11:0][7:0] DataIn, 
  
    output logic[11:0][7:0] DataOut
);

generate;
    genvar i;
    for(i = 0; i < 12; i++) begin : genMemChips
        MemoryChip mem_chp(.clk(clk), .rst(rst), .WE_bar(WE_bar), .CS_bar(CS_bar), .Address(Address), .DataIn(DataIn[i]), .DataOut(DataOut[i]));
    end
endgenerate

endmodule
