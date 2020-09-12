// ====================================================
// 
// designer:        yang shjiang
// date:            2020-07-21
// description:     sdram refresh module
// 
// ====================================================


module SDRAM_refresh (
    // system signal 
    input                       sysclk_100M         ,        // note: ~sdram_clk
    input                       rst_n               ,
    // sdram
    output          [ 3:0]      cmd_reg             ,
    // arbit
    input                       arbit_refresh_ack   ,
    output                      arbit_refresh_req   ,
    output                      refresh_end      
);

// ===================================================\
// *********** define params and signals **********
// ===================================================/
localparam          CNT_7800ns  =   780         ;
localparam          CNT_70ns    =   7           ;

localparam              NOP         =   4'b0111 ;
localparam              REFRESH     =   4'b0001 ;


reg     [12:0]      cnt_refresh                 ;
reg     [ 3:0]      cnt_cmd                     ;
wire                time2refresh                ;

// ===================================================\
// ****************** main code *******************
// ===================================================/

// cnt_refresh
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt_refresh <= 13'd0;
    else if (arbit_refresh_ack == 1'b1)
        cnt_refresh <= 13'd0;
    else if (cnt_refresh == CNT_7800ns)
        cnt_refresh <= cnt_refresh;
    else
        cnt_refresh <= cnt_refresh + 13'd1;
end

// arbit_refresh_req
assign time2refresh         = (cnt_refresh == CNT_7800ns) ? 1'b1 : 1'b0;
assign arbit_refresh_req    = time2refresh & (~arbit_refresh_ack);

// cnt_cmd
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt_cmd <= 4'd0;
    else if (arbit_refresh_req == 1'b1)
        cnt_cmd <= 4'd0;
    else if (cnt_cmd == CNT_70ns)
        cnt_cmd <= cnt_cmd;
    else
        cnt_cmd <= cnt_cmd + 4'd1;
end

// cmd_reg
assign cmd_reg = (cnt_cmd == 4'd1) ? REFRESH : NOP;

// refresh_end
assign refresh_end = (cnt_cmd == 4'd7) ? 1'b1 : 1'b0;

endmodule