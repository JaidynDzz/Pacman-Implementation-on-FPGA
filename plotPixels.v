module plotPixels(
			resetn,
			clock,
			color,
			x, y, plot,
			/* Signals for the DAC to drive the monitor. */
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK_N,
			VGA_SYNC_N,
			VGA_CLK);
			
	input resetn;
	input clock;	
	input [2:0] color;
	input [7:0] x;
	input [8:0] y;
	input plot;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	
	//use VGA to output player pixels
	vga_adapter outputpix (
				resetn,
				clock,
				color,
				x,
				y,
				plot,
				VGA_R,
				VGA_G,
				VGA_B,
				VGA_HS,
				VGA_VS,
				VGA_BLANK_N,
				VGA_SYNC_N,
				VGA_CLK);
	defparam outputpix.RESOLUTION = "160x120";
	defparam outputpix.MONOCHROME = "FALSE";
	defparam outputpix.BITS_PER_COLOUR_CHANNEL = 1;
	defparam outputpix.BACKGROUND_IMAGE = "background.mif";//should be black.mif, this is temporary
    
endmodule