module SSP(
	input pclk,			//Clock for Serial Synchronous Port
	input clear_b,			//Low active clear signal
	input psel,			//Chip select signal
	input pwrite,			//Write/Read signal
	input sspclkin,			//Synchronization clock for receive
	input sspfssin,			//Frame control signal for reception
	input ssprxd,			//Serial data input
	input [7:0] pwdata,		//8-bit transmission data
	output ssptxintr,		//Transmission interrupt signal
	output ssprxintr,		//Receive interrupt signal
	output reg ssptxd,		//Serial data output
	output reg sspoe_b,		//Active low output enable signal
	output reg sspfssout,		//Frame control signal for transmission
	output reg sspclkout,		//Synchronization clock for transmission
	output [7:0] prdata		//8-bit receive data
);

	reg [7:0] txshiftreg;		//Shift register for transmission
	reg [7:0] rxshiftreg;		//Shift register for receive
	reg t_en;			//Transmission enable signal to TxFIFO
	reg w_en;			//Write enable signal to RxFIFO

	wire [7:0] txdata;		//Transmission data to shift register
	reg [7:0] rxdata;		//Receive data to RxFIFO
	wire ready;			//Ready signal from TxFIFO when not empty

	integer tcount;			//Counter for transmit shift register
	integer rcount;			//Counter for receive shift register

	TxFIFO TxFIFO_instance(		
		.pclk(pclk),
		.clear_b(clear_b),
		.psel(psel),
		.pwrite(pwrite),	
		.t_en(t_en),
		.ready(ready),
		.pwdata(pwdata),
		.ssptxintr(ssptxintr),
		.txdata(txdata)
	);
	
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
	
	always @(posedge pclk) begin			

		if(!clear_b) begin				//Initializes all registers
			sspclkout <= 0;
			txshiftreg <= 0;
			rxshiftreg <= 0;
			t_en <= 0;
			w_en <= 0;
			rxdata <= 0;
			sspoe_b <= 1;
			sspfssout <= 0;
			tcount <= 0;
			rcount <= -1;				//Initial rcount needs to be -1 to adjust for extra shift at start
		end
		else begin
			sspclkout <= ~sspclkout;		//SSP clock operates twice slower than the pclock
		end
		
		if(ready && txshiftreg == 0 && tcount == 0) begin	//Activates the transmit enable signal at start
			t_en <= 1;
		end
		else if (ready && tcount == 7) begin			//Activates the transmit enable signal when the transmit shift register is shifting out the last bit
			t_en <= 1;
		end
		else begin
			t_en <= 0;
		end

		if(w_en) begin						//Turns off write enable signal after 1 pclk cycle
			w_en <= 0;
		end
	end
	
	
	always @(posedge sspclkout) begin					//Transmit logic
		
		if(ready && (txshiftreg == 0) && (tcount == 0)) begin		//At start, sspfssout is high and the transmit shift register accepts the transmit data from TxFIFO
			sspfssout <= 1;
			txshiftreg <= txdata;
			tcount <= 0;
			
		end
		else if (!sspoe_b && tcount != 8) begin				//Serializes the transmit data through the shift register
			sspfssout <= 0;
			{ssptxd, txshiftreg} <= txshiftreg << 1;
			tcount <= tcount + 1;
		end
		else begin							//Set everything to 0
			txshiftreg <= 0;
			ssptxd <= 0;
			tcount <= 0;
		end
		
		if (ready && tcount == 7) begin					//When the shift register is shifting out the last bit, accept the next transmit data from TxFIFO
			txshiftreg <= txdata;
			sspfssout <= 1;
			tcount <= 0;
		end
		
		
	end
	
	always @(posedge sspclkin) begin					//Receive logic

		if(!sspoe_b && rcount == -1) begin				//At start, shift in the first serial data into the shift register
			rxshiftreg <= {rxshiftreg[6:0], ssprxd};		
			rcount <= rcount + 1;
		end
		else if (sspoe_b && rcount == -1) begin				//At start keep the rcount at -1 in order to properly sync the shifting count
			rcount <= -1;
		end
		else if (rcount != 8) begin					//Parallelizes the serial data through the shift register
			rxshiftreg <= {rxshiftreg[6:0], ssprxd};
			rcount <= rcount + 1;
		end
		else if (sspoe_b && rcount == 8) begin				//If no more serial data is coming, send out the last set of parallel data in the shift register
			rxdata <= rxshiftreg;
			rcount <= -1;
		end
		else begin							//When the shift register loads in the last bit, shift in the next one and set the counter to 1
			rxdata <= rxshiftreg;
			rxshiftreg <= {rxshiftreg[6:0], ssprxd};
			rcount <= 1;
		end		
		
	end
	
	always @(txdata) begin							//Turns of t_en after data is sent out from TxFIFO
		t_en <= 0;
	end
	
	always @(rxdata) begin							//Turns on w_en after data is sent to RxFIFO
		if(rxdata == 0) begin
			w_en <= 0;
		end 
		else begin
			w_en <= 1;
		end
	end
	
	always @(negedge sspclkout) begin					//Sets sspoe_b when valid data is leaving or entering

		if(!clear_b) begin
			sspoe_b <= 1;
		end
		else if (sspfssout == 1) begin
			sspoe_b <= 0;
		end
		else if (tcount == 8) begin
			sspoe_b <= 1;
		end 
		
	end
endmodule
