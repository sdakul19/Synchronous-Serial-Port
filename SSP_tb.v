module SSP_tb();						//Testing transmitting data

	reg pclk;
	reg clear_b;
	reg psel;
	reg pwrite;
	reg sspfssin;
	reg ssprxd;
	reg [7:0] pwdata;
	reg sspclkin;

	wire ssptxintr;
	wire ssprxintr;
	wire ssptxd;
	wire sspoe_b;
	wire sspfssout;
	wire [7:0] prdata;
	wire sspclkout;

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

	initial begin
		pclk = 0;
		sspclkin = 0;
		sspfssin = 0;
		ssprxd = 0;
		clear_b = 0;
		psel = 1;
		pwdata = 8'hFF;
		
		#10
		clear_b = 1;
		pwrite = 1;
		pwdata = 8'h0F;
		
		
		#10
		clear_b = 1;
		pwrite = 1;
		pwdata = 8'b10101010;
		
		#10
		pwdata = 8'b11110000;

		#10
		pwdata = 8'b01010101;

		#10
		pwdata = 8'b00001111;
		
		#10
		pwdata = 8'b11111111;

		#10
		psel = 0;
		
	end
	
endmodule
