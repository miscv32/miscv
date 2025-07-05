module register_file
(
    input clk,
    input rstL,
    input wenableL [NUM_REGS-1:0],
    input [WORD_SIZE-1:0] data_w [NUM_REGS-1:0],
    output reg [WORD_SIZE-1:0] data_r [NUM_REGS-1:0]
);
    reg [WORD_SIZE-1:0] regs [NUM_REGS-1:0];
    

    always_ff @(posedge clk) begin
        if (~rstL) begin
            for (int i = 0; i < NUM_REGS; i++) begin
                    regs[i] <= 0;
                    data_r[i] <= 0;
            end
        end else begin
            for (int i = 0; i < NUM_REGS; i++) begin
                if (~wenableL[i] && i != 0) begin
                        regs[i] <= data_w[i];
                end 
                data_r[i] <= (i == 0) ? 0 : 
                             (~wenableL[i]) ? data_w[i] : regs[i];
            end
        end
    end
endmodule
