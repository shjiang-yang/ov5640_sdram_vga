// =========================================================
// 
// designer:               yang shjiang
// date:                   2020-09-08
// description:            the sccb module
// 
// =========================================================
`timescale 1ns/1ns


module ov5640_sccb(
    // system signals
    input                   sysclk      ,   // sclk*2
    input                   rst_n       ,
    // control
    input                   start       ,
    input       [31:0]      cfg_data    ,
    output reg  [ 7:0]      rd_data     ,
    output reg              busy        ,
    output reg              done        ,
    // sccb interface
    output reg              cmos_sclk   ,
    inout                   cmos_sdat   
);

// --------------------------------------------------------
// ************ define parameters and signals ********
// --------------------------------------------------------
localparam                  READ_JUMP_FROM  =   55  ;
localparam                  READ_JUMP_TO    =   76  ;
localparam                  WRITE_END_CNT   =   75  ;
localparam                  READ_END_CNT    =   117 ;

reg         [6:0]           cnt         ;
wire                        read        ;

reg                         cmos_sdat_r ;
reg         [31:0]          cfg_data_r  ;
reg                         sdat_dir    ;   // 1: read data from ov5640
// --------------------------------------------------------
// ******************** main code ********************
// --------------------------------------------------------

// cfg_data_r
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cfg_data_r <=  32'd0 ;
    end else if (start == 1'b1) begin
        cfg_data_r <=  cfg_data ;
    end
end

// busy
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        busy    <=  1'b0    ;
    end else if (start == 1'b1) begin
        busy    <=  1'b1    ;
    end else if (cnt == WRITE_END_CNT || cnt == READ_END_CNT) begin
        busy    <=  1'b0    ;
    end
end

// done
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        done    <=  1'b0    ;
    end else if (cnt == WRITE_END_CNT || cnt == READ_END_CNT) begin
        done    <=  1'b1    ;
    end else begin
        done    <=  1'b0    ;
    end
end

// cnt
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt     <=  7'd0    ;
    end else if (cnt == WRITE_END_CNT || cnt == READ_END_CNT) begin
        cnt     <=  7'd0    ;
    end else if (read == 1'b1 && cnt == READ_JUMP_FROM) begin
        cnt     <=  READ_JUMP_TO    ;
    end else if (busy   == 1'b1) begin
        cnt     <=  cnt + 1'd1  ;
    end
end

// read
assign read = cfg_data_r[24] ;

// cmos_sclk
always @(negedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cmos_sclk   <=  1'b1    ;
    end else if (cnt >= READ_JUMP_TO+1 && cnt <= READ_JUMP_TO + 3) begin
        cmos_sclk   <=  1'b1    ;
    end else if (cnt >= 2) begin
        cmos_sclk   <=  ~cmos_sclk  ;
    end else begin
        cmos_sclk   <=  1'b1    ;
    end
end

// cmos_sdat
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cmos_sdat_r   <=  1'b1    ;
    end else if (busy == 1'b1) begin
        case (cnt[6:1])
              0:    cmos_sdat_r     <=  ~cnt[0]     ;  // start

              1:    cmos_sdat_r     <=  cfg_data_r[31] ;  // ID
              2:    cmos_sdat_r     <=  cfg_data_r[30] ; 
              3:    cmos_sdat_r     <=  cfg_data_r[29] ; 
              4:    cmos_sdat_r     <=  cfg_data_r[28] ; 
              5:    cmos_sdat_r     <=  cfg_data_r[27] ; 
              6:    cmos_sdat_r     <=  cfg_data_r[26] ; 
              7:    cmos_sdat_r     <=  cfg_data_r[25] ; 
              8:    cmos_sdat_r     <=  1'b0        ; 

             10:    cmos_sdat_r     <=  cfg_data_r[23] ;  // sub addr-h
             11:    cmos_sdat_r     <=  cfg_data_r[22] ; 
             12:    cmos_sdat_r     <=  cfg_data_r[21] ; 
             13:    cmos_sdat_r     <=  cfg_data_r[20] ; 
             14:    cmos_sdat_r     <=  cfg_data_r[19] ; 
             15:    cmos_sdat_r     <=  cfg_data_r[18] ; 
             16:    cmos_sdat_r     <=  cfg_data_r[17] ; 
             17:    cmos_sdat_r     <=  cfg_data_r[16] ; 

             19:    cmos_sdat_r     <=  cfg_data_r[15] ;  // sub addr-l
             20:    cmos_sdat_r     <=  cfg_data_r[14] ; 
             21:    cmos_sdat_r     <=  cfg_data_r[13] ; 
             22:    cmos_sdat_r     <=  cfg_data_r[12] ; 
             23:    cmos_sdat_r     <=  cfg_data_r[11] ; 
             24:    cmos_sdat_r     <=  cfg_data_r[10] ; 
             25:    cmos_sdat_r     <=  cfg_data_r[09] ; 
             26:    cmos_sdat_r     <=  cfg_data_r[08] ; 

             28:    cmos_sdat_r     <=  cfg_data_r[07] ;  // write data
             29:    cmos_sdat_r     <=  cfg_data_r[06] ; 
             30:    cmos_sdat_r     <=  cfg_data_r[05] ; 
             31:    cmos_sdat_r     <=  cfg_data_r[04] ; 
             32:    cmos_sdat_r     <=  cfg_data_r[03] ; 
             33:    cmos_sdat_r     <=  cfg_data_r[02] ; 
             34:    cmos_sdat_r     <=  cfg_data_r[01] ; 
             35:    cmos_sdat_r     <=  cfg_data_r[00] ; 

             37:    cmos_sdat_r     <=  cnt[0]      ;  // write stop 

             38:    cmos_sdat_r     <=  cnt[0]      ;  //  stop for read
             39:    cmos_sdat_r     <=  ~cnt[0]     ;  //  start for read

             40:    cmos_sdat_r     <=  cfg_data_r[31] ;  // ID read
             41:    cmos_sdat_r     <=  cfg_data_r[30] ; 
             42:    cmos_sdat_r     <=  cfg_data_r[29] ; 
             43:    cmos_sdat_r     <=  cfg_data_r[28] ; 
             44:    cmos_sdat_r     <=  cfg_data_r[27] ; 
             45:    cmos_sdat_r     <=  cfg_data_r[26] ; 
             46:    cmos_sdat_r     <=  cfg_data_r[25] ; 
             47:    cmos_sdat_r     <=  1'b1        ; 

             58:    cmos_sdat_r     <=  cnt[0]      ;  //  read stop
            default: cmos_sdat_r    <=  1'b1        ;
        endcase
    end else begin
        cmos_sdat_r <=  1'b1    ;
    end
end

// sdat_dir
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        sdat_dir    <=  1'b0    ;
    end else begin
        case (cnt[6:1])
            9, 18, 27, 36, 48, 49, 50, 51, 52, 53, 54, 55, 56:   sdat_dir    <=  1'b1    ; 
            default: sdat_dir   <=  1'b0    ;
        endcase
    end
end

assign cmos_sdat = (sdat_dir == 1'b1) ? 1'bz : cmos_sdat_r  ;

// rd_data
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        rd_data <=  8'd0    ;
    end else if (sdat_dir == 1'b1 && cmos_sclk == 1'b1) begin
        rd_data <=  {rd_data[6:0], cmos_sdat}   ;
    end
end

endmodule