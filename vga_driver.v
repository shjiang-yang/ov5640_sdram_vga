// ===================================================
// 
// designer:        yang shjiang
// date:            2020-08-23
// description:     the vga driver
// 
// ===================================================

// ---------------------------------------------
// ********** vga define parameters *******
// ---------------------------------------------

`define     1024_768_60Hz

`ifdef  800_600_60Hz
    // 800*600@60Hz 40MHz
    `define H_SYNC_TIME     128
    `define H_BACK_PORCH    88
    `define H_LEFT_BORDER   0
    `define H_ADDR_TIME     800
    `define H_RIGHT_BORDER  0
    `define H_FRONT_PORCH   40
    `define H_TOTAL_TIME    1056
    `define H_CNT_WIDTH     11

    `define V_SYNC_TIME     4
    `define V_BACK_PORCH    23
    `define V_TOP_BORDER    0
    `define V_ADDR_TIME     600
    `define V_BOTTOM_BORDER 0
    `define V_FRONT_PORCH   1
    `define V_TOTAL_TIME    628
    `define V_CNT_WIDTH     10
	 
`elsif 1024_768_60Hz
    // 1024*768@60Hz 65MHz
    `define H_SYNC_TIME     136
    `define H_BACK_PORCH    160
    `define H_LEFT_BORDER   0
    `define H_ADDR_TIME     1024
    `define H_RIGHT_BORDER  0
    `define H_FRONT_PORCH   24
    `define H_TOTAL_TIME    1344
    `define H_CNT_WIDTH     11

    `define V_SYNC_TIME     6
    `define V_BACK_PORCH    29
    `define V_TOP_BORDER    0
    `define V_ADDR_TIME     768
    `define V_BOTTOM_BORDER 0
    `define V_FRONT_PORCH   3
    `define V_TOTAL_TIME    806
    `define V_CNT_WIDTH     10
	 
`endif


module vga_driver(
    // system signals
    input               sys_clk     ,   
    input               rst_n       ,
    // req data
    output  reg         data_req    ,
    input       [15:0]  data        ,
    // vga interface
    output  reg         h_sync      ,
    output  reg         v_sync      ,
    output      [ 4:0]  red         ,
    output      [ 5:0]  green       ,
    output      [ 4:0]  blue        
);

// -----------------------------------------------
// ********** define parameters and signals ***
// -----------------------------------------------
reg     [`H_CNT_WIDTH-1:0]      h_cnt       ;
reg     [`V_CNT_WIDTH-1:0]      v_cnt       ;

reg                             data_req_r  ;



// ------------------------------------------------
// *************** main code ******************
// ------------------------------------------------

// h_cnt
always @(posedge sys_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        h_cnt   <=  1'b0    ;
    end else if (h_cnt == `H_TOTAL_TIME-1) begin
        h_cnt   <=  1'b0    ;
    end else begin
        h_cnt   <=  h_cnt   +   1'b1    ;
    end
end

// v_cnt
always @(posedge sys_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        v_cnt   <=  1'b0    ;
    end else if (v_cnt == `V_TOTAL_TIME-1 && h_cnt == `H_TOTAL_TIME-1) begin
        v_cnt   <=  1'b0    ;
    end else if (h_cnt == `H_TOTAL_TIME-1) begin
        v_cnt   <=  v_cnt   +   1'b1    ;
    end
end

// h_sync
always @(posedge sys_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        h_sync  <=  1'b1    ;
    end else if (h_cnt  <=  `H_SYNC_TIME-1) begin
        h_sync  <=  1'b0    ;
    end else begin
        h_sync  <=  1'b1    ;
    end
end

// v_sync
always @(posedge sys_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        v_sync  <=  1'b1    ;
    end else if (v_cnt  <=  `V_SYNC_TIME-1) begin
        v_sync  <=  1'b0    ;
    end else begin
        v_sync  <=  1'b1    ;
    end
end

// data_req
always @(posedge sys_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        data_req    <=  1'b0    ;
    end else if (`H_SYNC_TIME+`H_BACK_PORCH+`H_LEFT_BORDER-2 <= h_cnt               && 
                 h_cnt <= `H_SYNC_TIME+`H_BACK_PORCH+`H_LEFT_BORDER+`H_ADDR_TIME-3  && 
                 `V_SYNC_TIME+`V_BACK_PORCH+`V_TOP_BORDER+24 <= v_cnt                && 
                 v_cnt <= `V_SYNC_TIME+`V_BACK_PORCH+`V_BOTTOM_BORDER+`V_ADDR_TIME-1-24) begin
        data_req    <=  1'b1    ;
    end else begin
        data_req    <=  1'b0    ;
    end
end

// data_req_r
always @(posedge sys_clk) begin
    data_req_r  <=  data_req    ;
end

// red/green/blue
assign blue     =   (data_req_r == 1'b0) ? 5'h0 : data[ 4: 0]  ;
assign green    =   (data_req_r == 1'b0) ? 6'h0 : data[10: 5]  ;
assign red      =   (data_req_r == 1'b0) ? 5'h0 : data[15:11]  ;

endmodule