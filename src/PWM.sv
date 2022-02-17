import MyPkg::byte2_t;

module PWM
(
    input logic clk, rst,
    input byte2_t T_LOW, T_HIGH,
    output logic pulse
);

byte2_t t_low, t_high;

always_ff @(posedge clk) begin
    if(rst) begin
        pulse <= 1'b1;
        t_low <= 0;
        t_high <= 0;
    end else begin 
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
    end
end
endmodule
