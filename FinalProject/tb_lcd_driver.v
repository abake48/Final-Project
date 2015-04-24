`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:26:35 04/24/2015
// Design Name:   lcd_driver
// Module Name:   E:/CSD Labs/Final Lab/FinalProject/tb_lcd_driver.v
// Project Name:  FinalProject
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: lcd_driver
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_lcd_driver;

	// Inputs
	reg [7:0] data_value;
	reg write_to_lcds;
	reg clk;
	reg reset;

	// Outputs
	wire [3:0] LCD_DATA;
	wire enable;
	wire rw;
	wire rs;

	// Instantiate the Unit Under Test (UUT)
	lcd_driver uut (
		.data_value(data_value), 
		.LCD_DATA(LCD_DATA), 
		.write_to_lcds(write_to_lcds), 
		.enable(enable), 
		.rw(rw), 
		.rs(rs), 
		.clk(clk), 
		.reset(reset)
	);

	always begin
		clk = 0;
		#5;
		clk = 1;
		#5;
	
	end

	initial begin
		// Initialize Inputs
		data_value = 8'b01100111;
		write_to_lcds = 0;
		reset = 0;
		// Wait 100 ns for global reset to finish
		#10;
        write_to_lcds = 1;
		// Add stimulus here

	end
      
endmodule

