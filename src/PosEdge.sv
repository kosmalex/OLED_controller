module PosEdge
(
    input logic clk, rst,
    input logic signal,
    output logic pedge
);

logic[1:0] ff;
always_ff @(posedge clk) begin
    if(rst)
        ff <= 2'd0;
    else begin
        if(signal === 1'bX)
            ff[0] <= 1'b0;
        else
            ff[0] <= signal;

        ff[1] <= ff[0];
    end
end

assign pedge = ~ff[1] & ff[0];

endmodule
