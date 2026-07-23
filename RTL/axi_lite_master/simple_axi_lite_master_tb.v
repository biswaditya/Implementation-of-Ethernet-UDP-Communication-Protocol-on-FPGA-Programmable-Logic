`timescale 1ns/1ps
`include "eth_registers.vh"

module simple_axi_lite_master_tb;

parameter C_ADDR_WIDTH = 18;

reg axi_clk;
reg axi_resetn;

wire [C_ADDR_WIDTH-1:0] s_axi_awaddr;
wire                    s_axi_awvalid;
reg                     s_axi_awready;

wire [31:0] s_axi_wdata;
wire [3:0]  s_axi_wstrb;
wire        s_axi_wvalid;
reg         s_axi_wready;

reg  [1:0]  s_axi_bresp;
reg         s_axi_bvalid;
wire        s_axi_bready;

wire init_done;

simple_axi_lite_master #(
    .C_ADDR_WIDTH(C_ADDR_WIDTH)
)
dut
(
    .axi_clk       (axi_clk),
    .axi_resetn    (axi_resetn),

    .s_axi_awaddr  (s_axi_awaddr),
    .s_axi_awvalid (s_axi_awvalid),
    .s_axi_awready (s_axi_awready),

    .s_axi_wdata   (s_axi_wdata),
    .s_axi_wstrb   (s_axi_wstrb),
    .s_axi_wvalid  (s_axi_wvalid),
    .s_axi_wready  (s_axi_wready),

    .s_axi_bresp   (s_axi_bresp),
    .s_axi_bvalid  (s_axi_bvalid),
    .s_axi_bready  (s_axi_bready),

    .init_done     (init_done)
);

initial begin
    axi_clk = 1'b0;
    forever #5 axi_clk = ~axi_clk;
end

initial begin
    axi_resetn = 1'b0;

    s_axi_awready = 1'b0;
    s_axi_wready  = 1'b0;
    s_axi_bvalid  = 1'b0;
    s_axi_bresp   = 2'b00;

    #30;
    axi_resetn = 1'b1;
end

always @(posedge axi_clk)
begin
    if(!axi_resetn)
    begin
        s_axi_awready <= 1'b0;
        s_axi_wready  <= 1'b0;
        s_axi_bvalid  <= 1'b0;
    end
    else
    begin
        s_axi_awready <= 1'b0;
        s_axi_wready  <= 1'b0;

        if(s_axi_awvalid)
            s_axi_awready <= 1'b1;

        if(s_axi_wvalid)
            s_axi_wready <= 1'b1;

        if(s_axi_awvalid && s_axi_awready &&
           s_axi_wvalid  && s_axi_wready)
        begin
            s_axi_bvalid <= 1'b1;
            s_axi_bresp  <= 2'b00;
        end

        if(s_axi_bvalid && s_axi_bready)
            s_axi_bvalid <= 1'b0;
    end
end

always @(posedge axi_clk)
begin
    if(s_axi_awvalid && s_axi_awready)
    begin
        $display("-----------------------------------------");
        $display("TIME  = %0t",$time);
        $display("WRITE = ADDR : %h",s_axi_awaddr);
        $display("DATA  = %h",s_axi_wdata);
    end

    if(init_done)
    begin
        $display("-----------------------------------------");
        $display("INITIALIZATION COMPLETE @ %0t",$time);
        #20;
        $finish;
    end
end

endmodule