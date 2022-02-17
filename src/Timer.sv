module Timer
#(
    parameter N = 4
)
(
    input logic clk, rst, start,
    input logic[N-1:0] ceil,
    output logic status
);
enum logic[1:0] {SLEEP, INCR, STOP} state;

logic pStrt;
PosEdge pStart(.clk(clk), .rst(rst), .signal(start), .pedge(pStrt));

logic[N-1:0] ctr;
always_ff @(posedge clk) begin
    if(rst) begin
        ctr <= 0;
        status <= 1'b0;
        state <= SLEEP;
    end else begin
        case(state)
            SLEEP: begin
                status <= 1'b0;
                
                if(pStrt) state <= INCR;
            end  
    
            INCR: begin
                if(ctr == ceil - 3) begin 
                    status <= 1'b1;
                    ctr <= 0;
    
                    state <= SLEEP;
                end else
                    ctr <= ctr + 1;
            end
    
            default: state <= SLEEP;
        endcase
    end
end

endmodule
