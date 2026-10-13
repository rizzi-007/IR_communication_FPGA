module ir_decode(clk,ir,cmd,rdy);
	
		input clk;
		input ir;
		output reg [7:0]cmd;
		output reg rdy;
		
		reg[2:0] sync=3'b111;
		
		always@(posedge clk)
		begin
				sync<={sync[1:0],ir};
		end
		
		wire fall=(sync[2]==1 && sync[1]==0);
		
		reg [19:0] timer=0;
		reg [5:0] bit=0;
		reg [31:0] data=0;
		
		always@(posedge clk)
		begin
		
			rdy<=0;
			
			if(timer<20'd1000000)
			begin
					timer<=timer+1'b1;
			end
			
			if(fall)
			begin
					timer<=0;
		
					if(timer>20'd400000)
					begin
							bit<=0;
					end
					else if(bit<32)
					begin
							if(timer>20'd80000)
							begin
									data<={1'b1,data[31:1]};
							end
							else
							begin
									data<={1'b0,data[31:1]};
							end
							
							bit<=bit+1'b1;
					end
			end
				
			if(bit==32)
			begin
					cmd<=data[23:16];
					rdy<=1;
					bit<=33;
			end
				
		end
		
endmodule