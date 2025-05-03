`include "count.v"
`include "outputGenerator.v"

module top_module(CLOCK_50, SW, HEX1, HEX0, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR,
PS2_CLK, PS2_DAT);

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
wire [6:0] backgroundY //y coordinate background output location
wire [7:0] VGA_X; //VGA output X
wire [6:0] VGA_Y; //VGA output Y

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

wire [2:0] collisionColor, coinColor, collisionCoin
reg wallInPange = 1'b0;
reg coinInRange = 1'b0;
reg collisionHorizontal = 1'b0;
reg collisionVertical = 1'b0;
wire [14:0] coinMifAddress = ((160 * backgroundY) + backgroundX);
coinMemRAM getCoinColor(coinMifAddress, CLOCK_50, 3'b111, 1'b0, coinColor);
//end 


//VGA output 
reg [127:0] coinReg = 128 'd340282366920938463463374607431768211455; //this is 128 1's in binary, where each 1 represents a coin in coinMemRAM
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

assign ghostXwire = ghostX;, 
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



endmodule