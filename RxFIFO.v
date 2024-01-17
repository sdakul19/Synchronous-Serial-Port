module RxFIFO(
	input pclk,				//Clock for synchronous serial port
	input clear_b,				//Low active clear signal
	input psel,				//Chip select signal
	input pwrite,				//Read signal when pwrite = 0
	input w_en,				//Write enable to the fifo
	input [7:0] rxdata,			//8 bit receive data input into the FIFO
	output reg ssprxintr,			//Interrupt signal if FIFO is full
	output reg [7:0] prdata			//8 bit receive data being read out
);

	reg [7:0] queue [3:0];			//FIFO memory
	reg [1:0] wptr;				//Write pointer
	reg [1:0] rptr;				//Read pointer
	integer count;				//Count that keeps track of number of words in the memory
	integer i;				//Integer for loops

	always @(posedge pclk) begin
	    	
		if (psel) begin						//When psel is active high activate the receive FIFO
			
    	    		if(!clear_b) begin				//Active low clear that initializes the memory
    	        		for(i = 0; i < 4; i = i + 1) begin
    	            			queue[i] <= 0;
    	        		end
    	        		count <= 0;
    	        		wptr <= 0;
    	        		rptr <= 0;
    	        		ssprxintr <= 0;
				prdata <= 0;
    	    		end 
    	    		else if (!pwrite && count > 0) begin				//Read from the FIFO memory
    	            		prdata <= queue[rptr];
				queue[rptr] <= 0;
				rptr <= rptr + 1;
				count <= count - 1;           
    	    		end
		end
 
		if (!ssprxintr && w_en) begin				//Write to the receive FIFO
			queue[wptr] <= rxdata;
    	            	wptr <= wptr + 1;
    	        	count <= count + 1;
		end

		if (wptr > 3) begin					//If wptr reaches the end, set to 0
    	    		wptr <= 0;
    		end
    	
    		if (rptr > 3) begin					//If rptr reaches the end, set to 0
    	    		rptr <= 0;
    		end   
	end

	always @(count) begin						//Updates count and sets interrupt signal
		if (count == 4) begin
			ssprxintr <= 1;
		end 
		else if (count < 0) begin
			count <= 0;
		end
		else begin
			ssprxintr <= 0;
		end
	end

endmodule
