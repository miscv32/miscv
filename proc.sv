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

    register_file regfile (
        .clk(clk),
        .wenableL(regs_wenableL),
        .data_w(regs_w),
        .data_r(regs_r),
        .rstL(regs_rstL)
    );

    /* verilator lint_off UNUSEDSIGNAL */
    typedef enum { 
        FETCH = 0,
        EXECUTE = 1
    } e_state;
    reg [WORD_SIZE-1:0] pc;
    reg [6:0] opcode;
    reg  [31:0] instrBE;
    reg  [4:0] rd, rs1, rs2;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] immI, immS, immB, immU, immJ;
    reg [31:0] tst;
    e_state state;
    /* verilator lint_on UNUSEDSIGNAL */
    always_ff @(posedge clk or negedge rstL) begin
        if (~rstL) begin
            pc <= 0;
            regs_rstL <= 0;
            ram_rstL <= 0;
            state <= FETCH;
            regs_wenableL <= '{32{1}};
            regs_w <= '{32{0}};
            ram_wenableL <= '{4{1}};
            ram_w <= '{4{0}};
        end else begin
            regs_rstL <= 1;
            ram_rstL <= 1;
            if (state == FETCH) begin
                regs_wenableL <= '{32{1'b1}};
                ram_addr <= pc[ADDR_WIDTH-1:0];
                state <= EXECUTE;
            end else if (state == EXECUTE) begin
                if (opcode == 7'b0010011 && funct3 == 3'b000) begin
                    // addi
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] + immI;
                end
                pc <= pc + 4;
                state <= FETCH;
            end
        end
    end

    always_comb begin
        instrBE = {ram_r[3], ram_r[2], ram_r[1], ram_r[0]};
        opcode = instrBE[6:0];
        rd = instrBE[11:7];
        rs1 = instrBE[19:15];
        rs2 = instrBE[24:20];
        funct3 = instrBE[14:12];
        funct7 = instrBE[31:25];
        immI = {{20{instrBE[31]}}, instrBE[31:20]};
        immS = {{20{instrBE[31]}}, instrBE[31:25], instrBE[4:0]};
        immB = {{19{instrBE[31]}}, instrBE[31], instrBE[7], instrBE[30:25], instrBE[11:8], 1'b0};
        immU = {instrBE[31:12], {12{1'b0}}};
        immJ = {{11{instrBE[31]}}, instrBE[31], instrBE[19:12], instrBE[20], instrBE[30:21], 1'b0};
    end 
endmodule
