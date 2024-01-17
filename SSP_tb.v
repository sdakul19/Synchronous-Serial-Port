/*
 * Author: Sam Rojanasakdakul
 * 
 * Description: A testbench for the non-looped synchronous serial port where the receive FIFO and transmit FIFO are not connected
 *		It tests the parallel to serial conversion through the SSP by defining the pwdata.
 */
module SSP_tb();						//Testing transmitting data

	reg pclk;			//Clock for Serial Synchronous Port
	reg clear_b;			//Low active clear signal
	reg psel;			//Chip select signal
	reg pwrite;			//Write/Read signal
	reg sspfssin;			//Frame control signal for reception
	reg ssprxd;			//Serial data input
	reg [7:0] pwdata;		//8-bit transmission data
	reg sspclkin;			//Synchronization clock for receive

	wire ssptxintr;			//Transmission interrupt signal
	wire ssprxintr;			//Receive interrupt signal
	wire ssptxd;			//Serial data output
	wire sspoe_b;			//Active low output enable signal
	wire sspfssout;			//Frame control signal for transmission
	wire [7:0] prdata;		//8-bit receive data
	wire sspclkout;			//Synchronization clock for transmission

	SSP SSP_instance(
		.pclk(pclk),
		.clear_b(clear_b),
		.psel(psel),
		.pwrite(pwrite),
		.sspclkin(sspclkin),
		.sspfssin(sspfssin),
		.ssprxd(ssprxd),
		.pwdata(pwdata),
		.ssptxintr(ssptxintr),
		.ssprxintr(ssprxintr),
		.ssptxd(ssptxd),
		.sspoe_b(sspoe_b),
		.sspfssout(sspfssout),
		.sspclkout(sspclkout),
		.prdata(prdata)
	);

	always #5 pclk = ~pclk;

	initial begin				//initializes SSP
		pclk = 0;
		sspclkin = 0;
		sspfssin = 0;
		ssprxd = 0;
		clear_b = 0;
		psel = 1;
		pwdata = 8'hFF;
		
		#10				//Preparing SSP to write
		clear_b = 1;
		pwrite = 1;
		pwdata = 8'h0F;
		
		
		#10				//Stores 8'b10101010 to transmit fifo	
		pwdata = 8'b10101010;
		
		#10				//Stores 8'b11110000 to transmit fifo and serial outputs 8'b10101010
		pwdata = 8'b11110000;

		#10				//Stores 8'b01010101 to transmit fifo and serial outputs 8'b11110000
		pwdata = 8'b01010101;

		#10				//Stores 8'b00001111 to transmit fifo and serial outputs 8'b01010101
		pwdata = 8'b00001111;	
		
		#10				//Stores 8'b11111111 to transmit fifo and serial outputs 8'b00001111
		pwdata = 8'b11111111;

		#10				//Serial outputs 8'b11111111 and deactivates SSP
		psel = 0;
		
	end
	
endmodule
