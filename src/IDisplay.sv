import MyPkg::*;

module IDisplay
(
    input logic clk, rst,
    input logic on_off, exec,
    input logic[3:0] cmd,
    input byte_t[10:0] IR,
    
    output logic rdy,
    output logic sclk, mosi, cs, 
    output logic vcc_en, pmod_en, dc, res
);

enum logic[4:0] {IDLE, ON[10], GFX[3], DELAY[6], OFF[3]} state;

//Initialize display data
logic[5:0] i;
byte_t data_to_send[45];
assign data_to_send = { 8'hFD, 8'h12, 8'hAE, 8'hA0, 8'h72, 8'hA1, 8'h00, 8'hA2, 8'h00, 8'hA4, 8'hA8, 8'h3F, 8'hAD, 8'h8E, 8'hB0, 8'h0B, 
                        8'hB1, 8'h31, 8'hB3, 8'hF0, 8'h8A, 8'h64, 8'h8B, 8'h78, 8'h8C, 8'h64, 8'hBB, 8'h3A, 8'hBE, 8'h3E, 8'h87, 8'h06, 
                        8'h81, 8'h91, 8'h82, 8'h50, 8'h83, 8'h7D, 8'h2E, 8'h25, 8'h0, 8'h0, 8'h3F, 8'h1F, 8'hAF };

logic start, stop, write, done;
byte_t data;
SPI protocol(.clk(clk), .rst(rst), .sclk(sclk), .mosi(mosi), .cs(cs), .start(start), .stop(stop), .write(write), .data(data), .done(done));

//Delays
logic passed_25ms, strt_25ms;
Timer #(.N(22)) _25ms(.clk(clk), .rst(rst), .start(strt_25ms), .ceil(22'd2499999), .status(passed_25ms));

logic strt_4us, passed_4us;
Timer #(.N(9)) _4us(.clk(clk), .rst(rst), .start(strt_4us), .ceil(9'd399), .status(passed_4us));

logic passed_100ms, strt_100ms;
Timer #(.N(24)) _100ms(.clk(clk), .rst(rst), .start(strt_100ms), .ceil(24'd9999999), .status(passed_100ms));

logic strt_400ms, rst_400ms, passed_400ms;
Timer #(.N(26)) _400ms(.clk(clk), .rst(rst), .start(strt_400ms), .ceil(26'd39999999), .status(passed_400ms));

logic[3:0] j; //index 
logic[3:0] nBytes; //Bytes to send (max 11)
always_ff @(posedge clk) begin
    if(rst) begin
        {i, j} <= 2'b0;
        nBytes <= 2'd2;
        rdy <= 1'b0;

        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                if(on_off) begin
                    state <= ON0;
                end    
            end

            ON0: begin
                {dc, res, vcc_en, pmod_en} <= 4'b0101;
                strt_25ms <= 1'b1;

                state <= ON1;
            end

            ON1: begin
                if(passed_25ms) begin
                // if(1'b1) begin
                    res <= 1'b0;
                    strt_25ms <= 1'b0; 
                    strt_4us <= 1'b1;

                    state <= ON2;     
                end
            end

            ON2: begin
                if(passed_4us) begin
                    strt_4us <= 1'b0;
                    start <= 1'b1;
                    res <= 1'b1;
                        
                    state <= ON3;     
                end
            end
            
            ON3: begin
                if(done) begin
                    start <= 1'b0;

                    state <= ON4;
                end    
            end

            ON4: begin
                if(i < 44) begin
                    write <= 1'b1;
                    data <= data_to_send[i];
                    
                    state <= DELAY0;
                end else
                    state <= ON6;
            end

            DELAY0: state <= DELAY1;
            DELAY1: state <= ON5;

            ON5: begin
                write <= 1'b0;

                if(done) begin
                    i <= i + 1;

                    state <= ON4;                    
                end
            end
            
            ON6: begin
                vcc_en <= 1'b1;
                strt_25ms <= 1'b1;
                write <= 1'b0;

                state <= ON7;
            end

            ON7: begin
                if(passed_25ms) begin
                // if(1'b1) begin
                    strt_25ms <= 1'b0;
                    write <= 1'b1;
                    data <= data_to_send[i];
                    
                    state <= DELAY2;
                end
            end
            
            DELAY2: state <= DELAY3;
            DELAY3: state <= ON8;    
            
            ON8: begin
                if(done) begin
                    strt_100ms <= 1'b1;
                    i <= 1'b0;
                    write <= 1'b0;

                    state <= ON9;
                end
            end

            ON9: begin
                if(passed_100ms) begin
                // if(1'b1) begin
                    strt_100ms <= 1'b0;

                    state <= GFX0;                    
                end
            end

           //<User action section>
            GFX0: begin
                rdy <= 1'b1;

                if(!on_off) begin
                    rdy <= 1'b0;

                    state <= OFF0;
                end

                if(exec) begin
                    rdy <= 1'b0;
                    
                    case(cmd)
                        3'd0: nBytes <= 2'd2;
                        3'd1: nBytes <= 3'd5;
                        3'd2: nBytes <= 3'd7;
                        3'd3: nBytes <= 4'd8;
                        3'd4: nBytes <= 4'd11;
                        default: nBytes <= 2'd2;
                    endcase

                    state <= GFX1;
                end
            end

            GFX1: begin
                if(j < nBytes) begin
                    write <= 1'b1;
                    data <= IR[10 - j];

                    state <= DELAY4;
                end else begin
                    j <= 0;
                    state <= GFX0; 
                end
            end

            DELAY4: state <= DELAY5;
            DELAY5: state <= GFX2;

            GFX2: begin
                write <= 1'b0;

                if(done) begin
                    j <= j + 1;

                    state <= GFX1;
                end
            end
           //<User action section/>

            OFF0: begin
                write <= 1'b1;
                data <= 8'hAE;

                if(done) begin
                    stop <= 1'b1; 
                    
                    state <= OFF1;
                end
            end

            OFF1: begin
                {vcc_en, stop} <= 2'b0;
                strt_400ms <= 1'b1;

                state <= OFF2; 
            end

            OFF2: begin
                if(passed_400ms) begin
                    strt_400ms <= 1'b0;
                    pmod_en <= 1'b0;

                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule