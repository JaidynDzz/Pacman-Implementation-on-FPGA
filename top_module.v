`include "count.v"
`include "outputGenerator.v"
`include "hex7seg.v"
`include "halfSecCount.v"
`include "plotPixels.v" 
`include "outputGenerator.v" 

module top_module(CLOCK_50, SW, HEX1, HEX0, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR,
PS2_CLK, PS2_DAT);

//VARIABLES FOR PS2 PS2_Controller
	inout PS2_CLK;
	inout PS2_DAT;
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;
	wire [3:0] left1, right1;
	reg	[7:0] last_data_received;

	assign left1 = last_data_received[7:4];
	assign right1 = last_data_received[3:0];

	assign right=((left1 == 4'b0111) && (right1 == 4'b0100));
	assign up =  ((left1 == 4'b0111) && (right1 == 4'b0101));
	assign down =((left1 == 4'b0111) && (right1 == 4'b0010));
	assign left =((left1 == 4'b0110) && (right1 == 4'b1011));
	wire space = ((left1 == 4'b0010) && (right1 == 4'b1001));
	wire enter = ((left1 == 4'b0101) && (right1 == 4'b1010));
	reg [3:0] lastKey;

//PS2 PS2_Controller
	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50				(CLOCK_50),
		.reset				(~SW[0]),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);


// inputs from board and VGA
input CLOCK_50;
input [7:0] SW;
output [6:0] HEX1, HEX0;
output [7:0] VGA_R;
output [7:0] VGA_G;
output [7:0] VGA_B;
output VGA_HS;
output VGA_VS;
output VGA_BLANK_N;
output VGA_SYNC_N;
output VGA_CLK;
output [9:0] LEDR;

// input for coordinates for vga output and player collision detection
reg [7:0] playerX = 8'd60; //starting x coordinate of player
reg [6:0] playerY = 7'd60; //starting y coordinate of player
reg [7:0] Xnext = 8'd60; //next x location of player
reg [6:0] Ynext = 7'd60; //next y location of player
wire [7:0] backgroundX; //x coordinate background output location
wire [6:0] backgroundY; //y coordinate background output location
wire [7:0] VGA_X; //VGA output X;
wire [6:0] VGA_Y; //VGA output Y;

// background counter block
wire Ex = 1'b1; //enables counting in the x direction, always enabled
wire Ey; //enables counting in the y direction 
count backgroundXcounter (.Clock(CLOCK_50), .Resetn(SW[0]), .E(Ex), .Q(backgroundX)); // counts background x coordinates with count.v
count backgroundYcounter (.Clock(CLOCK_50), .Resetn(SW[0]),.E(Ey), .Q(backgroundY)); //counts background y coordinates with count.v
defparam backgroundXcounter.n = 8;
defparam backgroundYcounter.n = 7;
assign Ey = (backgroundX == 8'b10100000); //Set wire Ey to 1 when backgroundX equals 160
wire finishedPlottingBackground; //indicator for when map is done plotting
assign finishedPlottingBackground = (backgroundY == 7'b1111000); //set signal to 1 when backgroundY equals 120
//end 

//collision wall detection block 
wire [2:0] currentXtoCheck; // player X coordinate
wire [2:0] currentYtoCheck; //player Y coordinate
wire startXcounter = 1'b1;
wire startYcounter, doneChecking;
count collisionXcounter (.Clock(CLOCK_50), .Resetn(SW[0]), . E(startXcounter), . Q(currentXtoCheck));
count collisionYcounter (.Clock(CLOCK_50), .Resetn (SW[0]), .E(startYcounter), .Q(currentYtoCheck));
assign startYcounter = (currentXcounter == 3'b111);
assign doneChecking = (currentYcounter == 3'b111);

wire [2:0] collisionColor, coinColor, collisionCoin;
reg wallInPange = 1'b0;
reg coinInRange = 1'b0;
reg collisionHorizontal = 1'b0;
reg collisionVertical = 1'b0;
wire [14:0] coinMifAddress = ((160 * backgroundY) + backgroundX);
coinMemRAM getCoinColor(coinMifAddress, CLOCK_50, 3'b111, 1'b0, coinColor);
//end 


//VGA output 
reg [127:0] coinReg = 128'd340282366920938463463374607431768211455; //this is 128 1's in binary, where each 1 represents a coin in coinMemRAM
wire [127:0] coinWire;
reg [6:0] coinIndex = 7'd0;
wire [7:0] coinIndexWire;

wire [7:0] Wx = playerX;
wire [6:0] Wy= playerY;
assign coinWire = coinReg;
assign coinIndexWire = coinIndex; 
reg [2:0] currentState, nextState;
reg plot;
wire [2:0] state = currentState; 
reg [7:0] ghostX = 8'd140;
reg [6:0] ghostY = 7'd20;
wire [7:0] ghostXwire;
wire [6:0] ghostYwire;

assign ghostXwire = ghostX;
assign ghostYwire = ghostY;
reg collisionghost = 1'b0; 
outputGenerator getCurrentPixel (.CLOCK (CLOCK_50), .X(backgroundX), .Y(backgroundY), .pX(Wx), .pY(Wy), .gX(ghostXwire), .gY(ghostYwire), .coinArray(coinWire), .coinIndex(coinIndex), .state (state), .color(VGA_COLOR));
assign VGA_X = backgroundX;
assign VGA_Y = backgroundY; 
//output pixel
	plotPixels playerOutput (
				.resetn(SW[0]),
				.clock(CLOCK_50),
				.color(VGA_COLOR),
				.x(VGA_X),
				.y(VGA_Y),
				.plot(plot), //ideally 1 if in pacman output state
				.VGA_R(VGA_R),
				.VGA_G(VGA_G),
				.VGA_B(VGA_B),
				.VGA_HS(VGA_HS),
				.VGA_VS(VGA_VS),
				.VGA_BLANK_N(VGA_BLANK_N),
				.VGA_SYNC_N(VGA_SYNC_N),
				.VGA_CLK(VGA_CLK));
	
	assign LEDR[0] = (currentState == 3'b001);
	assign LEDR[1] = (currentState == 3'b010);
	assign LEDR[2] = (currentState == 3'b111);

//score variables
reg [7:0] score = 7'd0;
wire [7:0] scorewire; 

//GAME STATE FSM
parameter startGame = 3'b0001, playGame =3'b010, endGame = 3'b100, winGame = 3'b111;

always @ (*) begin 
    case (currentState)
        startGame: begin 
        if(space) begin 
            nextState <= playGame;
        end 
        else 
            nextState <= startGame;
    end 
    playGame: begin 
        if (collisionGhost==1'b1)
            nextState<=endGame;
        else if (score == 7'd99)
            nextState <= winGame;
        else
            nextState <=playGame;
        end
    winGame: begin 
        if (enter)
            nextState <= startGame;
        else 
            nextState <= winGame;
        end
    endGame: begin 
        if (enter)
            nextState <= startGame;
        else 
            nextState <= endGame;
        end
        default: nextState <= startGame;
    endcase
end
//END GAME STATE FSM

wire enable;
//COUNTER TO MANAGE FPS
	halfSecCount G1 (CLOCK_50, 1'b1, enable); //enables counter based on a slower counter to slow down the movement of the player

always@(posedge CLOCK_50)begin 
		plot <= 1;
      //import mif to reg
	 if(currentState == startGame) begin
		score <= 0;
        coinReg <= 128 'd340282366920938463463374607431768211455;
        playerX <= 8'd60;
        playerY <= 7'd60;
         Xnext <= playerX;
		Ynext <= playerY;
        collisionGhost <= 1'b0;
	end
    if(coinColor == 3'b010)begin
		if(playerX <= backgroundX && playerX+4'd8 >=backgroundX && playerY <= backgroundY && playerY+4'd8 >= backgroundY && coinReg[coinIndex] == 1)
		begin
			coinReg[coinIndex] <= 1'b0;
			score <= score + 1;
		end
		coinIndex <= coinIndex + 1;
	end 

if(finishedPlottingBackground)begin
		coinIndex <= 7'd0;
	end
	//movement control
		if(enable)begin 
			if(up&&(playerY>0))begin
				Ynext <= playerY-delta;
			end
			if(down&&(playerY<7'd112))begin
				Ynext <= playerY + delta;
			end
			if(left&&(playerX>0))begin
				Xnext <= playerX -delta;
			end	
			if(right&&(playerX<8'd152))begin
				Xnext <= playerX + delta;
			end	
			/*if(!up&&!down&&!left&&!right||(up&&down)||(left&&right))begin
				Ynext <= playerY;
				Xnext <= playerX;
			end*/
		end
		
		//collision detection
		if(collisionColor == 3'b111)begin
			wallInRange <= 1'b1;
		end
		
      //ghost collision detection 
		//if (playerX+4'd8 >= ghostX+2 && playerX <= ghostX-2 + 4'd8 && playerY + 4'd8 >= ghostY +2 && playerY < ghostY -2+ 4'd8)
	            //collisionGhost<= 1'b1;
		
		if(wallInRange)begin
			if(up)			lastKey <= 4'b0001;
			else if(down)	lastKey <= 4'b0010;
			else if(left) 	lastKey <= 4'b0100;
			else if(right)	lastKey <= 4'b1000;
			Xnext <= playerX;
			Ynext <= playerY;
		end
		

		
		if(finishedPlottingBackground&&doneChecking)begin
			if(~wallInRange)begin
				playerY <= Ynext;
				playerX <= Xnext;
			end
		end
						
		if(wallInRange&&doneChecking&&Xnext==playerX&&Ynext==playerY)
	 	 begin
			if(((lastKey == 4'b0001)&&~up)||((lastKey == 4'b0010)&&~down)||((lastKey == 4'b0100)&&~left)||((lastKey == 4'b1000)&&~right))
		begin
				wallInRange <= 1'b0;
			end
		end

	//ps2 stuff
		if (SW[0] == 1'b0)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
		
		currentState <= nextState;
end
//end flipflop 

//outputting coordinates on hexes
	assign scorewire = score;
	hex7seg H5 (scorewire[7:4], HEX1);
	hex7seg H4 (scorewire[3:0], HEX0);

endmodule