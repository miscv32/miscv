module mem
(
    input clk,
    input rstL,
    input wenableL [DATA_WIDTH_BYTES-1:0],
    input [7:0] data_w [DATA_WIDTH_BYTES-1:0],
    input [ADDR_WIDTH-1:0] addr,
    output reg [7:0] data_r [DATA_WIDTH_BYTES-1:0]
);
    reg [7:0] mem [MEM_SIZE_BYTES-1:0];
    

    always_ff @(posedge clk) begin
        if (~rstL) begin
            for (int i = 0; i < DATA_WIDTH_BYTES; i++) begin
                data_r[i] <= 0;
            end 
        end else begin
            for (int i = 0; i < DATA_WIDTH_BYTES; i++) begin
                if (~wenableL[i]) begin
                    mem[addr + i[ADDR_WIDTH-1:0]] <= data_w[i];
                end 
                data_r[i] <= (~wenableL[i]) ? 0 : mem[addr + i[ADDR_WIDTH-1:0]];
            end
        end
    end
endmodule
