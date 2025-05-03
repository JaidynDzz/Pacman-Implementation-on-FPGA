//INPUTS FOR COORDINATES FOR OUTPUT AND COLLISION DETECTION
    reg [7:0] playerX = 8'd60;           // starting x location of object
	reg [6:0] playerY = 7'd60;           // starting y location of object
	reg [7:0] Xnext = 8'd60;
	reg [6:0] Ynext = 7'd60;
    wire [7:0] backgroundX; //counters for background output
	wire [6:0] backgroundY; //<-
	wire [7:0] VGA_X; // VGA OUTPUT X 
	wire [6:0] VGA_Y; // AND Y LOCATIONS

//ENABLERS FOR COUNTERS
	wire Ex = 1'b1; //enables counters in x direction, always 1
	wire Ey; //enables counting in y direction

//COLOR WIRES
	wire [2:0] VGA_COLOR; //COLOR FOR VGA
/OUTPUT CONTROL
	wire finishedPlottingBackground; //indicator for when map is done plotting
	wire enable;
	reg plot;
	reg  [127:0]coinReg = 128'd340282366920938463463374607431768211455;
	wire [127:0]coinWire;
	wire [7:0] coinIndexWire;
	reg [6:0] coinIndex = 7'd0;


    //score variable
	reg [7:0] score = 7'd0;
	wire [7:0] scorewire;

    //ghost variables
	reg [7:0] ghostX = 8'd140, ghostXnext;
	reg [6:0] ghostY = 7'd20, ghostYbext;
	wire [7:0] ghostXwire;
	wire [6:0] ghostYwire;
	reg collisionGhost= 1'b0; //intialize to zero at first
	reg direction = 1'b1;

    	wire [2:0] currentXtoCheck;
	wire [2:0] currentYtoCheck;                                                                                                                                                                                                                
	wire startXcounter = 1'b1;
	wire startYcounter, doneChecking;

    wire [2:0] collisionColor, coinColor, collisionCoin;
	reg wallInRange = 1'b0;
	reg coinInRange = 1'b0;
	reg collisionHorizontal = 1'b0;
	reg collisionVertical = 1'b0;


    wire [14:0] collisionDetectionMemAdress = (160*(Ynext + currentYtoCheck) + (Xnext-1 + currentXtoCheck));
	wire [14:0] coinMifAddress = ((160*backgroundY) + backgroundX);
	wire [14:0] playerCoinCollisionAddress = (160*(playerY + currentYtoCheck) + (playerX-1 + currentXtoCheck));


    wire [7:0] wX = playerX;
	wire [6:0] wY = playerY;

    wire [2:0] state = currentState;