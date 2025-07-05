parameter MEM_SIZE_BYTES = 4096; // needs to be a power of 2
parameter DATA_WIDTH_BYTES = 4;
parameter ADDR_WIDTH = $clog2(MEM_SIZE_BYTES);

module driver();
    reg[7:0] data_w [DATA_WIDTH_BYTES-1:0], data_r [DATA_WIDTH_BYTES-1:0];
    reg[ADDR_WIDTH-1:0] addr;
    reg clk, w_bar[DATA_WIDTH_BYTES-1:0];
    reg [7:0] dump [4095:0];
    reg rst_bar;
    int i;

    initial begin : Initialise_Clock
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin : Initialise_Processor
        $readmemh("file.hex", dump, 0, 9);
        w_bar = {0,0,0,0};
        addr = 0;
        i = 0;
        rst_bar = 1;
    end


    always_ff @ (negedge clk) begin : Write_FSM
        if (i + 3 < 4096) begin    
            data_w <= {dump[i+3], dump[i+2], dump[i+1], dump[i]};
            addr <= i[ADDR_WIDTH-1:0];
            i <= i + 4;
        end else begin
            w_bar <= {1,1,1,1};
        end
    end
    

    always_ff @ (posedge clk) begin : Display_Memory
            $display("i: %h", i);
            $display("%h %h %h %h", data_r[0], data_r[1], data_r[2], data_r[3]); 
    end

    mem mem_uut ( 
        .clk(clk),
        .w_bar(w_bar),
        .data_w(data_w),
        .addr(addr),
        .data_r(data_r),
        .rst_bar(rst_bar)
    );
endmodule

