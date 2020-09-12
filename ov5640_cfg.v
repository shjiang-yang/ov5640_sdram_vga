// =========================================================
// 
// designer:               yang shjiang
// date:                   2020-09-06
// description:            ov5640 config data
// 
// =========================================================
`timescale 1ns/1ns


module ov5640_cfg(
    // system signals
    input                   sysclk          ,  // sclk*2 max 100k
    input                   rst_n           ,
    // sccb
    output                  cmos_sclk       ,
    inout                   cmos_sdat       ,
    // control  
    output reg              cfg_done        ,
    output      [7:0]       rd_data         
);

// --------------------------------------------------------
// ************ define parameters and signals ********
// --------------------------------------------------------
localparam          CFG_REG_NUM =   304 ;

wire    [31:0]      cfg_reg[0:CFG_REG_NUM-1]    ;
reg     [ 8:0]      cfg_reg_addr                ;

wire                busy    ;
reg                 busy_r  ;
wire                done    ;
reg                 start   ;

// --------------------------------------------------------
// ******************** main code ********************
// --------------------------------------------------------
// busy_r
always @(posedge sysclk) begin
    busy_r  <=  busy    ;
end

// start
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        start   <=  1'b0    ;
    end else if (busy_r == 1'b0 && cfg_done == 1'b0) begin
        start   <=  1'b1    ;
    end else begin
        start   <=  1'b0    ;
    end
end

// cfg_reg_addr
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cfg_reg_addr    <=  9'd0    ;
    end else if (cfg_reg_addr == CFG_REG_NUM-1) begin
        cfg_reg_addr    <=  cfg_reg_addr    ;
    end else if (done == 1'b1) begin
        cfg_reg_addr    <=  cfg_reg_addr + 9'd1 ;
    end
end

// cfg_done
always @(posedge sysclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cfg_done    <=  1'b0    ;
    end else if (cfg_reg_addr == CFG_REG_NUM-1 && done == 1'b1) begin
        cfg_done    <=  1'b1    ;
    end
end

// sccb
ov5640_sccb u_ov5640_sccb(
    // system signals
    .sysclk                 (   sysclk                      ),       // sclk*2
    .rst_n                  (   rst_n                       ),
    // control
    .start                  (   start                       ),
    .cfg_data               (   cfg_reg[cfg_reg_addr]       ),
    // sccb interface
    .cmos_sclk              (   cmos_sclk                   ),
    .cmos_sdat              (   cmos_sdat                   ),
    // others               
    .done                   (   done                        ),
    .busy                   (   busy                        ),
    // debug                
    .rd_data                (   rd_data                     ) 
);

//                              ID    REG_ADDR  REG_VAL
assign  cfg_reg[000]  =       {8'h78, 16'h3103, 8'h11};
assign  cfg_reg[001]  =       {8'h78, 16'h3008, 8'h82};
assign  cfg_reg[002]  =       {8'h78, 16'h3008, 8'h42};
assign  cfg_reg[003]  =       {8'h78, 16'h3103, 8'h03};
assign  cfg_reg[004]  =       {8'h78, 16'h3017, 8'hff};
assign  cfg_reg[005]  =       {8'h78, 16'h3018, 8'hff};
assign  cfg_reg[006]  =       {8'h78, 16'h3034, 8'h1A};
assign  cfg_reg[007]  =       {8'h78, 16'h3037, 8'h13};       // PLL root divider, bit[4], PLL pre-divider, bit[3:0]
assign  cfg_reg[008]  =       {8'h78, 16'h3108, 8'h01};       // PCLK root divider, bit[5:4], SCLK2x root divider, bit[3:2] // SCLK root divider, bit[1:0] 
assign  cfg_reg[009]  =       {8'h78, 16'h3630, 8'h36};
                                             
assign  cfg_reg[010]  =       {8'h78, 16'h3631, 8'h0e};
assign  cfg_reg[011]  =       {8'h78, 16'h3632, 8'he2};
assign  cfg_reg[012]  =       {8'h78, 16'h3633, 8'h12};
assign  cfg_reg[013]  =       {8'h78, 16'h3621, 8'he0};
assign  cfg_reg[014]  =       {8'h78, 16'h3704, 8'ha0};
assign  cfg_reg[015]  =       {8'h78, 16'h3703, 8'h5a};
assign  cfg_reg[016]  =       {8'h78, 16'h3715, 8'h78};
assign  cfg_reg[017]  =       {8'h78, 16'h3717, 8'h01};
assign  cfg_reg[018]  =       {8'h78, 16'h370b, 8'h60};
assign  cfg_reg[019]  =       {8'h78, 16'h3705, 8'h1a};
                                           
assign  cfg_reg[020]  =       {8'h78, 16'h3905, 8'h02};
assign  cfg_reg[021]  =       {8'h78, 16'h3906, 8'h10};
assign  cfg_reg[022]  =       {8'h78, 16'h3901, 8'h0a};
assign  cfg_reg[023]  =       {8'h78, 16'h3731, 8'h12};
assign  cfg_reg[024]  =       {8'h78, 16'h3600, 8'h08};
assign  cfg_reg[025]  =       {8'h78, 16'h3601, 8'h33};
assign  cfg_reg[026]  =       {8'h78, 16'h302d, 8'h60};
assign  cfg_reg[027]  =       {8'h78, 16'h3620, 8'h52};
assign  cfg_reg[028]  =       {8'h78, 16'h371b, 8'h20};
assign  cfg_reg[029]  =       {8'h78, 16'h471c, 8'h50};
                                            
assign  cfg_reg[030]  =       {8'h78, 16'h3a13, 8'h43};
assign  cfg_reg[031]  =       {8'h78, 16'h3a18, 8'h00};
assign  cfg_reg[032]  =       {8'h78, 16'h3a19, 8'hf8};
assign  cfg_reg[033]  =       {8'h78, 16'h3635, 8'h13};
assign  cfg_reg[034]  =       {8'h78, 16'h3636, 8'h03};
assign  cfg_reg[035]  =       {8'h78, 16'h3634, 8'h40};
assign  cfg_reg[036]  =       {8'h78, 16'h3622, 8'h01};
assign  cfg_reg[037]  =       {8'h78, 16'h3c01, 8'h34};
assign  cfg_reg[038]  =       {8'h78, 16'h3c04, 8'h28};
assign  cfg_reg[039]  =       {8'h78, 16'h3c05, 8'h98};     
                                            
assign  cfg_reg[040]  =       {8'h78, 16'h3c06, 8'h00};
assign  cfg_reg[041]  =       {8'h78, 16'h3c07, 8'h08};
assign  cfg_reg[042]  =       {8'h78, 16'h3c08, 8'h00};
assign  cfg_reg[043]  =       {8'h78, 16'h3c09, 8'h1c};
assign  cfg_reg[044]  =       {8'h78, 16'h3c0a, 8'h9c};
assign  cfg_reg[045]  =       {8'h78, 16'h3c0b, 8'h40};
assign  cfg_reg[046]  =       {8'h78, 16'h3810, 8'h00};
assign  cfg_reg[047]  =       {8'h78, 16'h3811, 8'h10};
assign  cfg_reg[048]  =       {8'h78, 16'h3812, 8'h00};
assign  cfg_reg[049]  =       {8'h78, 16'h3708, 8'h64};
                                            
assign  cfg_reg[050]  =       {8'h78, 16'h4001, 8'h02};
assign  cfg_reg[051]  =       {8'h78, 16'h4005, 8'h1a};
assign  cfg_reg[052]  =       {8'h78, 16'h3000, 8'h00};
assign  cfg_reg[053]  =       {8'h78, 16'h3004, 8'hff};
assign  cfg_reg[054]  =       {8'h78, 16'h300e, 8'h58};
assign  cfg_reg[055]  =       {8'h78, 16'h302e, 8'h00};
assign  cfg_reg[056]  =       {8'h78, 16'h4300, 8'h61};  // format control reg
assign  cfg_reg[057]  =       {8'h78, 16'h501f, 8'h01};
assign  cfg_reg[058]  =       {8'h78, 16'h440e, 8'h00};
assign  cfg_reg[059]  =       {8'h78, 16'h5000, 8'ha7};    
                                             
assign  cfg_reg[060]  =       {8'h78, 16'h3a0f, 8'h30};
assign  cfg_reg[061]  =       {8'h78, 16'h3a10, 8'h28};
assign  cfg_reg[062]  =       {8'h78, 16'h3a1b, 8'h30};
assign  cfg_reg[063]  =       {8'h78, 16'h3a1e, 8'h26};
assign  cfg_reg[064]  =       {8'h78, 16'h3a11, 8'h60};
assign  cfg_reg[065]  =       {8'h78, 16'h3a1f, 8'h14};
assign  cfg_reg[066]  =       {8'h78, 16'h5800, 8'h23};
assign  cfg_reg[067]  =       {8'h78, 16'h5801, 8'h14};
assign  cfg_reg[068]  =       {8'h78, 16'h5802, 8'h0f};
assign  cfg_reg[069]  =       {8'h78, 16'h5803, 8'h0f};  
                                            
assign  cfg_reg[070]  =       {8'h78, 16'h5804, 8'h12};
assign  cfg_reg[071]  =       {8'h78, 16'h5805, 8'h26};
assign  cfg_reg[072]  =       {8'h78, 16'h5806, 8'h0c};
assign  cfg_reg[073]  =       {8'h78, 16'h5807, 8'h08};
assign  cfg_reg[074]  =       {8'h78, 16'h5808, 8'h05};
assign  cfg_reg[075]  =       {8'h78, 16'h5809, 8'h05};
assign  cfg_reg[076]  =       {8'h78, 16'h580a, 8'h08};
assign  cfg_reg[077]  =       {8'h78, 16'h580b, 8'h0d};
assign  cfg_reg[078]  =       {8'h78, 16'h580c, 8'h08};
assign  cfg_reg[079]  =       {8'h78, 16'h580d, 8'h03};    
                                          
assign  cfg_reg[080]  =       {8'h78, 16'h580e, 8'h00};
assign  cfg_reg[081]  =       {8'h78, 16'h580f, 8'h00};
assign  cfg_reg[082]  =       {8'h78, 16'h5810, 8'h03};
assign  cfg_reg[083]  =       {8'h78, 16'h5811, 8'h09};
assign  cfg_reg[084]  =       {8'h78, 16'h5812, 8'h07};
assign  cfg_reg[085]  =       {8'h78, 16'h5813, 8'h03};
assign  cfg_reg[086]  =       {8'h78, 16'h5814, 8'h00};
assign  cfg_reg[087]  =       {8'h78, 16'h5815, 8'h01};
assign  cfg_reg[088]  =       {8'h78, 16'h5816, 8'h03};
assign  cfg_reg[089]  =       {8'h78, 16'h5817, 8'h08};  
                                           
assign  cfg_reg[090]  =       {8'h78, 16'h5818, 8'h0d};
assign  cfg_reg[091]  =       {8'h78, 16'h5819, 8'h08};
assign  cfg_reg[092]  =       {8'h78, 16'h581a, 8'h05};
assign  cfg_reg[093]  =       {8'h78, 16'h581b, 8'h06};
assign  cfg_reg[094]  =       {8'h78, 16'h581c, 8'h08};
assign  cfg_reg[095]  =       {8'h78, 16'h581d, 8'h0e};
assign  cfg_reg[096]  =       {8'h78, 16'h581e, 8'h29};
assign  cfg_reg[097]  =       {8'h78, 16'h581f, 8'h17};
assign  cfg_reg[098]  =       {8'h78, 16'h5820, 8'h11};
assign  cfg_reg[099]  =       {8'h78, 16'h5821, 8'h11};     
                                              
assign  cfg_reg[100]  =       {8'h78, 16'h5822, 8'h15};
assign  cfg_reg[101]  =       {8'h78, 16'h5823, 8'h28};
assign  cfg_reg[102]  =       {8'h78, 16'h5824, 8'h46};
assign  cfg_reg[103]  =       {8'h78, 16'h5825, 8'h26};
assign  cfg_reg[104]  =       {8'h78, 16'h5826, 8'h08};
assign  cfg_reg[105]  =       {8'h78, 16'h5827, 8'h26};
assign  cfg_reg[106]  =       {8'h78, 16'h5828, 8'h64};
assign  cfg_reg[107]  =       {8'h78, 16'h5829, 8'h26};
assign  cfg_reg[108]  =       {8'h78, 16'h582a, 8'h24};
assign  cfg_reg[109]  =       {8'h78, 16'h582b, 8'h22};       
                                            
assign  cfg_reg[110]  =       {8'h78, 16'h582c, 8'h24};
assign  cfg_reg[111]  =       {8'h78, 16'h582d, 8'h24};
assign  cfg_reg[112]  =       {8'h78, 16'h582e, 8'h06};
assign  cfg_reg[113]  =       {8'h78, 16'h582f, 8'h22};
assign  cfg_reg[114]  =       {8'h78, 16'h5830, 8'h40};
assign  cfg_reg[115]  =       {8'h78, 16'h5831, 8'h42};
assign  cfg_reg[116]  =       {8'h78, 16'h5832, 8'h24};
assign  cfg_reg[117]  =       {8'h78, 16'h5833, 8'h26};
assign  cfg_reg[118]  =       {8'h78, 16'h5834, 8'h24};
assign  cfg_reg[119]  =       {8'h78, 16'h5835, 8'h22};        
                                            
assign  cfg_reg[120]  =       {8'h78, 16'h5836, 8'h22};
assign  cfg_reg[121]  =       {8'h78, 16'h5837, 8'h26};
assign  cfg_reg[122]  =       {8'h78, 16'h5838, 8'h44};
assign  cfg_reg[123]  =       {8'h78, 16'h5839, 8'h24};
assign  cfg_reg[124]  =       {8'h78, 16'h583a, 8'h26};
assign  cfg_reg[125]  =       {8'h78, 16'h583b, 8'h28};
assign  cfg_reg[126]  =       {8'h78, 16'h583c, 8'h42};
assign  cfg_reg[127]  =       {8'h78, 16'h583d, 8'hce};
assign  cfg_reg[128]  =       {8'h78, 16'h5180, 8'hff};
assign  cfg_reg[129]  =       {8'h78, 16'h5181, 8'hf2};   
                                            
assign  cfg_reg[130]  =       {8'h78, 16'h5182, 8'h00};
assign  cfg_reg[131]  =       {8'h78, 16'h5183, 8'h14};
assign  cfg_reg[132]  =       {8'h78, 16'h5184, 8'h25};
assign  cfg_reg[133]  =       {8'h78, 16'h5185, 8'h24};
assign  cfg_reg[134]  =       {8'h78, 16'h5186, 8'h09};
assign  cfg_reg[135]  =       {8'h78, 16'h5187, 8'h09};
assign  cfg_reg[136]  =       {8'h78, 16'h5188, 8'h09};
assign  cfg_reg[137]  =       {8'h78, 16'h5189, 8'h75};
assign  cfg_reg[138]  =       {8'h78, 16'h518a, 8'h54};
assign  cfg_reg[139]  =       {8'h78, 16'h518b, 8'he0};   
                                            
assign  cfg_reg[140]  =       {8'h78, 16'h518c, 8'hb2};
assign  cfg_reg[141]  =       {8'h78, 16'h518d, 8'h42};
assign  cfg_reg[142]  =       {8'h78, 16'h518e, 8'h3d};
assign  cfg_reg[143]  =       {8'h78, 16'h518f, 8'h56};
assign  cfg_reg[144]  =       {8'h78, 16'h5190, 8'h46};
assign  cfg_reg[145]  =       {8'h78, 16'h5191, 8'hf8};
assign  cfg_reg[146]  =       {8'h78, 16'h5192, 8'h04};
assign  cfg_reg[147]  =       {8'h78, 16'h5193, 8'h70};
assign  cfg_reg[148]  =       {8'h78, 16'h5194, 8'hf0};
assign  cfg_reg[149]  =       {8'h78, 16'h5195, 8'hf0};   
                                             
assign  cfg_reg[150]  =       {8'h78, 16'h5196, 8'h03};
assign  cfg_reg[151]  =       {8'h78, 16'h5197, 8'h01};
assign  cfg_reg[152]  =       {8'h78, 16'h5198, 8'h04};
assign  cfg_reg[153]  =       {8'h78, 16'h5199, 8'h12};
assign  cfg_reg[154]  =       {8'h78, 16'h519a, 8'h04};
assign  cfg_reg[155]  =       {8'h78, 16'h519b, 8'h00};
assign  cfg_reg[156]  =       {8'h78, 16'h519c, 8'h06};
assign  cfg_reg[157]  =       {8'h78, 16'h519d, 8'h82};
assign  cfg_reg[158]  =       {8'h78, 16'h519e, 8'h38};
assign  cfg_reg[159]  =       {8'h78, 16'h5480, 8'h01};   
                                             
assign  cfg_reg[160]  =       {8'h78, 16'h5481, 8'h08};
assign  cfg_reg[161]  =       {8'h78, 16'h5482, 8'h14};
assign  cfg_reg[162]  =       {8'h78, 16'h5483, 8'h28};
assign  cfg_reg[163]  =       {8'h78, 16'h5484, 8'h51};
assign  cfg_reg[164]  =       {8'h78, 16'h5485, 8'h65};
assign  cfg_reg[165]  =       {8'h78, 16'h5486, 8'h71};
assign  cfg_reg[166]  =       {8'h78, 16'h5487, 8'h7d};
assign  cfg_reg[167]  =       {8'h78, 16'h5488, 8'h87};
assign  cfg_reg[168]  =       {8'h78, 16'h5489, 8'h91};
assign  cfg_reg[169]  =       {8'h78, 16'h548a, 8'h9a};   
                                            
assign  cfg_reg[170]  =       {8'h78, 16'h548b, 8'haa};
assign  cfg_reg[171]  =       {8'h78, 16'h548c, 8'hb8};
assign  cfg_reg[172]  =       {8'h78, 16'h548d, 8'hcd};
assign  cfg_reg[173]  =       {8'h78, 16'h548e, 8'hdd};
assign  cfg_reg[174]  =       {8'h78, 16'h548f, 8'hea};
assign  cfg_reg[175]  =       {8'h78, 16'h5490, 8'h1d};
assign  cfg_reg[176]  =       {8'h78, 16'h5381, 8'h1e};
assign  cfg_reg[177]  =       {8'h78, 16'h5382, 8'h5b};
assign  cfg_reg[178]  =       {8'h78, 16'h5383, 8'h08};
assign  cfg_reg[179]  =       {8'h78, 16'h5384, 8'h0a};  
                                              
assign  cfg_reg[180]  =       {8'h78, 16'h5385, 8'h7e};
assign  cfg_reg[181]  =       {8'h78, 16'h5386, 8'h88};
assign  cfg_reg[182]  =       {8'h78, 16'h5387, 8'h7c};
assign  cfg_reg[183]  =       {8'h78, 16'h5388, 8'h6c};
assign  cfg_reg[184]  =       {8'h78, 16'h5389, 8'h10};
assign  cfg_reg[185]  =       {8'h78, 16'h538a, 8'h01};
assign  cfg_reg[186]  =       {8'h78, 16'h538b, 8'h98};
assign  cfg_reg[187]  =       {8'h78, 16'h5580, 8'h06};
assign  cfg_reg[188]  =       {8'h78, 16'h5583, 8'h40};
assign  cfg_reg[189]  =       {8'h78, 16'h5584, 8'h10};  
                                             
assign  cfg_reg[190]  =       {8'h78, 16'h5589, 8'h10};
assign  cfg_reg[191]  =       {8'h78, 16'h558a, 8'h00};
assign  cfg_reg[192]  =       {8'h78, 16'h558b, 8'hf8};
assign  cfg_reg[193]  =       {8'h78, 16'h501d, 8'h40};
assign  cfg_reg[194]  =       {8'h78, 16'h5300, 8'h08};
assign  cfg_reg[195]  =       {8'h78, 16'h5301, 8'h30};
assign  cfg_reg[196]  =       {8'h78, 16'h5302, 8'h10};
assign  cfg_reg[197]  =       {8'h78, 16'h5303, 8'h00};
assign  cfg_reg[198]  =       {8'h78, 16'h5304, 8'h08};
assign  cfg_reg[199]  =       {8'h78, 16'h5305, 8'h30};  
                                             
assign  cfg_reg[200]  =       {8'h78, 16'h5306, 8'h08};
assign  cfg_reg[201]  =       {8'h78, 16'h5307, 8'h16};
assign  cfg_reg[202]  =       {8'h78, 16'h5309, 8'h08};
assign  cfg_reg[203]  =       {8'h78, 16'h530a, 8'h30};
assign  cfg_reg[204]  =       {8'h78, 16'h530b, 8'h04};
assign  cfg_reg[205]  =       {8'h78, 16'h530c, 8'h06};
assign  cfg_reg[206]  =       {8'h78, 16'h5025, 8'h00};
assign  cfg_reg[207]  =       {8'h78, 16'h3008, 8'h02};
assign  cfg_reg[208]  =       {8'h78, 16'h3035, 8'h11};
assign  cfg_reg[209]  =       {8'h78, 16'h3036, 8'h46}; 
                                            
assign  cfg_reg[210]  =       {8'h78, 16'h3c07, 8'h08};
assign  cfg_reg[211]  =       {8'h78, 16'h3820, 8'h41};
assign  cfg_reg[212]  =       {8'h78, 16'h3821, 8'h07};
assign  cfg_reg[213]  =       {8'h78, 16'h3814, 8'h31};
assign  cfg_reg[214]  =       {8'h78, 16'h3815, 8'h31};
assign  cfg_reg[215]  =       {8'h78, 16'h3800, 8'h00};
assign  cfg_reg[216]  =       {8'h78, 16'h3801, 8'h00};
assign  cfg_reg[217]  =       {8'h78, 16'h3802, 8'h00};
assign  cfg_reg[218]  =       {8'h78, 16'h3803, 8'h04};
assign  cfg_reg[219]  =       {8'h78, 16'h3804, 8'h0a};  
                                           
assign  cfg_reg[220]  =       {8'h78, 16'h3805, 8'h3f};
assign  cfg_reg[221]  =       {8'h78, 16'h3806, 8'h07};
assign  cfg_reg[222]  =       {8'h78, 16'h3807, 8'h9b};
assign  cfg_reg[223]  =       {8'h78, 16'h3808, 8'h03};
assign  cfg_reg[224]  =       {8'h78, 16'h3809, 8'h20};
assign  cfg_reg[225]  =       {8'h78, 16'h380a, 8'h02};
assign  cfg_reg[226]  =       {8'h78, 16'h380b, 8'h58};
assign  cfg_reg[227]  =       {8'h78, 16'h380c, 8'h07};
assign  cfg_reg[228]  =       {8'h78, 16'h380d, 8'h68};
assign  cfg_reg[229]  =       {8'h78, 16'h380e, 8'h03}; 
                                            
assign  cfg_reg[230]  =       {8'h78, 16'h380f, 8'hd8};
assign  cfg_reg[231]  =       {8'h78, 16'h3813, 8'h06};
assign  cfg_reg[232]  =       {8'h78, 16'h3618, 8'h00};
assign  cfg_reg[233]  =       {8'h78, 16'h3612, 8'h29};
assign  cfg_reg[234]  =       {8'h78, 16'h3709, 8'h52};
assign  cfg_reg[235]  =       {8'h78, 16'h370c, 8'h03};
assign  cfg_reg[236]  =       {8'h78, 16'h3a02, 8'h17};
assign  cfg_reg[237]  =       {8'h78, 16'h3a03, 8'h10};
assign  cfg_reg[238]  =       {8'h78, 16'h3a14, 8'h17};
assign  cfg_reg[239]  =       {8'h78, 16'h3a15, 8'h10}; 
                                           
assign  cfg_reg[240]  =       {8'h78, 16'h4004, 8'h02};
assign  cfg_reg[241]  =       {8'h78, 16'h3002, 8'h1c};
assign  cfg_reg[242]  =       {8'h78, 16'h3006, 8'hc3};
assign  cfg_reg[243]  =       {8'h78, 16'h4713, 8'h03};
assign  cfg_reg[244]  =       {8'h78, 16'h4407, 8'h04};
assign  cfg_reg[245]  =       {8'h78, 16'h460b, 8'h35};
assign  cfg_reg[246]  =       {8'h78, 16'h460c, 8'h22};
assign  cfg_reg[247]  =       {8'h78, 16'h4837, 8'h22};
assign  cfg_reg[248]  =       {8'h78, 16'h3824, 8'h02}; 
assign  cfg_reg[249]  =       {8'h78, 16'h5001, 8'ha3}; 
                                            
assign  cfg_reg[250]  =       {8'h78, 16'h3503, 8'h00};
assign  cfg_reg[251]  =       {8'h78, 16'h3035, 8'h41};       // PLL     input clock =24Mhz, PCLK =84Mhz
assign  cfg_reg[252]  =       {8'h78, 16'h3036, 8'h69};
assign  cfg_reg[253]  =       {8'h78, 16'h3c07, 8'h07};
assign  cfg_reg[254]  =       {8'h78, 16'h3820, 8'h47};
assign  cfg_reg[255]  =       {8'h78, 16'h3821, 8'h07};
assign  cfg_reg[256]  =       {8'h78, 16'h3814, 8'h31};
assign  cfg_reg[257]  =       {8'h78, 16'h3815, 8'h31};
assign  cfg_reg[258]  =       {8'h78, 16'h3800, 8'h00};       // HS
assign  cfg_reg[259]  =       {8'h78, 16'h3801, 8'h00};       // HS
                                             
assign  cfg_reg[260]  =       {8'h78, 16'h3802, 8'h00};       // VS
assign  cfg_reg[261]  =       {8'h78, 16'h3803, 8'hfa};       // VS
assign  cfg_reg[262]  =       {8'h78, 16'h3804, 8'h0a};       // HW (HE)
assign  cfg_reg[263]  =       {8'h78, 16'h3805, 8'h3f};       // HW (HE)
assign  cfg_reg[264]  =       {8'h78, 16'h3806, 8'h06};       // VH (VE)
assign  cfg_reg[265]  =       {8'h78, 16'h3807, 8'ha9};       // VH (VE)
assign  cfg_reg[266]  =       {8'h78, 16'h3808, 8'h04};       // DVPHO     (1024)
assign  cfg_reg[267]  =       {8'h78, 16'h3809, 8'h00};       // DVPHO     (1024)
assign  cfg_reg[268]  =       {8'h78, 16'h380a, 8'h02};       // DVPVO     (720)
assign  cfg_reg[269]  =       {8'h78, 16'h380b, 8'hd0};       // DVPVO     (720)
                                            
assign  cfg_reg[270]  =       {8'h78, 16'h380c, 8'h07};       // HTS       (1892)  1892*740*65 = 95334200  /  90994176
assign  cfg_reg[271]  =       {8'h78, 16'h380d, 8'h64};       // HTS
assign  cfg_reg[272]  =       {8'h78, 16'h380e, 8'h02};       // VTS       (740)
assign  cfg_reg[273]  =       {8'h78, 16'h380f, 8'he4};       // VTS
assign  cfg_reg[274]  =       {8'h78, 16'h3813, 8'h04};       // timing V offset
assign  cfg_reg[275]  =       {8'h78, 16'h3618, 8'h00};
assign  cfg_reg[276]  =       {8'h78, 16'h3612, 8'h29};
assign  cfg_reg[277]  =       {8'h78, 16'h3709, 8'h52};
assign  cfg_reg[278]  =       {8'h78, 16'h370c, 8'h03};
assign  cfg_reg[279]  =       {8'h78, 16'h3a02, 8'h02}; 
                                              
assign  cfg_reg[280]  =       {8'h78, 16'h3a03, 8'he0};
assign  cfg_reg[281]  =       {8'h78, 16'h3a08, 8'h00};
assign  cfg_reg[282]  =       {8'h78, 16'h3a09, 8'h6f};
assign  cfg_reg[283]  =       {8'h78, 16'h3a0a, 8'h00};
assign  cfg_reg[284]  =       {8'h78, 16'h3a0b, 8'h5c};
assign  cfg_reg[285]  =       {8'h78, 16'h3a0e, 8'h06};
assign  cfg_reg[286]  =       {8'h78, 16'h3a0d, 8'h08};
assign  cfg_reg[287]  =       {8'h78, 16'h3a14, 8'h02};
assign  cfg_reg[288]  =       {8'h78, 16'h3a15, 8'he0};
assign  cfg_reg[289]  =       {8'h78, 16'h4004, 8'h02}; 
                                             
assign  cfg_reg[290]  =       {8'h78, 16'h3002, 8'h1c};
assign  cfg_reg[291]  =       {8'h78, 16'h3006, 8'hc3};
assign  cfg_reg[292]  =       {8'h78, 16'h4713, 8'h03};
assign  cfg_reg[293]  =       {8'h78, 16'h4407, 8'h04};
assign  cfg_reg[294]  =       {8'h78, 16'h460b, 8'h37};
assign  cfg_reg[295]  =       {8'h78, 16'h460c, 8'h20};
assign  cfg_reg[296]  =       {8'h78, 16'h4837, 8'h16};
assign  cfg_reg[297]  =       {8'h78, 16'h3824, 8'h04};       // PCLK manual divider
assign  cfg_reg[298]  =       {8'h78, 16'h5001, 8'h83};
assign  cfg_reg[299]  =       {8'h78, 16'h3503, 8'h00}; 
                                           
assign  cfg_reg[300]  =       {8'h78, 16'h3016, 8'h02};
assign  cfg_reg[301]  =       {8'h78, 16'h3b07, 8'h0a};
assign  cfg_reg[302]  =       {8'h78, 16'h3b00, 8'h83};
assign  cfg_reg[303]  =       {8'h78, 16'h3b00, 8'h00};
//-----------------------------------------------------------------------------

endmodule