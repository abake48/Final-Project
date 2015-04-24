`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:48 04/19/2015 
// Design Name: 
// Module Name:    LCD_testing 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LCD_testing( switches, leds, LCD_DATA, EN, RS, RW, up, down, center, rs232_tx, rs232_rx, reset, clk );

	// Top-level Inputs and Outputs
	// These connect directly to FPGA pins via the pin map
	//
	// Control - clk, rst, etc
	input	reset;			// Remember: ACTIVE LOW!!!
	input	clk;			// 100 MHz
	
	// GPIO
	input	[7:0]	switches;
	output[7:0]	leds;
	output [3:0] LCD_DATA;
	output RS;
	output RW;
	output EN;
	input up;
	input down;
	input center;
	
	// RS232 Lines
	input		rs232_rx;
	output	rs232_tx;
	
	// Wires and Register Declarations
	//
	// PicoBlaze Data Lines
	wire	[7:0]	pb_port_id;
	wire	[7:0]	pb_out_port;
	reg	[7:0]	pb_in_port;
	wire			pb_read_strobe;
	wire			pb_write_strobe;
	
	
	// PicoBlaze CPU Control Wires
	wire			pb_reset;
	wire			pb_interrupt;
	wire			pb_int_ack;
	
	// UART wires
	wire			write_to_uart;
	wire			uart_buffer_full;
	wire			uart_data_present;
	reg			read_from_uart;
	wire			uart_reset;
	wire [7:0]	lcdwire;
	wire			write_enable;
	
	// UART Data Lines
	// TX does not need a wire, as it is fed directly by pb_out_port
	wire	[7:0]	uart_rx_data;
	
	// LED wires
	wire write_to_leds;
	wire led_reset;
	
	//LCD Wire
	
	lcd_driver mylcddriver(
			.data_value(pb_out_port), //comes from pico
			.LCD_DATA(LCD_DATA),
			.enable(EN),
			.rw(RW),
			.rs(RS),
			.write_to_lcds(lcdwire),
			.clk(clk),
			.reset(~reset)
	);

/*
	// LED Driver and control logic
	//
	// LED driver expects ACTIVE-HIGH reset
	assign led_reset = ~reset;
	// LED driver instantiation
	*/
	led_driver_wrapper led_driver (
		.led_value(pb_out_port),
		.leds(leds),
		.write_to_leds(write_to_leds),
		.reset(led_reset),
		.clk(clk)
	);

	
	// UART and control logic
	//
	// UART expects ACTIVE-HIGH reset	
	assign uart_reset =  ~reset;
	// UART instantiation
	//
	// Within the UART Module (rs232_uart.v), make sure you fill in the
	// appropriate sections.
/*	rs232_uart UART (
		.tx_data_in(pb_out_port), // The UART only accepts data from PB, so we just tie the PB output to the UART input.
		.write_tx_data(write_to_uart), // Goes high when PB sends write strobe and PORT_ID is the UART write port number
		.tx_buffer_full(uart_buffer_full),
		.rx_data_out(uart_rx_data),
		.read_rx_data_ack(read_from_uart),
		.rx_data_present(uart_data_present),
		.rs232_tx(rs232_tx),
		.rs232_rx(rs232_rx),
		.reset(uart_reset),
		.clk(clk)
	);	
*/
	// PicoBlaze and control logic
	//
	// PB expects ACTIVE-HIGH reset
	assign pb_reset = ~reset;
	// Disable interrupt by assigning 0 to interrupt
	assign pb_interrupt = 1'b0;
	// PB CPU instantiation
	//
	// Within the PicoBlaze Module (picoblaze.v), make sure you fill in the
	// appropriate sections.
	picoblaze CPU (
		.port_id(pb_port_id),
		.read_strobe(pb_read_strobe),
		.in_port(pb_in_port),
		.write_strobe(pb_write_strobe),
		.out_port(pb_out_port),
		.interrupt(pb_interrupt),
		.interrupt_ack(),
		.reset(pb_reset),
		.clk(clk)
	);	
/*
	// PB I/O selection/routing
	//
	// Handle PicoBlaze Output Port Logic
	// Output Ports:
	// * leds_out : port 01
	// * uart_data_tx : port 03
	//
	// These signals are effectively "write enable" lines for the UART and LED
	// Driver modules. They must be asserted when PB is outputting to the
	// corresponding port
	assign write_to_leds = pb_write_strobe & (pb_port_id == 8'h01);
	assign write_to_uart = pb_write_strobe & (pb_port_id == 8'h03);
	//
	// Handle PicoBlaze Input Port Logic
	// Input Ports:
	// * switches_in : port 00
	// * uart_data_rx : port 02
	// * uart_data_present : port 04 (1-bit, assigned to LSB)
	// * uart_buffer_full: port 05 (1-bit, assigned to LSB)
	//
	// This process block gets the value of the requested input port device
	// and passes it to PBs in_port. When PB is not requestng data from
	// a valid input port, set the input to static 0.
*/
	assign lcdwire = pb_write_strobe & (pb_port_id == 8'h03); 
	//assign write_to_leds = pb_write_strobe & (pb_port_id == 8'h01);
	//assign write_enable = pb_write_strobe & (pb_port_id == 8'h04);
	//assign write_reg_select = pb_write_strobe & (pb_port_id == 8'h05);
	//assign write_read_write = pb_write_strobe & (pb_port_id == 8'h06);
	
	
	always @(posedge clk or posedge pb_reset)
	begin
		if(pb_reset) begin
			pb_in_port <= 0;
			read_from_uart <= 0;
		end else begin
			// Set pb input port to appropriate value
			case(pb_port_id)
				8'h00: pb_in_port <= up;
				8'h01: pb_in_port <= down;
				8'h02: pb_in_port <= center;
			// 8'h00: pb_in_port <= switches; //port 07 for testing
			//	8'h03: pb_in_port <= LCD_DATA;
			//	8'h04: pb_in_port <= EN;
			//	8'h05: pb_in_port <= RS;
			//	8'h06: pb_in_port <= RW;
				default: pb_in_port <= 0;
			endcase
			// Set up acknowledge/enable signals.
			//
			// Some modules, such as the UART, need confirmation that the data
			// has been read, since it needs to push it off the queue and make
			// the next byte available. This logic will set the 'read_from'
			// signal high for corresponding ports, as needed. Most input
			// ports will not need this.
			//we think it is on rx_data when the read strobe is high GS
		end
	end

endmodule

module lcd_driver(data_value, LCD_DATA, write_to_lcds, enable, rw, rs, clk, reset );
	input [7:0] data_value;
	output reg [3:0] LCD_DATA;
	output reg enable;
	output reg rw;
	output reg rs;
	input write_to_lcds;
	input clk;
	input reset;
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin 
			LCD_DATA <= 0;
			rs <= 0;
			rw <= 0;
			enable <= 0;
		end else if(write_to_lcds) begin
			LCD_DATA <= data_value[7:4];
			rs <= data_value[2];
			rw <= data_value[1];
			enable <= data_value[0];
		end
	end
endmodule

//led module for testing 
module led_driver_wrapper( led_value, leds, write_to_leds, clk, reset );
	input [7:0] led_value;
	output reg [7:0] leds;
	input write_to_leds;
	input clk;
	input reset;
	
	always @(posedge clk or posedge reset) begin
		if(reset) leds <= 0;
		else if(write_to_leds) leds <= led_value;
	end

endmodule

