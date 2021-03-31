`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

module hvsync_generator(clk, reset, hsync, vsync, display_on, hpos, vpos);
  
  input clk;
  input reset;
  
  output hsync, vsync;
  output display_on;
  
  // Pixel position for scanline
  output [8:0] hpos;
  output [8:0] vpos;
  
  // Horizontal attributes of the display
  localparam H_DISPLAY = 256; // horizontal display width
  localparam H_BACK    =  23; // left border (back porch)
  localparam H_FRONT   =   7; // right border (front porch)
  localparam H_SYNC    =  23; // horizontal sync width
  
  // Vertical attributes of the display
  localparam V_DISPLAY = 240; // vertical display height
  localparam V_TOP     =   4; // vertical top border
  localparam V_BOTTOM  =  14; // vertical bottom border
  localparam V_SYNC    =   4; // vertical sync # lines
  
  // Counter horizontal paramters
  localparam H_SYNC_START = H_DISPLAY + H_FRONT;
  localparam H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1;
  localparam H_MAX        = H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;

  // Counter vertical parameters
  localparam V_SYNC_START = V_DISPLAY + V_BOTTOM;
  localparam V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  localparam V_MAX        = V_DISPLAY + V_BOTTOM + V_SYNC + V_TOP - 1;

  wire hmaxxed = (hpos == H_MAX) || reset;
  wire vmaxxed = (vpos == V_MAX) || reset;
  
  // Horizontal postion counter
  always @(posedge clk)
  begin
    hsync <= (hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    
    if(hmaxxed)
      hpos <= 0;
    else
      hpos <= hpos + 1;
  end
  
  // Vertical position counter
  always @(posedge clk)
  begin
    vsync <= (vpos >= V_SYNC_START && vpos <= V_SYNC_END);
      
    if(hmaxxed)
      if(vmaxxed)
        vpos <= 0;
      else
        vpos <= vpos + 1;
  end
  
  /* Only on if the scanline position is inside the display zone
   * Will default to black (0) for pixel color when outside of the zone
   */
  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);
  
endmodule

`endif