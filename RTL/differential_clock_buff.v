`timescale 1ns / 1ps


module differential_clock_buff
(
    input  wire clk_125_p,
    input  wire clk_125_n,
    output wire clk_bufg
);

wire clk_125;


// Convert differential clock to single-ended
IBUFDS #(
    .DIFF_TERM("TRUE"),
    .IBUF_LOW_PWR("FALSE")
) ibufds_clk125 (
    .I (clk_125_p),
    .IB(clk_125_n),
    .O (clk_125)
);

// Put it on global clock network
BUFG bufg_clk125 (
    .I(clk_125),
    .O(clk_bufg)
);

// clk_bufg is your 125 MHz clock


endmodule
