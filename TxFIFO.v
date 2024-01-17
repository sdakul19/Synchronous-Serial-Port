module TxFIFO(
	input pclk,			//Clock for Synchronous Serial Port
	input clear_b,			//Low active clear signal
	input psel,			//Chip select signal
	input pwrite,			//Write signal 		
	input [7:0] pwdata,		//8 bit data that stores into the FIFO
	input t_en,			//Transmit enable signal to allow word to be read 
	output reg ready,		//Ready signal when there is a word in the bottom of the FIFO
	output reg ssptxintr,		//Interupt signal if FIFO is full
	output reg [7:0] txdata		//Data being transmitted from the FIFO
);
	reg [7:0] queue[3:0];		//FIFO memory
	reg [1:0] wptr;			//Write pointer pointing to where to write the incoming data
	reg [1:0] rptr;			//Read pointer pointing to where to read the data
	integer count;			//Count that keeps track of number of words in the memory
	
	integer i;			//Integer for loops
	
	always @(posedge pclk) begin
	    	
		
		if (psel) begin						//When psel is active high activate the transmit FIFO
			
    	    		if(!clear_b) begin				//Active low clear that initializes the memory
    	        		for(i = 0; i < 4; i = i + 1) begin
    	            			queue[i] <= 0;
    	        		end
    	        		count <= 0;
    	        		wptr <= 0;
    	        		rptr <= 0;
    	        		ssptxintr <= 0;
				txdata <= 0;
				ready <= 0;
    	    		end 
    	    		else if (pwrite && !ssptxintr) begin			//Write to the FIFO memory
    	            		queue[wptr] <= pwdata;
    	            		wptr <= wptr + 1;
    	            		count <= count + 1;            
    	    		end 
    	    
    	   	end
		
   	    	if (t_en) begin						//Read from transmit FIFO
    	        	txdata <= queue[rptr];
    	        	queue[rptr] <= 0;
    	        	rptr <= rptr + 1;
			
            	end
		
    		if (wptr > 3) begin					//If wptr reaches the end, set to 0
    	    		wptr <= 0;
    		end
    	
    		if (rptr > 3) begin					//If rptr reaches the end, set to 0
    	    		rptr <= 0;
    		end 
		
	end
	
	always @(negedge pclk) begin					//Updates count and sets interrupt signal
				
		if (count == 4) begin					
			ssptxintr <= 1;
		end 
		else if (count > 0) begin
			ssptxintr <= 0;
			ready <= 1;
		end
		else begin
			count <= 0;
			ready <= 0;
		end
	end

	always @(rptr) begin						//Fixes count when FIFO is reading and writing at the same time
		if(!clear_b) begin
			count <= 0;
		end
		else begin
			count <= count - 1;
		end
	end
endmodule 
