`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:57:34 09/10/2020
// Design Name:   ov5640_sdram_vga_top
// Module Name:   C:/Users/shjiang/Desktop/Xilinx Projects/OV5640_SDRAM_VGA/tb_top.v
// Project Name:  OV5640_SDRAM_VGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ov5640_sdram_vga_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_top;

	// Inputs
	reg osc_clk_50;
	reg reset;
	reg cmos_pclk;
	reg cmos_href;
	reg cmos_vsync;
	reg [7:0] cmos_d;

	// Outputs
	wire cmos_xclk;
	wire cmos_reset;
	wire cmos_pwdn;
	wire cmos_sclk;
	wire CLK;
	wire CKE;
	wire cs_n;
	wire ras_n;
	wire cas_n;
	wire we_n;
	wire [12:0] addr;
	wire [1:0] ba;
	wire [1:0] dqm;
	wire h_sync;
	wire v_sync;
	wire [4:0] red;
	wire [5:0] green;
	wire [4:0] blue;

	// Bidirs
	wire cmos_sdat;
	wire [15:0] dq;

	// Instantiate the Unit Under Test (UUT)
	ov5640_sdram_vga_top uut (
		.osc_clk_50(osc_clk_50), 
		.reset(reset), 
		.cmos_xclk(cmos_xclk), 
		.cmos_reset(cmos_reset), 
		.cmos_pwdn(cmos_pwdn), 
		.cmos_sclk(cmos_sclk), 
		.cmos_sdat(cmos_sdat), 
		.cmos_pclk(cmos_pclk), 
		.cmos_href(cmos_href), 
		.cmos_vsync(cmos_vsync), 
		.cmos_d(cmos_d), 
		.CLK(CLK), 
		.CKE(CKE), 
		.cs_n(cs_n), 
		.ras_n(ras_n), 
		.cas_n(cas_n), 
		.we_n(we_n), 
		.addr(addr), 
		.ba(ba), 
		.dqm(dqm), 
		.dq(dq), 
		.h_sync(h_sync), 
		.v_sync(v_sync), 
		.red(red), 
		.green(green), 
		.blue(blue)
	);
	
	sdram_model_plus sdram_model_plus_inst(
    .Clk                    (   CLK             ),
    .Cke                    (   CKE             ),
    .Cs_n                   (   cs_n            ),
    .Ras_n                  (   ras_n           ),
    .Cas_n                  (   cas_n           ),
    .We_n                   (   we_n            ),
    .Addr                   (   addr            ),
    .Ba                     (   ba              ),
    .Dqm                    (   dqm             ),
    .Dq                     (   dq              ),
    .Debug                  (   1'b1            )
);

	initial begin
		// Initialize Inputs
		osc_clk_50 = 0;
		reset = 0;
		cmos_pclk = 0;
		cmos_href = 0;
		cmos_vsync = 0;
		cmos_d = 0;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 1;
      #100;
 		
		// Add stimulus here
      

	end
 always #10 osc_clk_50 = ~osc_clk_50;
 always #10 cmos_pclk = ~cmos_pclk;
 
endmodule

