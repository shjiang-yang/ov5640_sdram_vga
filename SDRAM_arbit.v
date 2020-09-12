// ======================================================
// 
// designer:            yang shjiang
// date:                2020-07-24
// description:         the sdram arbit module
// 
// ======================================================
`include "./SDRAM_config.v"

module SDRAM_arbit(
    // system signals
    input                   sysclk_100M         ,
    input                   rst_n               ,
    // sdram interface
    output                  CLK                 ,
    output                  CKE                 ,
    output  reg             cs_n                ,
    output  reg             ras_n               ,
    output  reg             cas_n               ,
    output  reg             we_n                ,
    output  reg     [12:0]  addr                ,
    output  reg     [ 1:0]  ba                  ,
    output          [ 1:0]  dqm                 ,
    inout           [15:0]  dq                  ,
    // write fifo
    input                   write_trig          ,  // full
    output                  write_data_vld      ,  // w_fifo ren
    input           [15:0]  w_dq                ,
    // read fifo
    input                   read_trig           ,
    output                  read_data_vld       ,  // r_fifo_wen
    output          [15:0]  r_dq                ,
    output                  write_end           
);

// ===============================================
// ********* define params and signals ******
// ===============================================
localparam              NOP     =   4'b0111     ;

localparam              S_INIT  =   5'b0_0001   ;
localparam              S_ARBIT =   5'b0_0010   ;
localparam              S_REF   =   5'b0_0100   ;
localparam              S_WRITE =   5'b0_1000   ;
localparam              S_READ  =   5'b1_0000   ;

reg         [ 4:0]      state                   ;

// init
wire                    init_end_flag           ;
wire        [ 3:0]      cmd_init                ;
wire        [12:0]      sdram_addr_init         ;
wire        [ 1:0]      bank_addr_init          ;
// refresh
wire                    arbit_refresh_req       ;
wire                    arbit_refresh_end       ;
reg                     arbit_refresh_ack       ;
wire        [ 3:0]      cmd_refresh             ;
wire        [12:0]      sdram_addr_refresh      ;
wire        [ 1:0]      bank_addr_refresh       ;
// write
wire                    arbit_write_req         ;
wire                    write_prech_end         ;
reg                     arbit_write_ack         ;
wire        [ 3:0]      cmd_write               ;
wire        [12:0]      sdram_addr_write        ;
wire        [ 1:0]      bank_addr_write         ;
// read
wire                    arbit_read_req          ;
wire                    read_prech_end          ;
reg                     arbit_read_ack          ;
wire                    read_end                ;
wire        [ 3:0]      cmd_read                ;
wire        [12:0]      sdram_addr_read         ;
wire        [ 1:0]      bank_addr_read          ;


// flag for last read or write ; '1' for write, '0' for read
reg                     write_read_flag         ;

// =================================================
// *************** main code ********************
// =================================================
assign dqm  = 2'b00         ;
assign CKE  = 1'b1          ;
assign CLK  = ~sysclk_100M  ;

assign dq   = (state == S_WRITE) ? w_dq : 16'hzzzz   ;
assign r_dq = dq    ;

// state machine
always @(posedge sysclk_100M or negedge rst_n) begin
    if (rst_n == 1'b0)
        state <=    S_INIT  ;
    else
    case (state)
        S_INIT: 
                begin
                    if (init_end_flag == 1'b1)
                        state   <=  S_ARBIT ;
                    else
                        state   <=  S_INIT  ;
                end
        S_ARBIT:
                begin
                    if (arbit_refresh_req == 1'b1)
                        state   <=  S_REF    ;
						  else if (arbit_write_req == 1'b1 && arbit_read_req == 1'b1 && 
                            write_end == 1'b1 && read_end == 1'b1 && write_read_flag == 1'b1)
                        state   <=  S_READ  ;
                    else if (arbit_write_req == 1'b1 && arbit_read_req == 1'b1 && 
                            write_end == 1'b1 && read_end == 1'b1 && write_read_flag == 1'b0)
                        state   <=  S_WRITE ;
                    else if (arbit_write_req == 1'b1 && read_end == 1'b1)
                        state   <= S_WRITE  ;
                    else if (arbit_read_req == 1'b1 && write_end == 1'b1)
                        state   <=  S_READ  ;
                    else 
                        state   <=  S_ARBIT  ;
                end
        S_REF:
                begin
                    if (arbit_refresh_end == 1'b1)
                        state   <=  S_ARBIT ;
                    else
                        state   <=  S_REF   ;
                end

        S_WRITE:
                begin
                    if (write_prech_end == 1'b1 && (arbit_refresh_req == 1'b1 || write_end == 1'b1)) 
                        state   <=  S_ARBIT ;
                    else
                        state   <=  S_WRITE ;
                end
        S_READ:
                begin
                    if (read_prech_end == 1'b1 && (arbit_refresh_req == 1'b1 || read_end == 1'b1))
                        state   <=  S_ARBIT ;
                    else
                        state   <=  S_READ  ;
                end
        default:        state   <=  S_INIT  ;
    endcase
end

// output
always @(posedge sysclk_100M) begin
    case (state)
        S_INIT: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  cmd_init            ;
                    addr                        <=  sdram_addr_init     ;
                    ba                          <=  bank_addr_init      ;
                    // write_read_flag
                    write_read_flag             <=  1'b0                ;
                    // control module
                    arbit_refresh_ack           <=  1'b0                ;
                    arbit_write_ack             <=  1'b0                ;
                    arbit_read_ack              <=  1'b0                ;
                end
        S_ARBIT: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  NOP                 ;
                    addr                        <=  addr                ;
                    ba                          <=  ba                  ;
                    // write_read_flag
                    write_read_flag             <=  write_read_flag     ;
                    // control module
                    if (arbit_refresh_req == 1'b1) begin
                        arbit_refresh_ack           <=  1'b1                ;
                        arbit_write_ack             <=  1'b0                ;
                        arbit_read_ack              <=  1'b0                ;
                    end
                    else if (arbit_write_req == 1'b1 && arbit_read_req == 1'b1 && 
                            write_end == 1'b1 && read_end == 1'b1 && write_read_flag == 1'b0) begin 
                        arbit_refresh_ack           <=  1'b0                ;
                        arbit_write_ack             <=  1'b1                ;
                        arbit_read_ack              <=  1'b0                ;
                    end
                    else if (arbit_write_req == 1'b1 && arbit_read_req == 1'b1 && 
                            write_end == 1'b1 && read_end == 1'b1 && write_read_flag == 1'b1) begin 
                        arbit_refresh_ack           <=  1'b0                ;
                        arbit_write_ack             <=  1'b0                ;
                        arbit_read_ack              <=  1'b1                ;
                    end
                    else if (arbit_write_req == 1'b1 && read_end == 1'b1) begin 
                        arbit_refresh_ack           <=  1'b0                ;
                        arbit_write_ack             <=  1'b1                ;
                        arbit_read_ack              <=  1'b0                ;
                    end
                    else if (arbit_read_req == 1'b1 && write_end == 1'b1) begin 
                        arbit_refresh_ack           <=  1'b0                ;
                        arbit_write_ack             <=  1'b0                ;
                        arbit_read_ack              <=  1'b1                ;
                    end
                    else begin
                        arbit_refresh_ack           <=  1'b0                ;
                        arbit_write_ack             <=  1'b0                ;
                        arbit_read_ack              <=  1'b0                ;
                    end
                end
        S_REF: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  cmd_refresh         ;
                    addr                        <=  sdram_addr_refresh  ;
                    ba                          <=  bank_addr_refresh   ;
                    // write_read_flag
                    write_read_flag             <=  write_read_flag     ;
                    // control module
                    arbit_refresh_ack           <=  1'b0                ;
                    arbit_write_ack             <=  1'b0                ;
                    arbit_read_ack              <=  1'b0                ;
                end
        S_WRITE: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  cmd_write           ;
                    addr                        <=  sdram_addr_write    ;
                    ba                          <=  bank_addr_write     ;
                    // write_read_flag
                    write_read_flag             <=  1'b1                ;
                    // control module
                    arbit_refresh_ack           <=  1'b0                ;
                    arbit_write_ack             <=  1'b0                ;
                    arbit_read_ack              <=  1'b0                ;
                end
        S_READ: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  cmd_read            ;
                    addr                        <=  sdram_addr_read     ;
                    ba                          <=  bank_addr_read      ;
                    // write_read_flag
                    write_read_flag             <=  1'b0                ;
                    // control module
                    arbit_refresh_ack           <=  1'b0                ;
                    arbit_write_ack             <=  1'b0                ;
                    arbit_read_ack              <=  1'b0                ;
                end
        default: 
                begin
                    // output
                    {cs_n, ras_n, cas_n, we_n}  <=  NOP                 ;
                    addr                        <=  addr                ;
                    ba                          <=  ba                  ;
                    // write_read_flag
                    write_read_flag             <=  write_read_flag     ;
                    // control module
                    arbit_refresh_ack           <=  1'b0                ;
                    arbit_write_ack             <=  1'b0                ;
                    arbit_read_ack              <=  1'b0                ;
                end
    endcase
end

SDRAM_init SDRAM_init_inst(
    // system signal
    .sysclk_100M                (   sysclk_100M                 )   ,       // note: ~sdram_clk
    .rst_n                      (   rst_n                       )   ,
    // SDRAM            
    .cmd_reg                    (   cmd_init                    )   ,
    .sdram_ba                   (   bank_addr_init              )   ,
    .sdram_addr                 (   sdram_addr_init             )   ,
    // init end flag            
    .init_end_flag              (   init_end_flag               )
);


SDRAM_refresh SDRAM_refresh_inst(
    // system signal 
    .sysclk_100M                (   sysclk_100M                 )   ,        // note: ~sdram_clk
    .rst_n                      (   rst_n                       )   ,
    // sdram
    .cmd_reg                    (   cmd_refresh                 )   ,
    // arbit
    .arbit_refresh_ack          (   arbit_refresh_ack           )   ,
    .arbit_refresh_req          (   arbit_refresh_req           )   ,
    .refresh_end                (   arbit_refresh_end           )
);
assign  sdram_addr_refresh = 13'd0  ;
assign  bank_addr_refresh  = 2'd0   ;


SDRAM_write SDRAM_write_inst(
    // system singals
    .sysclk_100M                (   sysclk_100M                 )   ,
    .rst_n                      (   rst_n                       )   ,
    // arbit
    .arbit_write_req            (   arbit_write_req             )   ,
    .arbit_write_ack            (   arbit_write_ack             )   ,
    .arbit_prech_end            (   write_prech_end             )   ,
    .write_end                  (   write_end                   )   ,
    // from refresh module
    .refresh_req                (   arbit_refresh_req           )   ,
    // sdram
    .cmd_reg                    (   cmd_write                   )   ,
    .sdram_addr                 (   sdram_addr_write            )   ,
    .sdram_bank_addr            (   bank_addr_write             )   ,
    // others
    .write_trig                 (   write_trig                  )   ,
    .data_vld                   (   write_data_vld              )   
);


SDRAM_read SDRAM_read_inst(
    // system signals
    .sysclk_100M                (   sysclk_100M                 )   ,
    .rst_n                      (   rst_n                       )   ,
    // sdram
    .cmd_reg                    (   cmd_read                    )   ,
    .sdram_addr                 (   sdram_addr_read             )   ,
    .sdram_bank_addr            (   bank_addr_read              )   ,
    // from refresh
    .refresh_req                (   arbit_refresh_req           )   ,
    // from arbit
    .arbit_read_req             (   arbit_read_req              )   ,
    .arbit_read_ack             (   arbit_read_ack              )   ,
    .arbit_read_end             (   read_end                    )   ,
    .arbit_prech_end            (   read_prech_end              )   ,
    // from write module
    `ifdef PINGPONG_BUFFER
        .write_bank_addr        (   bank_addr_write             )   ,
    `endif
    // others
    .read_trig                  (   read_trig                   )   ,
    .data_vld                   (   read_data_vld               )   
);

endmodule