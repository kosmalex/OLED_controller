import MyPkg::*;

module Programmer
(
    input logic clk, rst,

    //Switches
    input logic mode, //0: kypd_buffer, 1: reg_file
    input logic[1:0] stage,

    //Pmod_KYPD
    input logic[3:0] row,
    output logic[3:0] col,

    //Pmod_ENC
    input logic A, B,
    input logic btn, swt,

    //7_Segment_LEDs
    output byte_t AN, C,

    //LEDs
    output logic[2:0] Addr,

    //Register_File
    input logic[7:0][3:0] RF_Data,
    output logic WE_bar,
    output logic[31:0] entrdCommand
);

logic kwp;
logic[3:0] key;
IKeyboard PmodKYPD(.clk(clk), .rst(rst), .row(row), .col(col), .key(key), .key_was_pressed(kwp));

logic[2:0] i;
logic[7:0][3:0] kypd_buffer;
assign entrdCommand = kypd_buffer;
always_ff @(posedge clk) begin : writer_kypd_buffer
    if(rst) begin
        kypd_buffer <= 0;
        i <= 0;
    end else if(kwp & !mode & !swt) begin
        kypd_buffer[i] <= key;
        i <= i + 1; 
    end else if(add & !mode & swt) i <= i + 1;
    else if(sub & !mode & swt) i <= i - 1;
end

logic add, sub;
IEncoder PmodENC(.clk(clk), .rst(rst), .A(A), .B(B), .add(add), .sub(sub));

byte_t an;
assign AN = an;
SegmentRefresh arbiter(.clk(clk), .rst(rst), .AN(an));

logic[2:0] k;
always_comb begin : InvEncoder
    k[0] = ~(an[1] & an[3] & an[5] & an[7]);
    k[1] = ~(an[2] & an[3] & an[6] & an[7]);
    k[2] = ~(an[4] & an[5] & an[6] & an[7]);
end

logic pBTN;
Pedge pedge_btn(.clk(clk), .rst(rst), .signal(btn), .pedge(pBTN));

enum logic {IDLE, WRITE_AND_INC} state;
always_ff @(posedge clk) begin
    if(rst) begin
        WE_bar <= 1'b1;
        Addr <= 0;
        
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if(add & mode & (stage == 0)) Addr <= Addr + 1;
                else if(sub & mode & (stage == 0)) Addr <= Addr - 1;
                
                if(pBTN & (stage == 0)) begin
                    WE_bar <= 1'b0;

                    state <= WRITE_AND_INC;
                end
            end
            
            WRITE_AND_INC: begin
                WE_bar <= 1'b1;
                Addr <= Addr + 1'b1;

                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

logic[3:0] val;
assign val = mode ? RF_Data[k] : kypd_buffer[k];

byte_t c;
ISegmentDisplay display(.val(val), .C(c));

always_comb begin : Light_up_dot
    if(!mode) begin
        if(k == i) C = {c[7:1], 1'b0};
        else C = c;
    end else begin
        C = c;
    end
end

endmodule
