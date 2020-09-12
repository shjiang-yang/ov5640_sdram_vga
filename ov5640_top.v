// =========================================================
// 
// designer:               yang shjiang
// date:                   2020-09-08
// description:            ov5640 top
// 
// =========================================================
`timescale 1ns/1ns


module ov5640_top(
    // system signals
    input               clk_24M     ,
    input               clk_50M     ,
    input               rst_n       ,
    // ov5640 interface
    output              cmos_reset  ,
    output              cmos_pwdn   ,
    output              cmos_sclk   ,
    inout               cmos_sdat   ,
    output              cmos_xclk   ,
    input               cmos_pclk   ,
    input               cmos_href   ,
    input               cmos_vsync  ,
    input      [ 7:0]   cmos_d      ,
    // pixel data output 
    output     [15:0]   rgb565      ,
    output              rgb565_ready,
    output              pclk        
);

// --------------------------------------------------------
// ************ define parameters and signals ********
// --------------------------------------------------------
wire            pwup_done   ;
wire            cfg_done    ;
wire            clk_100k    ;

reg     [8:0]   cnt         ;


// --------------------------------------------------------
// ******************** main code ********************
// --------------------------------------------------------
always @(posedge clk_50M or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt     <=  'd0     ;
    end else begin
        cnt     <=  cnt + 1'd1  ;
    end
end

assign clk_100k = cnt[8]    ;

assign pclk = cmos_pclk     ;
assign cmos_xclk = clk_24M  ;

ov5640_powerup ov5640_powerup_inst(
    // system signals
    .sysclk                         (   clk_50M     ),       // 50M
    .rst_n                          (   rst_n       ),
    // ov5640 interface
    .cmos_pwdn                      (   cmos_pwdn   ),
    .cmos_reset                     (   cmos_reset  ),
    // other
    .done                           (   pwup_done   )
);

ov5640_cfg ov5640_cfg_inst(
    // system signals
    .sysclk                         (   clk_100k                ),  // sclk*2 max 100k
    .rst_n                          (   rst_n  & pwup_done      ),
    // sccb
    .cmos_sclk                      (   cmos_sclk               ),
    .cmos_sdat                      (   cmos_sdat               ),
    // control  
    .cfg_done                       (   cfg_done                )
);

ov5640_data ov5640_data_inst(
    // system signals
    .rst_n                          (   rst_n & cfg_done        ),
    // ov5640 data interface    
    .cmos_pclk                      (   cmos_pclk               ),
    .cmos_href                      (   cmos_href               ),
    .cmos_vsync                     (   cmos_vsync              ),
    .cmos_d                         (   cmos_d                  ),
    // data output  
    .rgb565                         (   rgb565                  ),  // delay a pclk
    .rgb565_ready                   (   rgb565_ready            )
);

endmodule