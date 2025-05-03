module outputGenerator(clock, X, Y, pX, pY, gX,gY, coinArray, coinIndex, state, color);
	input wire [3:0] state;
	input wire [7:0] X, pX, gX;
	input wire [6:0] Y, pY, gY;
	wire [2:0] bgColor, pacColor, coinColor, screencolor, purpleghostcolor, winscreencolor, endscreencolor;
	output reg [2:0] color;
	input clock;
	input wire [127:0] coinArray;
	input wire [6:0] coinIndex;
	parameter pWidth = 4'd7;
	parameter pHeight = 4'd7;

	//get adresses
	wire [14:0] defaultCoinAddress  = (160*(Y) + (X));
	wire [14:0] backgroundMemAdress = (160*(Y) + (X));
	wire [6:0] pacmanMemAdress = (8*(Y-pY) + (X-pX+1));
	wire [6:0] purpleghostaddress = (8*(Y-gY) + (X-gX)+1);

	//get colors
	bgROM getBGcolor (backgroundMemAdress, clock, bgColor);
	pacmanmem getpacColor (pacmanMemAdress, clock, pacColor);
	coinMemRAM getcoincolor(defaultCoinAddress, clock, 3'b111, 0, coinColor);
	startscreen getscrencolor (defaultCoinAddress, clock, screencolor);
	purpleghost getghostcolor (purpleghostaddress, clock, purpleghostcolor);
	endscreen getendscreencolor (backgroundMemAdress, clock, endscreencolor);
	winscreen getwinscreencolor (defaultCoinAddress, clock, winscreencolor);
	//always block

	always@(posedge clock)begin
		if(state == 3'b001)
	      color<=screencolor;
		 
		else if (state==3'b111) 
		    color<=winscreencolor;
		
		else if (state==3'b100)
		     color<=endscreencolor;
			  
		else if (state==3'b010)
		   begin
			if(X >= pX && X <= (pX+pWidth) && Y >= pY && Y <= (pY + pHeight))
				color <= pacColor;
			else if(coinColor == 3'b010&&coinArray[coinIndex]==1'b1)
				color <= 3'b010;
			else if (X >=gX && X <= (gX+pWidth) && Y >= gY && Y <= (gY + pHeight))
			  color<=purpleghostcolor;
			else	
				color <= bgColor;
		end
	end
	
endmodule