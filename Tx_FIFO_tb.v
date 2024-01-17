module Tx_FIFO_tb();
    reg pclk;
    reg clear_b;
    reg psel;
    reg pwrite;
    reg t_en;
    reg [7:0] pwdata;
    
    wire ssptxintr;
    wire [7:0] txdata;

    TxFIFO TxFIFO_instance(
        .pclk(pclk),
        .clear_b(clear_b),
        .psel(psel),
        .pwrite(pwrite),
        .t_en(t_en),
        .pwdata(pwdata),
        .ssptxintr(ssptxintr),
        .txdata(txdata)
    );
    
    always #5 pclk = ~pclk;
    
    initial begin
        pclk = 0;
        clear_b = 0;
        psel = 1;
        pwrite = 1;
        t_en = 0;
        pwdata = 8'h00;
        
        #10
        clear_b = 1;
        pwdata = 8'h00;
        
        #10    
        pwdata = 8'h01;
        
        #10 
        pwdata = 8'h02;
        
        #10
        pwdata = 8'h03;
        
        #10
        pwdata = 8'h04;

	#10
	t_en = 1; 
    end
    
    
	
endmodule
