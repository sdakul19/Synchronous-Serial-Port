module SSP_tb2();					//Testing looped SSP with transmit wire to receive

	reg pclk;
	reg clear_b;
	reg psel;
	reg pwrite;
	reg [7:0] pwdata;

	wire [7:0] prdata;
	wire sspoe_b;
	wire tx_to_rx;					//Serial transmit output data from SSP enters as serial receive input data
	wire clk_wire;					//sspclkout wires to sspclkin
	wire fss_wire;					//sspfssout wires to sspfssin
	wire ssptxintr;
	wire ssprxintr;
	
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