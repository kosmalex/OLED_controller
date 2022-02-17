module ExecModule
(
    input logic clk, rst,
    input logic rdy_oled, rdy_compiler, run,
    input logic[95:0] DataIn,

    output logic draw,
    output logic[2:0] Addr,
    output logic[3:0] cmd,
    output logic[87:0] oled_IR
);

assign cmd = IR[91:88];

logic pRun;
Pedge peRun(.clk(clk), .rst(rst), .signal(run), .pedge(pRun));

logic sel_IR;
logic[95:0] IR;
always_ff @(posedge clk) begin
    if(rst) begin
        IR <= 0;
    end else if(sel_IR)
        IR <= DataIn;
end

logic sel_Addr;
always_ff @(posedge clk) begin
    if(rst)
        Addr <= 0;
    else if(sel_Addr)
        Addr <= Addr + 1; 
end

logic sel_oIR;
always_ff @(posedge clk) begin
    if(rst)
        oled_IR <= 0;
    else if(sel_oIR)
        oled_IR <= IR[87:0];
    else 
        oled_IR <= cl_command;
end

logic[87:0] cl_command;
always_comb begin : next_oled_instr
    if(IR[92])
        cl_command = 88'h26_01_00_00_00_00_00_00_00_00_00;
    else 
        cl_command = 88'h26_00_00_00_00_00_00_00_00_00_00;
end

enum logic[2:0] {IDLE, S[5]} state;
always_ff @(posedge clk) begin
    if(rst) begin
        {sel_IR, sel_Addr, sel_oIR} <= 0;
        draw <= 0;
        
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if(rdy_compiler & rdy_oled & pRun) state <= S0;    
            end

            S0: begin
                {sel_IR, sel_Addr, sel_oIR} <= 3'b110;
                
                state <= S1;
            end

            S1: begin
                {sel_IR, sel_Addr, sel_oIR} <= 3'b000;
                draw <= 1'b1;
                
                state <= S2;
            end

            S2: begin
                {sel_IR, sel_Addr, sel_oIR} <= 3'b000;
                draw <= 1'b0;

                state <= S3;
            end

            S3: begin
                if(rdy_oled) begin
                    {sel_IR, sel_Addr, sel_oIR} <= 3'b001;
                    draw <= 1'b1;
                    
                    state <= S4;
                end
            end

            S4: begin
                {sel_IR, sel_Addr, sel_oIR} <= 3'b001;
                draw <= 1'b0;

                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
