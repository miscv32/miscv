module regs_tb();
    reg[WORD_SIZE-1:0] data_w [NUM_REGS-1:0], data_r [NUM_REGS-1:0];
    reg clk, wenableL[NUM_REGS-1:0];
    reg [WORD_SIZE-1:0] dump [NUM_REGS-1:0];
    reg rstL;
    int i;

    initial begin : Initialise_Clock
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin : Initialise_Writing
        $readmemh("regs_tb.hex", dump, 0, 31);
        wenableL = '{32{0}};
        i = 0;
        rstL = 1;
    end


    always_ff @ (negedge clk) begin : Write_FSM
        if (i == 0) begin    
            for (int j = 0; j < NUM_REGS; j++) begin
                data_w[j] <= dump[j];
            end
            i <= i + 1;
        end else begin
            wenableL <= '{32{1}};
        end
    end

    always_ff @ (posedge clk) begin : Display_Regs
            $display("i: %h", i);
            $display("0: %h %h %h %h 4: %h %h %h %h 8: %h %h %h %h 12: %h %h %h %h 16: %h %h %h %h 20: %h %h %h %h 24: %h %h %h %h 28: %h %h %h %h", 
            data_r[0], data_r[1], data_r[2], data_r[3], 
            data_r[4], data_r[5], data_r[6] , data_r[7], 
            data_r[9], data_r[9], data_r[10], data_r[11], 
            data_r[12], data_r[13], data_r[14], data_r[15], 
            data_r[16], data_r[17], data_r[18], data_r[19],
            data_r[20], data_r[21], data_r[22], data_r[23],
            data_r[24], data_r[25], data_r[26], data_r[27],
            data_r[28], data_r[29], data_r[30], data_r[31]); 
    end

    register_file regs_uut ( 
        .clk(clk),
        .wenableL(wenableL),
        .data_w(data_w),
        .data_r(data_r),
        .rstL(rstL)
    );
endmodule

