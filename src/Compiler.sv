import MyPkg::*;

module Compiler
(
    input logic clk, rst,
    input logic compile,
    input byte4_t DataIn,
    input byte_t[2:0] color,

    output logic WE_bar, done,
    output logic[2:0] Addr,
    output logic[95:0] DataOut
);

logic pCompile;
Pedge peCompile(.clk(clk), .rst(rst), .signal(compile), .pedge(pCompile));

logic sel_IR;
byte4_t IR;
always_ff @(posedge clk) begin : DataInREG
    if(rst) begin
        IR <= 0;
    end else begin
        if(sel_IR)
            IR <= DataIn;
    end
end

logic sel_Addr;
always_ff @(posedge clk) begin : AddrOutREG
    if(rst) begin
        Addr <= 0;
    end else begin
        if(sel_Addr)
            Addr <= Addr + 1;
    end
end

logic sel_cmd, sel_colr, sel_offset, sel_opcode;
logic[1:0][4:0] cmd;
logic[11:0] InColor;
byte_t[2:0] OutColor;
byte2_t[1:0] offset;
byte_t[1:0] opcode;
always_ff @(posedge clk) begin : CmdREG
    if(rst) begin
        {cmd, InColor, OutColor, offset} <= 0;
    end else begin
        if(sel_cmd)
            cmd[0] <= IR[31:28];
        else
            cmd[1] <= cl_cmd;
        
        if(sel_offset)
            offset[0] <= IR[27:12];
        else
            offset[1] <= offset[0];

        if(sel_colr)
            InColor <= IR[11:0];
        else
            OutColor <= cl_colr;

        if(sel_opcode)
            opcode[0] <= 0;
        else
            opcode[1] <= cl_opcode;
    end
end

logic sel_DataOut;
always_ff @(posedge clk) begin
    if(rst)
        DataOut[95:0] <= 96'h00_00_10_10_40_30_00_00_00_00_00_00;
    else begin
        if(sel_DataOut) begin
            DataOut[92] <= cl_fill;
            DataOut[91:88] <= cmd[1];
            DataOut[87:80] <= opcode[1];
            DataOut[47:0] <= cl_LSBs;
            
            if(opcode[1] == 8'h25)
                DataOut[79:48] <= 32'h00_00_5F_3F;
            else
                DataOut[79:48] <= 32'h10_10_40_20;
        end
    end
end

logic cl_fill;
logic[3:0] cl_cmd;
logic[7:0] cl_opcode;
always_comb begin : CL_cmd_opcode
    case(cmd[0])
        4'd0: begin
            cl_cmd = 4'd3;
            cl_opcode = 8'h21;
            cl_fill = 1'b0;
        end 

        4'd1: begin
            cl_cmd = 4'd3;
            cl_opcode = 8'h21;
            cl_fill = 1'b0;
        end 

        4'd2: begin
            cl_cmd = 4'd4;
            cl_opcode = 8'h22;
            cl_fill = 1'b0;
        end 

        4'd3: begin
            cl_cmd = 4'd4;
            cl_opcode = 8'h22;
            cl_fill = 1'b1;
        end 

        4'd4: begin
            cl_cmd = 4'd4;
            cl_opcode = 8'h22;
            cl_fill = 1'b0;
        end 

        4'd5: begin
            cl_cmd = 4'd4;
            cl_opcode = 8'h22;
            cl_fill = 1'b1;
        end 
        4'd6: begin
            cl_cmd = 4'd2;
            cl_opcode = 8'h23;
            cl_fill = 1'b0;
        end 

        4'd7: begin
            cl_cmd = 4'd1;
            cl_opcode = 8'h25;
            cl_fill = 1'b0;
        end 

        default: begin
            cl_cmd = 4'd1;
            cl_opcode = 8'h25;
            cl_fill = 1'b0;
        end 
    endcase
end

byte_t[2:0] cl_colr;
UsampleChip CL_colr(.In(InColor), .Out(cl_colr));

logic[47:0] cl_LSBs;
always_comb begin
    if(opcode[1] == 8'h23) begin
        cl_LSBs = {offset[1], 32'h0};
    end else begin
        if(cmd[0] == 1 || cmd[0] == 4 || cmd[0] == 5)
            cl_LSBs = {color[2], color[1], color[0], color[2], color[1], color[0]};
        else
            cl_LSBs = {OutColor[2], OutColor[1], OutColor[0], OutColor[2], OutColor[1], OutColor[0]};
    end 
end

enum {S[10], IDLE} state;
logic[3:0] i;
always_ff @(posedge clk) begin
    if(rst) begin
        {sel_opcode, sel_cmd, sel_colr, sel_offset} <= 0;
        {sel_IR, sel_DataOut, sel_Addr} <= 0;
        WE_bar <= 1'b1;
        i <= 0;

        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin 
                done <= 1'b1;

                if(pCompile) begin
                    done <= 1'b0; 
                    state <= S0;
                end
            end

            S0: begin
                if(i < 8) begin
                    WE_bar <= 1'b1;
                    i <= i + 1;

                    sel_IR <= 1'b1;
                    sel_colr <= 1'b1;

                    state <= S1;
                end else begin
                    {sel_opcode, sel_cmd, sel_colr, sel_offset} <= 0;
                    {sel_IR, sel_DataOut, sel_Addr} <= 0;
                    WE_bar <= 1'b1;
                    i <= 0;

                    state <= IDLE;
                end   
            end

            S1: begin
                {sel_IR, sel_colr} <= 0;
                {sel_opcode, sel_cmd, sel_colr, sel_offset} <= 4'hF;
                sel_Addr <= 1'b1;

                state <= S2;
            end

            S2: begin
                {sel_opcode, sel_cmd, sel_colr, sel_offset} <= 0;
                sel_Addr <= 1'b0;

                state <= S3;
            end

            S3: begin
                sel_DataOut <= 1'b1;

                
                state <= S4;
            end

            S4: begin
                sel_DataOut <= 1'b0;
                WE_bar <= 1'b0;

                state <= S0;
            end

            default: state <= IDLE;
        endcase
    end   
end
endmodule
