// =========================================================
// 
// designer:               yang shjiang
// date:                   2020-09-06
// description:            the ov5640_data module
// 
// =========================================================
`timescale 1ns/1ns


module ov5640_data(
    // system signals
    input                   rst_n           ,
    // ov5640 data interface    
    input                   cmos_pclk       ,
    input                   cmos_href       ,
    input                   cmos_vsync      ,
    input       [ 7:0]      cmos_d          ,
    // data output  
    output reg  [15:0]      rgb565          ,  // delay a pclk
    output                  rgb565_ready    
);

// --------------------------------------------------------
// ************ define parameters and signals ********
// --------------------------------------------------------
localparam          DUMMY_FRAMES    =   10  ;

reg                 rgb565_high     ;
wire                frame_start     ;
reg                 cmos_vsync_r    ;
wire                cmos_vsync_pos  ;

reg     [3:0]       dummy_frames    ;

// --------------------------------------------------------
// ******************** main code ********************
// --------------------------------------------------------

// rgb565_high
always @(posedge cmos_pclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        rgb565_high <=  1'b0    ;
    end else if (frame_start == 1'b1 && cmos_href == 1'b1) begin
        rgb565_high <=  ~rgb565_high    ;
    end else begin
        rgb565_high <=  1'b0    ;
    end
end

// rgb565
always @(posedge cmos_pclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        rgb565  <=  16'd0   ;
    end else if (rgb565_high == 1'b0) begin
        rgb565  <=  {cmos_d, rgb565[7:0]}   ;
    end else begin
        rgb565  <=  {rgb565[15:8], cmos_d}  ;
    end
end

// rgb565_ready
//always @(posedge cmos_pclk) begin
//    rgb565_ready <= rgb565_high   ;
//end
assign rgb565_ready = rgb565_high;

// cmos_vsync_r
always @(posedge cmos_pclk) begin
    cmos_vsync_r    <=  cmos_vsync  ;
end

assign cmos_vsync_pos = ~cmos_vsync_r & cmos_vsync  ;

// dummy_frames
always @(posedge cmos_pclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        dummy_frames    <=  4'd0    ;
    end else if (dummy_frames == DUMMY_FRAMES-1) begin
        dummy_frames    <=  dummy_frames    ;
    end else if (cmos_vsync_pos == 1'b1) begin
        dummy_frames    <=  dummy_frames    + 1'd1  ;
    end
end

// frame_start
assign frame_start = (dummy_frames >= DUMMY_FRAMES-1) ? 1'b1 : 1'b0 ;


endmodule