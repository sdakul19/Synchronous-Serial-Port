/*
 * Author: Sam Rojanasakdakul
 * 
 * Description: A testbench for the looped synchronous serial port where the receive FIFO and transmit FIFO are connected.
 *		The serial output of the transmit FIFO becomes the serial input of the receive FIFO.
 */
module SSP_tb2();					//Testing looped SSP with transmit wire to receive

	reg pclk;					//Clock for Serial Synchronous Port
	reg clear_b;					//Low active clear signal
	reg psel;					//Chip select signal
	reg pwrite;					//Write/Read signal
	reg [7:0] pwdata;				//8-bit transmission data

	wire [7:0] prdata;				//8-bit receive data
	wire sspoe_b;					//Active low output enable signal
	wire tx_to_rx;					//Serial transmit output data from SSP enters as serial receive input data
	wire clk_wire;					//sspclkout wires to sspclkin
	wire fss_wire;					//sspfssout wires to sspfssin
	wire ssptxintr;					//Transmission interrupt signal
	wire ssprxintr;					//Receive interrupt signal
	
	always #5 pclk = ~pclk;
	
	SSP SSP2_instance(
		.pclk(pclk),
		.clear_b(clear_b),
		.psel(psel),
		.pwrite(pwrite),
		.sspclkin(clk_wire),
		.sspfssin(fss_wire),
		.ssprxd(tx_to_rx),
		.pwdata(pwdata),
		.ssptxintr(ssptxintr),
		.ssprxintr(ssprxintr),
		.ssptxd(tx_to_rx),
		.sspoe_b(sspoe_b),
		.sspfssout(fss_wire),
		.sspclkout(clk_wire),
		.prdata(prdata)
	);

	initial begin
		$monitor($time,"sspclk = %b pwdata = %b prdata = %b", clk_wire, pwdata, prdata); 
		pclk = 0;
		clear_b = 0;
		psel = 1;
		pwdata = 8'hFF;
		
		#10
		clear_b = 1;
		pwrite = 1;
		pwdata = 8'h51; 

		#10
		pwdata = 8'h24;

		#10
		pwdata = 8'h67;

		#10
		pwdata = 8'hF3;

		#10
		pwdata = 8'hB6;

		#10
		pwdata = 8'h84;
		
		#10
		psel = 0;
		pwdata = 8'h00;

		#800
		psel = 1;
		pwrite = 0;
	end
endmodule
