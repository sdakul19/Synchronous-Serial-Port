/*
 * Author: Sam Rojanasakdakul
 * 
 * Description: Test bench module of the receive FIFO
 *
 */
module RxFIFO_tb();

	reg pclk;			//Clock for synchronous serial port
	reg clear_b;			//Low active clear signal
	reg psel;			//Chip select signal
	reg pwrite;			//Read signal when pwrite = 0
	reg w_en;			//Write enable to the fifo
	reg [7:0] rxdata;		//8 bit receive data input into the FIFO
	
	wire ssprxintr;			//Interrupt signal if FIFO is full
	wire [7:0] prdata;		//8 bit receive data being read out

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
    
    	initial begin			//Initializes data
        	pclk = 0;
        	clear_b = 0;
        	psel = 1;
        	pwrite = 1;
        	w_en = 1;
        	rxdata = 8'h00;
        
        	#10			//Stores 8'h00 in first lcoation
        	clear_b = 1;
		psel = 0;
		pwrite = 0;
        	rxdata = 8'h00;
        
        	#10    			//Stores 8'h01 in second location
        	rxdata = 8'h01;
        
        	#10 			//Stores 8'h02 in third location
        	rxdata = 8'h02;
        
        	#10			//Stores 8'h03 in fourth location
        	rxdata = 8'h03;
        
        	#10			//Fails to store 8'h04 because FIFO is full
        	rxdata = 8'h04;

		#10			//Receive FIFO is activated and data should be read off from FIFO
		psel = 1;
		 
    	end
endmodule

