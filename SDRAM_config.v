// ==================================================
// 
// designer:            yang shjiang
// date:                2020-08-11
// description:         SDRAM config file
// 
// ==================================================


// -------------- async FIFO ------------------------
// POINTER_WIDTH is $clog2(FIFO_DEPTH)+1
`define FIFO_WIDTH      16
`define FIFO_DEPTH      512
`define POINTER_WIDTH   10 


// -------------- sdram config -----------------------
// capacity per bank; the ending cell addr+1 
`define     ROW_ADDR_END        1440  
`define     COL_ADDR_END        512 

// bank (one-hot), can be {PINGPONG_BUFFER, BANK_INCR, BANK_ONE}
// for PINGPONG_BUFFER, assume that read port faster than write port
`define     PINGPONG_BUFFER
