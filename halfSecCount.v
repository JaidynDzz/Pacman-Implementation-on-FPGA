module halfSecCount(input clock, input reset, output reg halfClk);
	reg [24:0] Q; // counter
	always @(posedge clock) begin
		 if (!reset)
			  Q <= 25'b0;
		 else if (Q == 2000000)
			  Q <= 25'b0;
		 else
			  Q <= Q + 1;
	end

	always @(posedge clock) begin
		 if (!reset)
			  halfClk <= 0;
		 else if (Q == 2000000)
			  halfClk <= 1'b1;
		 else
			  halfClk <= 1'b0;
	end
endmodule