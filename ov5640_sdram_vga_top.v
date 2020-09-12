// =========================================================
// 
// designer:               yang shjiang
// date:                   2020-09-09
// description:            the ov5640_sdram_vga_top module
// 
// =========================================================
`timescale 1ns/1ns


module ov5640_sdram_vga_top(
    // system signals
    input                   osc_clk_50      ,
    input                   reset           ,
    // ov5640 interface
    output                  cmos_xclk       ,
    output                  cmos_reset      ,
    output                  cmos_pwdn       ,
    output                  cmos_sclk       ,
    inout                   cmos_sdat       ,
    input                   cmos_pclk       ,
    input                   cmos_href       ,
    input                   cmos_vsync      ,
    input       [ 7:0]      cmos_d          ,
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
    // vga interface
    output                  h_sync          ,
    output                  v_sync          ,
    output      [ 4:0]      red             ,
    output      [ 5:0]      green           ,
    output      [ 4:0]      blue             
);


// --------------------------------------------------------
// ************ define parameters and signals ********
// --------------------------------------------------------
wire                clk_24M         ;
wire                clk_50M         ;
wire                clk_50M_2       ;
wire                clk_100M        ;
wire                clk_vga         ;  // 65MHz
wire                rst_n           ;
wire        [15:0]  rgb565          ;
wire                rgb565_ready    ;
wire                pclk            ;

wire                empty_r         ;
wire                vga_req         ;
wire        [15:0]  vga_data        ;

wire                LOCKED          ;
wire                LOCKED1         ;
wire                rst_key_out     ;

// --------------------------------------------------------
// ******************** main code ********************
// --------------------------------------------------------
pll pll_inst(
    .CLK_IN1                            (   osc_clk_50      ),
    .CLK_OUT1                           (   clk_24M         ),
    .CLK_OUT2                           (   clk_50M         ),
    .CLK_OUT3                           (   clk_100M        ),
    .RESET                              (   1'b0            ),
    .LOCKED                             (   LOCKED          )
);

pll1 pll1_inst(
    .CLK_IN1                            (   clk_50M         ),
    .CLK_OUT1                           (   clk_vga         ),  // 
	 .CLK_OUT2                           (   clk_50M_2       ),
    .RESET                              (   1'b0            ),
    .LOCKED                             (   LOCKED1         )
);

debounce #(
    .CLK_CYC                            (   20              )
) debounce_inst(
    // system signals
    .sysclk                             (   clk_50M_2       ),
    // key
    .key_in                             (   reset           ),
    // output
    .key_out                            (   rst_key_out     )  
);

assign rst_n = reset & LOCKED & LOCKED1;

ov5640_top ov5640_top_inst(
    // system signals
    .clk_24M                            (   clk_24M         ),
    .clk_50M                            (   clk_50M_2       ),
    .rst_n                              (   rst_n           ),
    // ov5640 interface
    .cmos_reset                         (   cmos_reset      ),
    .cmos_pwdn                          (   cmos_pwdn       ),
    .cmos_sclk                          (   cmos_sclk       ),
    .cmos_sdat                          (   cmos_sdat       ),
    .cmos_xclk                          (   cmos_xclk       ),
    .cmos_pclk                          (   cmos_pclk       ),
    .cmos_href                          (   cmos_href       ),
    .cmos_vsync                         (   cmos_vsync      ),
    .cmos_d                             (   cmos_d          ),
    // pixel data output 
    .rgb565                             (   rgb565          ),
    .rgb565_ready                       (   rgb565_ready    ),
    .pclk                               (   pclk            )
);

SDRAM_TOP SDRAM_TOP_inst(
    // system signals
    .sysclk_100M                        (   clk_100M        ),
    .rst_n                              (   rst_n           ),
    // sdram interface
    .CLK                                (   CLK             ),
    .CKE                                (   CKE             ),
    .cs_n                               (   cs_n            ),
    .ras_n                              (   ras_n           ),
    .cas_n                              (   cas_n           ),
    .we_n                               (   we_n            ),
    .addr                               (   addr            ),
    .ba                                 (   ba              ),
    .dqm                                (   dqm             ),
    .dq                                 (   dq              ),
    // write fifo interface
    .w_clk                              (   ~pclk           ),
    .wen                                (   rgb565_ready    ),
    .din                                (   rgb565         ),
    // read fifo interface
    .r_clk                              (   clk_vga         ),
    .ren                                (   vga_req         ),
    .dout                               (   vga_data        ),
    .empty_r                            (   empty_r         )
);

vga_driver vga_driver_inst(
    // system signals
    .sys_clk                            (   ~clk_vga        ),
    .rst_n                              (   rst_n & ~empty_r  ),
    // req data
    .data_req                           (   vga_req         ),
    .data                               (   vga_data        ),
    // vga interface
    .h_sync                             (   h_sync          ),
    .v_sync                             (   v_sync          ),
    .red                                (   red             ),
    .green                              (   green           ),
    .blue                               (   blue            )
);

endmodule