import MyPkg::byte_t;

module SegmentRefresh
#(
    parameter nSeg = 8
)
(
    input logic clk, rst,
    output byte_t AN
);

byte_t an;
assign AN = an;

logic[16:0] ctr;
always_ff @(posedge clk) begin
    if(rst) begin
        ctr <= 17'd0;
        an <= 8'b11111110;
    end else
        if(ctr == 17'd100000) begin
            an <= roll_shift(an);
            ctr <= 17'd0;
        end else
            ctr <= ctr + 1'b1;
end

function automatic byte_t roll_shift(byte_t bits);
    byte_t ret;
    logic last_bit;
    
    last_bit = bits[nSeg - 1];
    ret = bits << 1;
    ret[0] = last_bit;

    if(nSeg < 8)
        for (int i = nSeg; i < 8; i++)
            ret[i] = 1'b1;

    return ret;
endfunction

endmodule
