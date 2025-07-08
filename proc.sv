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
        EXECUTE_0 = 1,
        EXECUTE_1 = 2
    } e_state;
    reg [WORD_SIZE-1:0] pc;
    reg [6:0] opcode;
    reg  [31:0] instrBE;
    reg  [4:0] rd, rs1, rs2;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg signed [31:0] immI, immS, immB, immU, immJ, immShift;
    reg [31:0] rs1_signed_offset, rs1_unsigned_offset;
    e_state state;
    reg is_addi;
    reg is_add;
    reg is_sub;
    reg is_xor;
    reg is_or;
    reg is_and;
    reg is_sll;
    reg is_srl;
    reg is_sra;
    reg is_slt;
    reg is_sltu;
    reg is_xori;
    reg is_ori;
    reg is_andi;
    reg is_slli;
    reg is_srli;
    reg is_srai;
    reg is_slti;
    reg is_sltiu;
    reg is_lb;
    reg is_lh;
    reg is_lw;
    reg is_lbu;
    reg is_lhu;
    reg is_sb;
    reg is_sh;
    reg is_sw;
    reg is_beq;
    reg is_bne;
    reg is_blt;
    reg is_bge;
    reg is_bltu;
    reg is_bgeu;
    reg is_jal;
    reg is_jalr;
    reg is_lui;
    reg is_auipc;
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
                state <= EXECUTE_0;
            end else if (state == EXECUTE_0) begin // TODO implement ecall and ebreak - for 
            // TODO check sign extension bugs. I think a lot of the places where $unsigned(immI) is used are wrong because already sign extended it.
                if (is_addi) begin : ADDI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] + immI;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_add) begin : ADD
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] + regs_r[rs2];
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_sub) begin : SUB
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] - regs_r[rs2];
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_xor) begin : XOR
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] ^ regs_r[rs2];
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_or) begin : OR
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] | regs_r[rs2];
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_and) begin : AND
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] & regs_r[rs2];
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_sll) begin : SLL
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] << (regs_r[rs2] & 32'h1f);
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_srl) begin : SRL
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] >> (regs_r[rs2] & 32'h1f);
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_sra) begin : SRA
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] >>> (regs_r[rs2] & 32'h1f);
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_slt) begin : SLT
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {{31{1'b0}}, regs_r[rs1] < regs_r[rs2]};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_sltu) begin : SLTU
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {{31{1'b0}},$unsigned(regs_r[rs1]) < $unsigned(regs_r[rs2])};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_xori) begin : XORI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] ^ immI;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_ori) begin : ORI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] | immI;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_andi) begin : ANDI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] & immI;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_slli) begin : SLLI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] << immShift;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_srli) begin : SRLI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] >> immShift;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_srai) begin : SRAI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= regs_r[rs1] >>> immShift;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_slti) begin : SLTI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {{31{1'b0}}, regs_r[rs1] < immI};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_sltiu) begin : SLTIU
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {{31{1'b0}}, {$unsigned(regs_r[rs1]) < $unsigned(immI)}};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_lb) begin : LB
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    state <= EXECUTE_1;
                end else if (is_lh) begin : LH
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    state <= EXECUTE_1;
                end else if (is_lw) begin : LW
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    state <= EXECUTE_1;
                end else if (is_lbu) begin : LBU
                    ram_addr <= rs1_unsigned_offset[ADDR_WIDTH-1:0];
                    state <= EXECUTE_1;
                end else if (is_lhu) begin : LHU
                    ram_addr <= rs1_unsigned_offset[ADDR_WIDTH-1:0];
                    state <= EXECUTE_1;
                end else if (is_sb) begin : SB
                    ram_wenableL <= '{0,1,1,1};
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    ram_w[0] <= regs_r[rs2][7:0];
                    state <= FETCH;
                end else if (is_sh) begin : SH
                    ram_wenableL <= '{0,0,1,1};
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    ram_w[0] <= regs_r[rs2][7:0];
                    ram_w[1] <= regs_r[rs2][15:8];
                    state <= FETCH;
                end else if (is_sw) begin : SW
                    ram_wenableL <= '{4{0}};
                    ram_addr <= rs1_signed_offset[ADDR_WIDTH-1:0];
                    ram_w[0] <= regs_r[rs2][7:0];
                    ram_w[1] <= regs_r[rs2][15:8];
                    ram_w[2] <= regs_r[rs2][23:16];
                    ram_w[3] <= regs_r[rs2][31:24];
                    state <= FETCH;
                end else if (is_beq) begin : BEQ
                    if (rs1 == rs2) pc <= pc + immB;
                    state <= FETCH;
                end else if (is_bne) begin : BNE
                    if (rs1 != rs2) pc <= pc + immB;
                    state <= FETCH;
                end else if (is_blt) begin : BLT
                    if (rs1 < rs2) pc <= pc + immB;
                    state <= FETCH;
                end else if (is_bge) begin : BGT
                    if (rs1 >= rs2) pc <= pc + immB; 
                    state <= FETCH;
                end else if (is_bltu) begin : BLTU
                    if ($unsigned(rs1) < $unsigned(rs2)) pc <= pc + immB;
                    state <= FETCH;
                end else if (is_bgeu) begin : BGEU
                    if ($unsigned(rs1) >= $unsigned(rs2)) pc <= pc + immB;
                    state <= FETCH;
                end else if (is_jal) begin : JAL
                    regs_wenableL[rd] <= 0; 
                    regs_w[rd] <= pc + 4;
                    pc <= pc + immJ;
                    state <= FETCH;
                end else if (is_jalr) begin : JALR
                    regs_wenableL[rd] <= 0; 
                    regs_w[rd] <= pc + 4;
                    pc <= regs_r[rs1] + immJ;
                    state <= FETCH;
                end else if (is_lui) begin : LUI
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= immU;
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_auipc) begin : AUIPC
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= pc + immU;
                    pc <= pc + 4;
                    state <= FETCH;
                end else begin
                    // Treat everything else as a NOP
                    pc <= pc + 4;
                    state <= FETCH;
                end
            end else if (state == EXECUTE_1) begin
                if (is_lb | is_lbu) begin : LB_LBU_LOAD_REG
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {24'b0, ram_r[0]};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_lh | is_lhu) begin : LH_LHU_LOAD_REG
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {16'b0, ram_r[0], ram_r[1]};
                    pc <= pc + 4;
                    state <= FETCH;
                end else if (is_lw) begin : LW_LOAD_REG
                    regs_wenableL[rd] <= 0;
                    regs_w[rd] <= {ram_r[0], ram_r[1], ram_r[2], ram_r[3]};
                    pc <= pc + 4;
                    state <= FETCH;
                end
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
        immI = {{20{instrBE[31]}}, instrBE[31:20]}; // see sign extension todo
        immS = {{20{instrBE[31]}}, instrBE[31:25], instrBE[4:0]};
        immB = {{19{instrBE[31]}}, instrBE[31], instrBE[7], instrBE[30:25], instrBE[11:8], 1'b0};
        immU = {instrBE[31:12], {12{1'b0}}};
        immJ = {{11{instrBE[31]}}, instrBE[31], instrBE[19:12], instrBE[20], instrBE[30:21], 1'b0};
        immShift = {{27{1'b0}}, immI[4:0]};
        is_addi = opcode == 7'b0010011 && funct3 == 3'b000;
        is_add = opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'h00;
        is_sub = opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'h20;
        is_xor = opcode == 7'b0110011 && funct3 == 3'h4 && funct7 == 7'h00;
        is_or  = opcode == 7'b0110011 && funct3 == 3'h6 && funct7 == 7'h00;
        is_and = opcode == 7'b0110011 && funct3 == 3'h7 && funct7 == 7'h00;
        is_sll = opcode == 7'b0110011 && funct3 == 3'h1 && funct7 == 7'h00;
        is_srl = opcode == 7'b0110011 && funct3 == 3'h5 && funct7 == 7'h00;
        is_sra = opcode == 7'b0110011 && funct3 == 3'h5 && funct7 == 7'h20;
        is_slt = opcode == 7'b0110011 && funct3 == 3'h2 && funct7 == 7'h00;
        is_sltu = opcode == 7'b0110011 && funct3 == 3'h3 && funct7 == 7'h00;
        is_xori = opcode == 7'b0010011 && funct3 == 3'h4;
        is_ori = opcode == 7'b0010011 && funct3 == 3'h6;
        is_andi = opcode == 7'b0010011 && funct3 == 3'h7;
        is_slli = opcode == 7'b0010011 && funct3 == 3'h1 && funct7 == 7'h00;
        is_srli = opcode == 7'b0010011 && funct3 == 3'h5 && funct7 == 7'h00;
        is_srai = opcode == 7'b0010011 && funct3 == 3'h1 && funct7 == 7'h20;
        is_slti = opcode == 7'b0010011 && funct3 == 3'h2;
        is_sltiu = opcode == 7'b0010011 && funct3 == 3'h3;
        is_lb = opcode == 7'b0000011 && funct3 == 3'h0;
        is_lh = opcode == 7'b0000011 && funct3 == 3'h1;
        is_lw = opcode == 7'b0000011 && funct3 == 3'h2;
        is_lbu = opcode == 7'b0000011 && funct3 == 3'h4;
        is_lhu = opcode == 7'b0000011 && funct3 == 3'h5;
        is_sb = opcode == 7'b0100011 && funct3 == 3'h0;
        is_sh = opcode == 7'b0100011 && funct3 == 3'h1;
        is_sw = opcode == 7'b0100011 && funct3 == 3'h2;
        is_beq = opcode == 7'b1100011 && funct3 == 3'h0;
        is_bne = opcode == 7'b1100011 && funct3 == 3'h1;
        is_blt = opcode == 7'b1100011 && funct3 == 3'h4;
        is_bge = opcode == 7'b1100011 && funct3 == 3'h5;
        is_bltu = opcode == 7'b1100011 && funct3 == 3'h6;
        is_bgeu = opcode == 7'b1100011 && funct3 == 3'h7;
        is_jal = opcode == 7'b1101111 && funct3 != 3'h0;
        is_jalr = opcode == 7'b110011 && funct3 == 3'h0;
        is_lui = opcode == 7'b0110111;
        is_auipc = opcode == 7'b0010111;
        rs1_signed_offset = regs_r[rs1] + $signed(immI); // see sign extension todo
        rs1_unsigned_offset = regs_r[rs1] + $unsigned(immI); // see sign extension todo
    end 
endmodule
