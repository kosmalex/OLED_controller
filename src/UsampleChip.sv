module UsampleChip
(
    input logic[2:0][3:0] In,
    output logic[2:0][7:0] Out
);

generate;
    genvar i;
    for(i = 0; i < 3; i++) begin : genUpSampling
        Usample mdl_(.In(In[i]), .Out(Out[i]));
    end
endgenerate

endmodule