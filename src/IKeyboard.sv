module IKeyboard
(
    input logic clk, rst,
    input logic[3:0] row,
    output logic[3:0] col, key,
    output logic key_was_pressed
);

logic[15:0] kwp;
logic[1:0][15:0] ff;
assign key_was_pressed = ~(|ff[1]) & |ff[0];
always_ff @(posedge clk) begin
    if(rst)
        ff <= {16'h0, 16'h0};
    else begin
        ff[0] <= kwp;
        ff[1] <= ff[0];
    end
end

logic[$clog2(400008) - 1:0] ctr;
always_ff @(posedge clk) begin
    if(rst) begin
        ctr <= 20'd0;
        kwp <= 4'b0;
    end
    else begin
        if(ctr == 20'd100000) begin
            col <= 4'b0111;
            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd100008) begin
            case(row)
                4'b0111: begin
                    key <= 4'd1;
                    kwp[0] <= 1'b1;
                    
                    kwp[3:1] <= 3'b0;
                end
                4'b1011: begin
                    key <= 4'd4;
                    kwp[1] <= 1'b1;
                    
                    kwp[3:2] <= 2'b0;
                    kwp[0] <= 1'b0;
                end
                4'b1101: begin
                    key <= 4'd7;
                    kwp[2] <= 1'b1;

                    kwp[1:0] <= 2'b0;
                    kwp[3] <= 1'b0;
                end
                4'b1110: begin
                    key <= 4'd0;
                    kwp[3] <= 1'b1;
                    
                    kwp[2:0] <= 3'b0;
                end
                default:
                    kwp[3:0] <= 4'b0;
            endcase

            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd200000) begin
            col <= 4'b1011;
            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd200008) begin
            case(row)
                4'b0111: begin
                    key <= 4'd2;
                    kwp[4] <= 1'b1;

                    kwp[7:5] <= 3'b0;
                end
                4'b1011: begin
                    
                    key <= 4'd5;
                    kwp[5] <= 1'b1;

                    kwp[7:6] <= 2'b0;
                    kwp[4] <= 1'b0;
                end
                4'b1101: begin
                    key <= 4'd8;
                    kwp[6] <= 1'b1;

                    kwp[5:4] <= 2'b0;
                    kwp[7] <= 1'b0;
                end
                4'b1110: begin
                    key <= 4'hF;
                    kwp[7] <= 1'b1;

                    kwp[6:4] <= 3'b0;
                end
                default:
                    kwp[7:4] <= 4'b0;
            endcase

            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd300000) begin
            col <= 4'b1101;
            ctr <= ctr +1'b1;
        end
        else if(ctr == 20'd300008) begin
            case(row)
                4'b0111: begin
                    key <= 4'd3;
                    kwp[8] <= 1'b1;

                    kwp[11:9] <= 3'b0;
                end
                4'b1011: begin
                    
                    key <= 4'd6;
                    kwp[9] <= 1'b1;

                    kwp[11:10] <= 2'b0;
                    kwp[8] <= 1'b0;
                end
                4'b1101: begin
                    key <= 4'd9;
                    kwp[10] <= 1'b1;

                    kwp[9:8] <= 2'b0;
                    kwp[11] <= 1'b0;
                end
                4'b1110: begin
                    key <= 4'hE;
                    kwp[11] <= 1'b1;

                    kwp[10:8] <= 3'b0;
                end
                default:
                    kwp[11:8] <= 4'b0;
            endcase

            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd400000) begin
            col <= 4'b1110;
            ctr <= ctr + 1'b1;
        end
        else if(ctr == 20'd400008) begin
            case(row)
               4'b0111: begin
                    key <= 4'hA;
                    kwp[12] <= 1'b1;

                    kwp[15:13] <= 3'b0;
                end
                4'b1011: begin
                    
                    key <= 4'hB;
                    kwp[13] <= 1'b1;

                    kwp[15:14] <= 2'b0;
                    kwp[12] <= 1'b0;
                end
                4'b1101: begin
                    key <= 4'hC;
                    kwp[14] <= 1'b1;

                    kwp[13:12] <= 2'b0;
                    kwp[15] <= 1'b0;
                end
                4'b1110: begin
                    key <= 4'hD;
                    kwp[15] <= 1'b1;

                    kwp[14:12] <= 3'b0;
                end
                default:
                    kwp[15:12] <= 4'b0;
            endcase

            ctr <= 0;
        end
        else begin
            ctr <= ctr + 1'b1;
        end
    end 
end

endmodule