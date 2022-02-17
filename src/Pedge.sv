module Pedge
(
    input logic clk, rst,
    input logic signal,
    output logic pedge
);

logic start_1s, passed_1s;
Timer #(.N(27)) _2s(.clk(clk), .rst(rst), .start(start_1s), .ceil(27'd99_999_999), .status(passed_1s));

enum logic[1:0] {S[3]} state;
always_ff @(posedge clk) begin
    if(rst) begin
        pedge <= 1'b0;
        start_1s <= 1'b0;
        
        state <= S0;
    end else begin
        case(state)
            S0: begin
                if(signal) begin
                    pedge <= 1'b1;
                    state <= S1; 
                end
            end

            S1: begin
                pedge <= 1'b0;
                start_1s <= 1'b1;

                state <= S2;
            end

            S2: begin 
                start_1s <= 1'b0;
                if(passed_1s) state <= S0;
            end    

            default: state <= S0;
        endcase
    end
end

endmodule
