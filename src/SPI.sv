import MyPkg::byte_t;

module SPI
#(
    parameter T = 80
)
(
    input logic clk, rst,
    input logic start, stop,
    input logic write,
    input byte_t data,

    output logic done,
    output logic sclk, mosi, cs
);

logic pStart, pStop, pWrite;
PosEdge peStart(.clk(clk), .rst(rst), .signal(start), .pedge(pStart));
PosEdge peStop(.clk(clk), .rst(rst), .signal(stop), .pedge(pStop));
PosEdge peWrite(.clk(clk), .rst(rst), .signal(write), .pedge(pWrite));

logic[1:0] sel_sclk;
always_comb begin
    case(sel_sclk)
        2'd0: sclk = 1'b0;
        2'd1: sclk = 1'b1;
        2'd2: sclk = pulse;
        default: sclk = 1'b1;
    endcase
end

localparam T_div_2 = (T / 10) - 1;
logic[$clog2(T_div_2) - 1:0] ctr;
logic pulse;
always_ff @(posedge clk) begin : wav_gen
    if(rst) begin
        ctr <= 3'b0;
        pulse <= 1'b0;
    end
    else if(sel_sclk == 2'd2) begin
        if(ctr == T_div_2) begin
            pulse <= ~pulse;
            ctr <= 3'b0;
        end else
            ctr <= ctr + 1'b1;
    end else begin
        pulse <= 1'b0;
        ctr <= 1'b0;
    end
end

logic[3:0] i;
always_ff @(posedge clk) begin
    if(rst) begin
        i <= 0;
    end else if(sel_sclk == 2'd2) begin
        if(sclk == 1'b1 && ctr == 1'b0) 
            if(i < 8) i <= i + 1;
            else i <= 0;
    end else
        i <= 1'b0;
end

logic _80ns_passed, start_80ns;
Timer #(.N(3)) _80ns(.clk(clk), .rst(rst), .start(start_80ns), .ceil(3'd7), .status(_80ns_passed));

enum {IDLE, S[5], DONE} state;
always_ff @(posedge clk) begin
    if(rst) begin
        sel_sclk <= 1'b1;
        cs <= 1'b1;
        mosi <= 1'b0;
        done <= 1'b0;

        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if(pStart) begin
                    start_80ns <= 1'b1;
                    cs <= 1'b0;

                    state <= S0;
                end
            end

            S0: begin
                if(_80ns_passed) begin
                    start_80ns <= 1'b0;
                    sel_sclk <= 2'd0;
                    done <= 1'b1;

                    state <= S1;
                end
            end

            S1: begin
                if(pWrite) begin 
                    sel_sclk <= 2'd2;
                    done <= 1'b0;

                    state <= S2;
                end
                else if(pStop) begin
                    start_80ns <= 1'b1;
                    sel_sclk <= 1'b1;
                    done <= 1'b0;

                    state <= DONE;
                end 
            end

            S2: begin
                if(i < 8 && ctr == 2) begin
                    mosi <= data[7 - i];
                end else if(i == 8 && ctr == 7 && !sclk) begin
                    sel_sclk <= 1'b0;
                    mosi <= 1'b0;
                    done <= 1'b1;

                    state <= S1;
                end
            end

            DONE: begin
                if(_80ns_passed) begin
                    start_80ns <= 1'b0;
                    cs <= 1'b1;

                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end
endmodule
