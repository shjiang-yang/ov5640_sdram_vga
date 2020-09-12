// ==================================================
// 
// designer:            yang shjiang
// date:                2020-07-18
// description:         to initial the SDRAM 
// 
// ==================================================

module SDRAM_init(
    // system signal
    input                   sysclk_100M     ,       // note: ~sdram_clk
    input                   rst_n           ,
    // SDRAM
    output  reg     [ 3:0]  cmd_reg         ,
    output          [1:0]   sdram_ba        ,
    output  reg     [12:0]  sdram_addr      ,
    // init end flag
    output                  init_end_flag
);


// ==================================================\
// *********** define parameter and signal *****
// ==================================================/
localparam              POWERUP_200us    =   20000  ;
localparam              CMD_CNT          =   11     ;

// CMD -- cs_n, ras_n, cas_n, we_n
localparam              NOP         =   4'b0111 ;
localparam              PRECHARGE   =   4'b0010 ;
localparam              REFRESH     =   4'b0001 ;
localparam              MODEREG_SET =   4'b0000 ;

reg     [14:0]      powerup_cnt     ;
reg     [ 3:0]       cmd_cnt         ;
wire                powerup_done    ;


// ==================================================\
// ***************** main code *****************
// ==================================================/

// power up
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        powerup_cnt     <=  11'd0   ;
    else if (powerup_cnt == POWERUP_200us)
        powerup_cnt     <=  POWERUP_200us   ;
    else
        powerup_cnt     <= powerup_cnt + 15'd1;
end

assign  powerup_done = (powerup_cnt == POWERUP_200us) ? 1'b1 : 1'b0;


// cmd_cnt
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cmd_cnt     <= 4'd0     ;
    else if (cmd_cnt == CMD_CNT)
        cmd_cnt     <= CMD_CNT  ;
    else if (powerup_done == 1'b1)
        cmd_cnt     <=  cmd_cnt + 4'd1;
    else
        cmd_cnt     <=  4'd0    ;
end


// give cmd
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        cmd_reg    <=   NOP ;
    else
        case (cmd_cnt)
            0:  begin
                cmd_reg     <=  NOP                     ;
                sdram_addr  <=  13'b0_0100_0000_0000    ;
                end
            1:  begin
                cmd_reg     <=  PRECHARGE               ;
                sdram_addr  <=  13'b0_0100_0000_0000    ;
                end
            3:  begin
                cmd_reg     <=  REFRESH                 ;
                sdram_addr  <=  13'b0_0100_0000_0000    ;
                end
           10:  begin
                cmd_reg     <=  MODEREG_SET             ;
                sdram_addr  <=  13'b0_0000_0011_0011    ;
                end
            default:    begin
                        cmd_reg     <=  NOP                     ;
                        sdram_addr  <=  13'b0_0100_0000_0000    ;
                        end
        endcase
end


// bank addr
assign sdram_ba = 2'b00;


// init end flag
assign init_end_flag = (cmd_cnt == CMD_CNT) ? 1'b1 : 1'b0;

endmodule