module RxFIFO_tb();

	reg pclk;
	reg clear_b;
	reg psel;
	reg pwrite;
	reg w_en;
	reg [7:0] rxdata;
	
	wire ssprxintr;
	wire [7:0] prdata;

	RxFIFO RxFIFO_instance(
		.pclk(pclk),
		.clear_b(clear_b),
		.psel(psel),
		.pwrite(pwrite),
		.w_en(w_en),
		.rxdata(rxdata),
		.ssprxintr(ssprxintr),
		.prdata(prdata)
	);

	always #5 pclk = ~pclk;
    
    	initial begin
        	pclk = 0;
        	clear_b = 0;
        	psel = 1;
        	pwrite = 1;
        	w_en = 1;
        	rxdata = 8'h00;
        
        	#10
        	clear_b = 1;
		psel = 0;
		pwrite = 0;
        	rxdata = 8'h00;
        
        	#10    
        	rxdata = 8'h01;
        
        	#10 
        	rxdata = 8'h02;
        
        	#10
        	rxdata = 8'h03;
        
        	#10
        	rxdata = 8'h04;

		#10
		psel = 1;
		 
    	end
endmodule

