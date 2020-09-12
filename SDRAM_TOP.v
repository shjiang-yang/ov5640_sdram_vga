// =======================================================
// 
// designer:                yang shjiang
// date:                    2020-07-29
// description:             the sdram top module
//                          async_FIFO should be replaced FIFO IP
// 
// =======================================================

module SDRAM_TOP(
    // system signals
    input                   sysclk_100M     ,
    input                   rst_n           ,
    // sdram interface
    output                  CLK             ,
    output                  CKE             ,
    output                  cs_n            ,
    output                  ras_n           ,
    output                  cas_n           ,
    output                  we_n            ,
    output      [12:0]      addr            ,
    output      [ 1:0]      ba              ,
    output      [ 1:0]      dqm             ,
    inout       [15:0]      dq              ,
    // write fifo interface
    input                   w_clk           ,
    input                   wen             ,
    input       [15:0]      din             ,
    // read fifo interface
    input                   r_clk           ,
    input                   ren             ,
	 output                  empty_r         ,
    output      [15:0]      dout            
);

// ------------- define params and signals -----------------
wire                write_data_vld  ;
wire                write_trig      ;
wire    [15:0]      w_dq            ;
wire    [ 9:0]      w_data_count    ;

wire                read_trig       ;
wire                read_data_vld   ;
wire    [15:0]      r_dq            ;
wire                write_end       ;
wire    [ 9:0]       r_data_count    ;

// ---------------- main code ----------------------------
SDRAM_arbit SDRAM_arbit_inst(
    // system signals
    .sysclk_100M                (   sysclk_100M     )   ,
    .rst_n                      (   rst_n           )   ,
    // sdram interface
    .CLK                        (   CLK             )   ,
    .CKE                        (   CKE             )   ,
    .cs_n                       (   cs_n            )   ,
    .ras_n                      (   ras_n           )   ,
    .cas_n                      (   cas_n           )   ,
    .we_n                       (   we_n            )   ,
    .addr                       (   addr            )   ,
    .ba                         (   ba              )   ,
    .dqm                        (   dqm             )   ,
    .dq                         (   dq              )   ,
    // write fifo
    .write_trig                 (   write_trig      )   ,  // 
    .write_data_vld             (   write_data_vld  )   ,  // w_fifo ren
    .w_dq                       (   w_dq            )   ,
    // read fifo
    .read_trig                  (   read_trig       )   ,
    .read_data_vld              (   read_data_vld   )   ,  // r_fifo_wen
    .r_dq                       (   r_dq            )   ,
    .write_end                  (   write_end       )
);


// ---------------------- write fifo ------------------------
assign write_trig = (w_data_count > 512) ? 1'b1 : 1'b0 ;
assign read_trig = (r_data_count < 512  && write_end == 1'b1) ? 1'b1 : 1'b0  ;
/* 
async_FIFO write_fifo(
    // system signal 
    .rst_n                      (   rst_n           )  ,
    // write interface
    .w_clk                      (   w_clk           )  ,
    .wen                        (   wen             )  ,
    .din                        (   din             )  ,
    .full                       (   full_w          )  ,  // debug
    // read interface
    .r_clk                      (   CLK             )  ,
    .ren                        (   write_data_vld  )  ,
    .dout                       (   w_dq            )  ,
    .empty                      (   empty_w         )  ,  // debug
    // data num
    .data_count                 (   w_data_count    )
);


// ------------------------ read fifo --------------------------
async_FIFO read_fifo(
    // system signal 
    .rst_n                      (   rst_n           )  ,
    // write interface
    .w_clk                      (   CLK             )  ,
    .wen                        (   read_data_vld   )  ,
    .din                        (   r_dq            )  ,
    .full                       (   full_r          )  ,  // debug
    // read interface
    .r_clk                      (   r_clk           )  ,
    .ren                        (   ren             )  ,
    .dout                       (   dout            )  ,
    .empty                      (   empty_r         )  ,  // debug
    // data num
    .data_count                 (   r_data_count    )
); */

// -------------------- fifo IP

fifo write_fifo(
    // system signal 
    .rst                        (   ~rst_n          )  ,
    // write interface
    .wr_clk                     (   w_clk           )  ,
    .wr_en                      (   wen             )  ,
    .din                        (   din             )  ,
    .full                       (   full_w          )  ,  // debug
    // read interface
    .rd_clk                     (   CLK             )  ,
    .rd_en                      (   write_data_vld  )  ,
    .dout                       (   w_dq            )  ,
    .empty                      (   empty_w         )  ,  // debug
    // data num
    .wr_data_count              (   w_data_count    )
);


// ------------------------ read fifo --------------------------
fifo read_fifo(
    // system signal 
    .rst                        (   ~rst_n          )  ,
    // write interface
    .wr_clk                     (   CLK             )  ,
    .wr_en                      (   read_data_vld   )  ,  // read_data_vld
    .din                        (   r_dq            )  ,  // r_dq
    .full                       (   full_r          )  ,  // debug
    // read interface
    .rd_clk                     (   r_clk           )  ,
    .rd_en                      (   ren             )  ,
    .dout                       (   dout            )  ,
    .empty                      (   empty_r         )  ,  // debug
    // data num
    .rd_data_count              (   r_data_count    )
);


endmodule