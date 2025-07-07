module mem_tb();
    reg[7:0] data_w [0:DATA_WIDTH_BYTES-1], data_r [0:DATA_WIDTH_BYTES-1];
    reg[ADDR_WIDTH-1:0] addr;
    reg clk, wenableL[0:DATA_WIDTH_BYTES-1];
    reg [7:0] dump [0:MEM_SIZE_BYTES-1];
    reg rstL;
    int i;

    initial begin : Initialise_Clock
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin : Initialise_Writing
        $readmemh("mem_tb.hex", dump, 0, 9);
        wenableL = {0,0,0,0};
        addr = 0;
        i = 0;
        rstL = 1;
    end


    always_ff @ (negedge clk) begin : Write_FSM
        if (i + 3 < 4096) begin    
            data_w <= {dump[i], dump[i+1], dump[i+2], dump[i+3]};
            addr <= i[ADDR_WIDTH-1:0];
            i <= i + 4;
        end else begin
            wenableL <= {1,1,1,1};
        end
    end

    always_ff @ (posedge clk) begin : Display_Memory
            $display("i: %h", i);
            $display("%h %h %h %h", data_r[0], data_r[1], data_r[2], data_r[3]); 
    end

    mem mem_uut ( 
        .clk(clk),
        .wenableL(wenableL),
        .data_w(data_w),
        .addr(addr),
        .data_r(data_r),
        .rstL(rstL)
    );
endmodule

