// ================================================
// 
// designer:            yang shjiang
// date:                2020-07-25
// description:         the debounce module
// 
// ================================================

module debounce #(
    parameter           CLK_CYC =   10
)(
    // system signals
    input               sysclk      ,
    // key
    input               key_in      ,
    // output
    output  reg         key_out=1     
);

// ============================================
// ******** define params/signals *********
// ============================================
localparam              CNT_END     =   10_000_000/CLK_CYC  ;
localparam              CNT_WIDTH   =   32     ;

reg     [CNT_WIDTH-1:0] cnt =   'd0     ;
reg     [ 1:0]          key_in_r        ;

wire                    trig            ;

// ============================================
// ********** main code ********************
// ============================================
// detect trig
always @(posedge sysclk) begin
    key_in_r    <=  {key_in_r[0], key_in} ;
end

assign trig = key_out ^ key_in_r[1] ;

// cnt
always @(posedge sysclk) begin
    if (trig == 1'b0)
        cnt     <=  'd0 ;
    else if (cnt == CNT_END)
        cnt     <=  cnt ;
    else
        cnt     <=  cnt + 'd1   ;
end

// key_out
always @(posedge sysclk) begin
    if (cnt == CNT_END-1 ) begin
        key_out     <=  key_in_r[1] ; 
    end else begin
        key_out     <=  key_out     ;
    end
end


endmodule