import MyPkg::byte_t;

module I2C
#(
    T_LOW = 50, // *10 ns
    T_HIGH = 50, // *10 ns
    T_SAMPLE = 25 // *10 ns time since period started, at which new data bit is sampled during sclk's low state
                  // !!!!!!! T_SAMPLE < T_LOW !!!!!! 
)
(
    input logic clk, rst, 
    input logic S, P,
    input logic write, read,
    input byte_t wData,

    inout logic sda,

    output logic sclk,
    output byte_t rData,

    //state outputs
    output logic rdy,
    output logic ack
);
enum logic[2:0] {S_IDLE, S_WAIT, WRITE[2], READ[2], P_WAIT, BUS_FREE} state;

logic[2:0] sel_sclk;
always_comb begin
    case(sel_sclk)
        3'b001: sclk = pulse;
        3'b010: sclk = 1'b0;
        3'b100: sclk = 1'b1;

        default: sclk = 1'b0;
    endcase
end

logic[$clog2(T_LOW) - 1:0] t_low;
logic[$clog2(T_HIGH) - 1:0] t_high;
logic pulse;
always_ff @(posedge clk) begin : gen_wav
    if(rst) begin
        pulse <= 1'b0;
        t_low <= 0;
        t_high <= 0;
    end else if(sel_sclk == 1) begin
        if(t_low == T_LOW - 1) begin
            t_low <= 0;
            pulse <= ~pulse;
        end else if(t_high == T_HIGH - 1) begin
            t_high <= 0;
            pulse <= ~pulse;
        end else begin
            if(pulse)
                t_high <= t_high + 1;
            else
                t_low <= t_low + 1;
        end
    end else begin
        t_low <= 0;
        t_high <= 0;
    end
end

logic pWrite;
PosEdge posedge_write(.clk(clk), .rst(rst), .signal(write), .pedge(pWrite));

logic pRead;
PosEdge posedge_read(.clk(clk), .rst(rst), .signal(read), .pedge(pRead));

logic is_out;
logic sda_in, sda_out;
assign sda = is_out ? sda_out : 1'bz;
assign sda_in = sda;

logic hello;
PosEdge pHello(.clk(clk), .rst(rst), .signal(S), .pedge(hello));

logic goodbye;
PosEdge pGoodbye(.clk(clk), .rst(rst), .signal(P), .pedge(goodbye));

logic start_790ns, passed_790ns;
Timer #(.N(7)) _790ns(.clk(clk), .rst(rst), .start(start_790ns), .ceil(7'd79), .status(passed_790ns));

logic start_1p3us, passed_1p3us;
Timer #(.N(8)) _1300ns(.clk(clk), .rst(rst), .start(start_1p3us), .ceil(8'd130), .status(passed_1p3us));

logic rw;
logic[3:0] nPulse;
always_ff @(posedge clk) begin
    if(rst) begin
        sda_out <= 1'b1;
        sel_sclk <= 3'd4; // slck <= 1'b1
        is_out <= 1'b1;
        nPulse <= 1'b0;
        rdy <= 1'b0;
        
        rw <= 1'b0;
        
        state <= S_IDLE;
    end else begin
        case(state)
            S_IDLE: begin
                if(hello) begin
                    sda_out <= 1'b0;
                    start_790ns <= 1'b1;
                    rdy <= 1'b0;

                    state <= S_WAIT;
                end
            end

            S_WAIT: begin
                if(passed_790ns) begin
                    start_790ns <= 1'b0;
                    sel_sclk <= 3'd2;
                    rdy <= 1'b1;
    
                    state <= WRITE0; 
                end
            end

            //<Here communication occures>
            WRITE0: begin
                if(pWrite) begin
                    sel_sclk <= 3'd1;
                    rdy <= 1'b0;
                    ack <= 1'b0;

                    state <= WRITE1;
                end else if(goodbye) begin
                    rw <= 1'b0;
                    sel_sclk <= 3'd4;
                    start_790ns <= 1'b1;
                    rdy <= 1'b0;

                    state <= P_WAIT;
                end
            end

            WRITE1: begin
                if(nPulse < 10) begin
                    if(t_low == T_SAMPLE) begin
                        if(nPulse < 8)
                            sda_out <= wData[7 - nPulse];
                        
                        if(nPulse == 8)
                            is_out <= 1'b0;

                        nPulse <= nPulse + 1'b1;
                    end

                    if(nPulse == 9 && t_high == 80) begin
                        if(~sda) 
                            ack <= 1'b1;
                        else
                            ack <= 1'b0;
                    end
                end else begin
                    sda_out <= 1'b0;
                    sel_sclk <= 3'd2;
                    is_out <= 1'b1;
                    nPulse <= 0;
                    rdy <= 1'b1;

                    if(!rw) begin
                        rw <= 1'b1;
                        if(wData[0])
                            state <= READ0;
                        else
                            state <= WRITE0;
                    end else 
                        state <= WRITE0;
                end
            end

            READ0: begin
                if(pRead) begin
                    sel_sclk <= 3'd1;
                    is_out <= 1'b0;
                    rdy <= 1'b0;

                    state <= READ1;
                end else if(goodbye) begin
                    rw <= 1'b0;
                    sel_sclk <= 3'd4;
                    start_790ns <= 1'b1;
                    rdy <= 1'b0;

                    state <= P_WAIT;
                end
            end

            READ1: begin
                if(nPulse < 10) begin
                    if(t_low == T_SAMPLE) begin
                        if(nPulse < 8)
                            rData[7 - nPulse] <= sda_in;
                        
                        if(nPulse == 8) begin
                            sda_out <= 1'b0;
                            is_out <= 1'b1;
                        end

                        nPulse <= nPulse + 1'b1;
                    end
                end else begin
                    sel_sclk <= 3'd2;
                    is_out <= 1'b1;
                    nPulse <= 0;
                    rdy <= 1'b1;

                    state <= READ0;
                end
            end
            //<Here communication occures/>

            P_WAIT: begin
                if(passed_790ns) begin
                    sda_out <= 1'b1;
                    start_790ns <= 1'b0;
                    start_1p3us <= 1'b1;

                    state <= BUS_FREE; 
                end
            end

            BUS_FREE: begin
                if(passed_1p3us) begin
                    start_1p3us <= 1'b0;
                    rdy <= 1'b1;

                    state <= S_IDLE;
                end
            end

            default: state <= S_IDLE;
        endcase
    end   
end
endmodule
