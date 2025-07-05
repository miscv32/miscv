module proc(
    input clk,
    input rstL
);
    // instantiate RAM

    reg ram_rstL;
    reg ram_wenableL [DATA_WIDTH_BYTES-1:0];
    reg [7:0] ram_w [DATA_WIDTH_BYTES-1:0], ram_r [DATA_WIDTH_BYTES-1:0];
    reg [ADDR_WIDTH-1:0] ram_addr;

    mem ram (
        .clk(clk),
        .wenableL(ram_wenableL),
        .data_w(ram_w),
        .addr(ram_addr),
        .data_r(ram_r),
        .rstL(ram_rstL)
    );

    // instantiate registers
    
    reg regs_rstL;
    reg regs_wenableL [NUM_REGS-1:0];
    reg [WORD_SIZE-1:0] regs_w [NUM_REGS-1:0], regs_r [NUM_REGS-1:0];

    register_file regs (
        .clk(clk),
        .wenableL(regs_wenableL),
        .data_w(regs_w),
        .data_r(regs_r),
        .rstL(regs_rstL)
    );


endmodule