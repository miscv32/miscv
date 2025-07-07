module driver();
    reg clk;
    reg rstL = 1;

    initial begin
        #5
        rstL = 0;
        #5
        rstL = 1;
        
        $readmemh("add.hex", proc_uut.ram.mem, 0, 3);

        clk = 0;
        forever begin
            #5 
            clk = ~clk;
            $display("%h %h %h %h", proc_uut.ram.mem[0],proc_uut.ram.mem[1],proc_uut.ram.mem[2],proc_uut.ram.mem[3]);
            $display ("%h %h %h %h", proc_uut.ram_r[0],proc_uut.ram_r[1],proc_uut.ram_r[2],proc_uut.ram_r[3]);
            $display("0: %h %h %h %h 4: %h %h %h %h 8: %h %h %h %h 12: %h %h %h %h 16: %h %h %h %h 20: %h %h %h %h 24: %h %h %h %h 28: %h %h %h %h", 
            proc_uut.regfile.regs[0], proc_uut.regfile.regs[1], proc_uut.regfile.regs[2], proc_uut.regfile.regs[3], 
            proc_uut.regfile.regs[4], proc_uut.regfile.regs[5], proc_uut.regfile.regs[6] , proc_uut.regfile.regs[7], 
            proc_uut.regfile.regs[8], proc_uut.regfile.regs[9], proc_uut.regfile.regs[10], proc_uut.regfile.regs[11], 
            proc_uut.regfile.regs[12], proc_uut.regfile.regs[13], proc_uut.regfile.regs[14], proc_uut.regfile.regs[15], 
            proc_uut.regfile.regs[16], proc_uut.regfile.regs[17], proc_uut.regfile.regs[18], proc_uut.regfile.regs[19],
            proc_uut.regfile.regs[20], proc_uut.regfile.regs[21], proc_uut.regfile.regs[22], proc_uut.regfile.regs[23],
            proc_uut.regfile.regs[24], proc_uut.regfile.regs[25], proc_uut.regfile.regs[26], proc_uut.regfile.regs[27],
            proc_uut.regfile.regs[28], proc_uut.regfile.regs[29], proc_uut.regfile.regs[30], proc_uut.regfile.regs[31]); 
            $display("---------------------");
        end
    end


    proc proc_uut (
        .clk(clk),
        .rstL(rstL)
    );

endmodule
