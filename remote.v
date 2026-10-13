module remote(clk,ir,rw,rs,blon,onn,en,data,LEDG);

		input clk,ir;
		output rw,rs,blon,onn,en;
		output reg[7:0]data;
		output [7:0]LEDG; 
		
		assign blon=1'b1;
		assign onn=1'b1;
		assign rw=1'b0;
		
		reg led_en=0;
		assign en=led_en;
		
		reg led_rs=0;
		assign rs=led_rs;
		
		wire [7:0]ir_cmd;
		wire ir_rdy;
		
		ir_decode op1(.clk(clk),.ir(ir),.cmd(ir_cmd),.rdy(ir_rdy));
		
		assign LEDG = ir_cmd;
		
		reg [19:0]timer2=0;
		reg [2:0]state=0;
		reg row=0;
		
		always @(posedge clk)
		begin
				if(timer2<20'd100000)
				begin
						timer2<=timer2+1'b1;
						
						if(timer2==20'd30000) led_en<=1;
						if(timer2==20'd70000) led_en<=0;
				end
				else 
				begin
						case(state)
								3'd0: begin led_rs<=0; data<=8'h38; timer2<=0; state<=3'd1; end
								3'd1: begin led_rs<=0; data<=8'h0F; timer2<=0; state<=3'd2; end
								3'd2: begin led_rs<=0; data<=8'h01; timer2<=0; state<=3'd3; end
								3'd3: begin led_rs<=0; data<=8'h06; timer2<=0; state<=3'd4; end
								3'd4: begin
										led_en<=0;
										
										if(ir_rdy)
										begin
												timer2<=0;
												
												case(ir_cmd)
														8'h00: begin led_rs <= 1; data <= "0"; end
														8'h01: begin led_rs <= 1; data <= "1"; end
														8'h02: begin led_rs <= 1; data <= "2"; end
														8'h03: begin led_rs <= 1; data <= "3"; end
														8'h04: begin led_rs <= 1; data <= "4"; end
														8'h05: begin led_rs <= 1; data <= "5"; end
														8'h06: begin led_rs <= 1; data <= "6"; end
														8'h07: begin led_rs <= 1; data <= "7"; end
														8'h08: begin led_rs <= 1; data <= "8"; end
														8'h09: begin led_rs <= 1; data <= "9"; end
														
														8'h1A: begin led_rs <= 1; data <= "R"; end
														8'h1E: begin led_rs <= 1; data <= "I"; end
														8'h1B: begin led_rs <= 1; data <= "S"; end
														8'h1F: begin led_rs <= 1; data <= "H"; end
												
														
														8'h12: begin led_rs <= 0; data <= 8'h01; end
														
														8'h0C: begin 
																led_rs <= 0; 
																row <= ~row; 
																data <= (row == 0) ? 8'hC0 : 8'h80; 
														end
														
														default: begin led_rs <= 0; data <= 8'h00; end
												endcase
										end
								end
						endcase
				end
		end
endmodule
