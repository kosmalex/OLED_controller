import MyPkg::byte_t;

module IEncoder
(
    input logic clk, rst,
    input logic A, B,

    output logic add, sub 
);
enum logic[3:0] {IDLE, A[3], B[3], SUB, ADD} state;

always_ff @(posedge clk) begin
    if(rst) begin
        add <= 1'b0;
        sub <= 1'b0;

        state <= IDLE;
    end else
        case(state)
            IDLE: begin
                add <= 1'b0;
                sub <= 1'b0;

                if(~A)
                    state <= A0;
                else if(~B)
                    state <= B0;    
            end

            A0: begin
                if(A)
                    state <= IDLE;
                else if(~B)
                    state <= A1;
            end

            A1: begin
                if(B)
                    state <= A0;
                else if(A)
                    state <= A2;
            end

            A2: begin
                if(~A)
                    state <= A1;
                else if(B)
                    state <= SUB;
            end

            SUB: begin
                sub <= 1'b1;

                state <= IDLE;
            end 

            B0: begin
                if(B)
                    state <= IDLE;
                else if(~A)
                    state <= B1;
            end

            B1: begin
                if(A)
                    state <= B0;
                else if(B)
                    state <= B2;
            end

            B2: begin
                if(~B)
                    state <= B1;
                else if(A)
                    state <= ADD;
            end

            ADD: begin
                add <= 1'b1;

                state <= IDLE;
            end
            
            default:
                state <= IDLE;
        endcase
end

endmodule
