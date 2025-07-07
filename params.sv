parameter MEM_SIZE_BYTES = 4096; // needs to be a power of 2
parameter DATA_WIDTH_BYTES = 4;
parameter ADDR_WIDTH = $clog2(MEM_SIZE_BYTES);
parameter WORD_SIZE = 32;
parameter NUM_REGS = 32;
