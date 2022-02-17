import MyPkg::*;

module System
(
    input logic clk, rst,

    //Switches
    input logic mode, //0: kypd_buffer, 1: reg_file
    input logic[1:0] stage, //0: program, 1: compile, 2: run
    input logic on_off, // oled on/off

    //Buttons
    input logic detect, //Initiate color detection
    input logic compile, //Compile "Code"
    input logic run, //Run program

    //Pmod_KYPD
    input logic[3:0] row,
    output logic[3:0] col,

    //Pmod_ENC
    input logic A_ENC, B_ENC,
    input logic btn, swt,

    //Pmod_COLOR 
    input logic led_in,
    inout logic sda,
    output logic sclk_c, led_en,

    //Pmod_OLED
    output logic sclk_o, mosi, cs, 
    output logic vcc_en, pmod_en, dc, res,

    //RGB OLED
    output logic R, G, B,

    //7_Segment_LEDs
    output byte_t AN, C,

    //LEDs
    output logic[2:0] mem_addr
);

//Programmer
logic WE_bar_0;
logic[2:0] RF_Addr;
logic[31:0] entrdCommand;

//Register_File
logic[31:0] DataOut;
logic[2:0] Addr_RF;

//IDisplay
logic rdy;

//IColor
byte_t r, g, b;

//Compiler
logic WE_bar_1, cmpl_done, compl;
logic[2:0] IS_RF_Addr;
logic[95:0] cmpldCommand;

//Instr_Set
logic[95:0] exeCommand;
logic[2:0] Addr_IS;

//ExecModule
logic exe;
logic[2:0] IS_Addr;

//Assigns
assign mem_addr = (stage == 0 || stage == 1) ? Addr_RF : Addr_IS;
assign Addr_RF = (stage == 0) ? RF_Addr : (stage == 1) ? IS_RF_Addr : 0;
assign Addr_IS = (stage == 1) ? IS_RF_Addr : (stage == 2) ? IS_Addr : 0;
assign compl = (stage == 1) ? compile : 1'b0;
assign exe = (stage == 2) ? run : 1'b0;

//Modules
IColor PmodCOLOR(.clk(clk), .rst(~rst), .detect(detect), .led_in(led_in), .sda(sda), .sclk(sclk_c), .led_en(led_en), .R(R), .G(G), .B(B), 
                 .r(r), .g(g), .b(b));

Programmer code_writer(.clk(clk), .rst(~rst), .mode(mode), .stage(stage), .row(row), .col(col), .A(A_ENC), .B(B_ENC), .btn(btn), .swt(swt), 
                       .AN(AN), .C(C), .WE_bar(WE_bar_0), .Addr(RF_Addr), .entrdCommand(entrdCommand), .RF_Data(DataOut));

defparam reg_file.WORD_SIZE = 32; // 32-bits
MemoryChip reg_file(.clk(clk), .rst(~rst), .WE_bar(WE_bar_0), .CS_bar(1'b0), .Address(Addr_RF), .DataIn(entrdCommand), .DataOut(DataOut));

Compiler to_executable(.clk(clk), .rst(~rst), .compile(compl), .DataIn(DataOut), .color({r, g, b}), .WE_bar(WE_bar_1), .done(cmpl_done), 
                       .Addr(IS_RF_Addr), .DataOut(cmpldCommand));

Memory dot_exe(.clk(clk), .rst(~rst), .WE_bar(WE_bar_1), .CS_bar(1'b0), .Address(Addr_IS), .DataIn(cmpldCommand), .DataOut(exeCommand));

ExecModule driver(.clk(clk), .rst(~rst), .rdy_oled(oled.rdy), .rdy_compiler(cmpl_done), .run(exe), .DataIn(exeCommand), .Addr(IS_Addr),
                  .draw(oled.draw), .cmd(oled.cmd), .oled_IR(oled.IR));

IDisplay PmodOLED(.clk(clk), .rst(~rst), .on_off(on_off), .exec(oled.draw), .cmd(oled.cmd), .IR(oled.IR), .rdy(oled.rdy), 
                  .sclk(sclk_o), .mosi(mosi), .vcc_en(vcc_en), .pmod_en(pmod_en), .cs(cs), .dc(dc), .res(res));
endmodule