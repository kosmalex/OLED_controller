import MyPkg::byte_t;

module ISegmentDisplay
#(
    parameter nSeg = 8
)
(
    input logic[3:0] val,
    output byte_t C
);

always_comb begin
    case(val)
        4'd0:
            C = 8'b00000011;
        4'd1:
            C = 8'b10011111;
        4'd2:
            C = 8'b00100101;
        4'd3:
            C = 8'b00001101;
        4'd4:
            C = 8'b10011001;
        4'd5:
            C = 8'b01001001;
        4'd6:
            C = 8'b01000001;
        4'd7:
            C = 8'b00011111;
        4'd8:
            C = 8'b00000001;
        4'd9:
            C = 8'b00001001;
        4'hA:
            C = 8'b00010001;
        4'hB:
            C = 8'b11000001;
        4'hC:
            C = 8'b01100011;
        4'hD:
            C = 8'b10000101;
        4'hE:
            C = 8'b01100001;
        4'hF:
            C = 8'b01110001;
        default:
            C = 8'b11111111;
    endcase
end

endmodule
