module mem
(
    input clk,
    input rst_bar,
    input w_bar [DATA_WIDTH_BYTES-1:0],
    input [7:0] data_w [DATA_WIDTH_BYTES-1:0],
    input [ADDR_WIDTH-1:0] addr,
    output reg [7:0] data_r [DATA_WIDTH_BYTES-1:0]
);
    reg [7:0] mem [MEM_SIZE_BYTES-1:0];
    

    always_ff @(posedge clk) begin
        if (~rst_bar) begin
            for (int i = 0; i < MEM_SIZE_BYTES; i++) begin
                    mem[i] <= 0;
            end
            for (int i = 0; i < DATA_WIDTH_BYTES; i++) begin
                data_r[i] <= 0;
            end 
        end else begin
            for (int i = 0; i < DATA_WIDTH_BYTES; i++) begin
                if (~w_bar[i]) begin
                    mem[addr + i[ADDR_WIDTH-1:0]] <= data_w[i];
                    data_r[i] <= data_w[i];
                end else begin
                    data_r[i] <= mem[addr + i[ADDR_WIDTH-1:0]];
                end
            end
        end
    end
endmodule
