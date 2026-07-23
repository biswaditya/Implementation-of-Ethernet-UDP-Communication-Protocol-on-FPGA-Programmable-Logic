`timescale 1ns / 1ps



module clk_toggler(
input clk_in,
output clk_toggle
);
    
assign clk_toggle = ~clk_in;
endmodule
