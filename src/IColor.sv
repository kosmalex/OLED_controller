import MyPkg::*;

module IColor
(
    input logic clk, rst,
    input logic detect,

    //PmodColor 
    input logic led_in,
    inout logic sda,
    output logic sclk, led_en,

    //RGB OLED
    output logic R, G, B,

    //Collected Data
    output byte_t r, g, b
);
enum {IDLE, START[4], S[11], G[12], STOP[4]} state;

assign led_en = led_in;

byte_t wData, rData;
logic rdy, rcvd_ack;
logic S, P, write, read;
defparam prtcl.T_LOW = 200;
defparam prtcl.T_HIGH = 100;
defparam prtcl.T_SAMPLE = 80;
I2C prtcl(.clk(clk), .rst(rst), .S(S), .write(write), .read(read), .wData(wData), .rData(rData), .P(P), .sclk(sclk), .sda(sda), .rdy(rdy), .ack(rcvd_ack));

logic start_10ms, passed_10ms;
Timer #(.N(20)) _10ms(.clk(clk), .rst(rst), .start(start_10ms), .ceil(20'd1000000), .status(passed_10ms));

logic pDetect;
Pedge peDetect(.clk(clk), .rst(rst), .signal(detect), .pedge(pDetect));

logic[16:0] red, green, blue;
always_comb begin
    red = {buffer[3], buffer[2]};
    green = {buffer[5], buffer[4]};
    blue = {buffer[7], buffer[6]};
end

always_comb begin
    if(red > blue && red > green) begin 
        R = pulse;
        r = 8'hFF;
    end else begin
        R = 1'b0;
        r = 0;
    end 
    
    if(green > blue && green > red) begin 
        G = pulse;
        g = 8'hFF;
    end else begin
        G = 1'b0;
        g = 0;
    end 
    
    if(blue > red && blue > green)  begin 
        B = pulse;
        b = 8'hFF;
    end else begin
        B = 1'b0;
        b = 0;
    end 
end

logic pulse;
PWM wav_gen(.clk(clk), .rst(rst), .T_LOW(16'hFFFF), .T_HIGH(16'h0FFF), .pulse(pulse));

logic err;
logic[1:0] flag; 
logic[3:0] j;
logic[2:0] i;
byte_t buffer[8], send_data[6];
assign send_data = {8'h52, 8'hA0, 8'h03, 8'h52, 8'hB4, 8'h53};
always_ff @(posedge clk) begin
    if(rst) begin
        i <= 3'd0;
        j <= 3'b0;
        err <= 1'b0;
        flag <= 2'b0;

        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if(pDetect) state <= START0; 
            end

            START0: begin
                S <= 1'b1;
                
                state <= START1;
            end

            START1: begin
                state <= START2;
            end

            START2: begin
                state <= START3;
            end

            START3: begin
                if(rdy) begin
                    S <= 1'b0;

                    case(flag)
                        2'd0:
                            state <= S0;
                        
                        2'd1:
                            state <= S4;

                        2'd2:
                            state <= S8;
                        
                        default:
                            state <= S0;
                    endcase
                end
            end

            S0: begin
                if(i < 3) begin
                    wData <= send_data[i];
                    write <= 1'b1;

                    state <= G0;
                end else begin
                    write <= 1'b0;

                    state <= S2;
                end
            end

            G0: begin
               state <= G1;
            end

            G1: begin
                state <= G2;
            end

            G2: begin
                if(rdy) begin 
                    write <= 1'b0;
                    
                    state <= S1;
                end
            end

            S1: begin
                if(rcvd_ack) begin
                    i <= i + 1;

                    state <= S0;
                end else begin
                    err <= 1'b1;
                    i <= 1'b0;
                    flag <= 2'd0;

                    state <= STOP0;
                end
            end

            S2: begin
                start_10ms <= 1'b1;

                state <= S3;
            end

            S3: begin
                if(passed_10ms) begin
                    start_10ms <= 1'b0;
                    flag <= 2'd1;

                    state <= STOP0;
                end 
            end

            S4: begin
                if(i < 5) begin
                    wData <= send_data[i];
                    write <= 1'b1;

                    state <= G3;
                end else begin
                    write <= 1'b0;

                    state <= S6;
                end
            end

            G3: begin
                state <= G4;
            end

            G4: begin
                state <= G5;
            end

            G5: begin
                if(rdy) begin 
                    write <= 1'b0;
                    
                    state <= S5;
                end
            end

            S5: begin
                if(rcvd_ack) begin
                    i <= i + 1;

                    state <= S4;
                end else begin
                    err <= 1'b1;
                    i <= 3'd0;
                    flag <= 2'd0;

                    state <= STOP0;
                end
            end
            
            S6: begin
                start_10ms <= 1'b1;

                state <= S7;
            end

            S7: begin
                if(passed_10ms) begin
                    start_10ms <= 1'b0;
                    flag <= 2'd2;

                    state <= STOP0;
                end 
            end

            S8: begin
                flag <= 2'd0;
                wData <= send_data[i];
                write <= 1'b1;

                state <= G6;
            end

            G6: begin
                state <= G7;
            end

            G7: begin
                state <= G8;
            end

            G8: begin
                if(rdy) begin 
                    write <= 1'b0;
                    
                    state <= S9;
                end
            end

            S9: begin
                if(rcvd_ack) begin
                    i <= 3'b0;

                    state <= S10;
                end else begin
                    err <= 1'b1;
                    i <= 3'd0;
                    flag <= 2'd0;

                    state <= STOP0;
                end
            end

            S10: begin
                 if(j < 8) begin
                    read <= 1'b1;

                    state <= G9;
                end else begin
                    j <= 1'b0;
                    
                    state <= STOP0;
                end
            end

            G9: begin
                state <= G10;
            end

            G10: begin
                state <= G11;
            end

            G11: begin
                if(rdy) begin
                    buffer[j] <= rData;
                    read <= 1'b0;
                    j <= j + 1;

                    state <= S10;
                end
            end

            STOP0: begin
                P <= 1'b1;

                state <= STOP1;
            end

            STOP1: begin
                state <= STOP2;
            end

            STOP2: begin
               state <= STOP3;
            end

            STOP3: begin
                if(rdy) begin
                    P <= 1'b0;

                    if(err || |flag) begin
                        err <= 1'b0;
                        state <= START0;
                    end else
                        state <= IDLE;
                end
            end
            
            default: state <= IDLE;
           
        endcase
    end
end

endmodule
