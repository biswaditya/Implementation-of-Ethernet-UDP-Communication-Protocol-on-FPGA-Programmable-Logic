`timescale 1ns/1ps
`include "eth_registers.vh"

module simple_axi_lite_master #(
    parameter integer C_ADDR_WIDTH = 18
) (
    input  wire                      axi_clk,
    input  wire                      axi_resetn,

    output reg  [C_ADDR_WIDTH-1:0]   s_axi_awaddr,
    output reg                       s_axi_awvalid,
    input  wire                      s_axi_awready,

    output reg  [31:0]               s_axi_wdata,
    output reg  [3:0]                s_axi_wstrb,
    output reg                       s_axi_wvalid,
    input  wire                      s_axi_wready,

    input  wire [1:0]                s_axi_bresp,
    input  wire                      s_axi_bvalid,
    output reg                       s_axi_bready,

    output reg                       init_done
);

    localparam [3:0]
        ST_RESET      = 4'd0,
        ST_WRITE_MDIO = 4'd1,
        ST_WAIT_MDIO  = 4'd2,
        ST_WRITE_RX   = 4'd3,
        ST_WAIT_RX    = 4'd4,
        ST_WRITE_TX   = 4'd5,
        ST_WAIT_TX    = 4'd6,
        ST_WRITE_FLOW = 4'd7,
        ST_WAIT_FLOW  = 4'd8,
        ST_INIT_DONE  = 4'd9;

    reg [3:0] state, next_state;

    reg aw_done, w_done;
    reg launched;

    reg [31:0] sel_addr;
    reg [31:0] sel_data;

    always @(*) begin
        case (state)
            ST_WRITE_MDIO, ST_WAIT_MDIO : begin
                sel_addr = `REG_MDIO_SETUP;
                sel_data = `VAL_MDIO_SETUP;
            end
            ST_WRITE_RX, ST_WAIT_RX : begin
                sel_addr = `REG_RCW1;
                sel_data = `VAL_RCW1_RX_EN;
            end
            ST_WRITE_TX, ST_WAIT_TX : begin
                sel_addr = `REG_TC;
                sel_data = `VAL_TC_TX_EN;
            end
            ST_WRITE_FLOW, ST_WAIT_FLOW : begin
                sel_addr = `REG_FCC;
                sel_data = `VAL_FCC_DISABLE;
            end
            default : begin
                sel_addr = 32'h0;
                sel_data = 32'h0;
            end
        endcase
    end

    always @(*) begin
        next_state = state;
        case (state)
            ST_RESET      : next_state = ST_WRITE_MDIO;
            ST_WRITE_MDIO : if (aw_done && w_done) next_state = ST_WAIT_MDIO;
            ST_WAIT_MDIO  : if (s_axi_bvalid)      next_state = ST_WRITE_RX;
            ST_WRITE_RX   : if (aw_done && w_done) next_state = ST_WAIT_RX;
            ST_WAIT_RX    : if (s_axi_bvalid)      next_state = ST_WRITE_TX;
            ST_WRITE_TX   : if (aw_done && w_done) next_state = ST_WAIT_TX;
            ST_WAIT_TX    : if (s_axi_bvalid)      next_state = ST_WRITE_FLOW;
            ST_WRITE_FLOW : if (aw_done && w_done) next_state = ST_WAIT_FLOW;
            ST_WAIT_FLOW  : if (s_axi_bvalid)      next_state = ST_INIT_DONE;
            ST_INIT_DONE  : next_state = ST_INIT_DONE;
            default       : next_state = ST_RESET;
        endcase
    end

    always @(posedge axi_clk) begin
        if (!axi_resetn) begin
            state         <= ST_RESET;
            s_axi_awaddr  <= {C_ADDR_WIDTH{1'b0}};
            s_axi_awvalid <= 1'b0;
            s_axi_wdata   <= 32'h0;
            s_axi_wstrb   <= 4'h0;
            s_axi_wvalid  <= 1'b0;
            s_axi_bready  <= 1'b0;
            aw_done       <= 1'b0;
            w_done        <= 1'b0;
            launched      <= 1'b0;
            init_done     <= 1'b0;
        end else begin
            state <= next_state;

            if ((state == ST_WRITE_MDIO ||
                 state == ST_WRITE_RX   ||
                 state == ST_WRITE_TX   ||
                 state == ST_WRITE_FLOW) && !launched) begin

                s_axi_awaddr  <= sel_addr[C_ADDR_WIDTH-1:0];
                s_axi_awvalid <= 1'b1;
                s_axi_wdata   <= sel_data;
                s_axi_wstrb   <= 4'hF;
                s_axi_wvalid  <= 1'b1;
                aw_done       <= 1'b0;
                w_done        <= 1'b0;
                launched      <= 1'b1;

            end else begin
                if (s_axi_awvalid && s_axi_awready) begin
                    s_axi_awvalid <= 1'b0;
                    aw_done       <= 1'b1;
                end

                if (s_axi_wvalid && s_axi_wready) begin
                    s_axi_wvalid <= 1'b0;
                    w_done       <= 1'b1;
                end
            end

            if (state == ST_WAIT_MDIO ||
                state == ST_WAIT_RX   ||
                state == ST_WAIT_TX   ||
                state == ST_WAIT_FLOW) begin
                s_axi_bready <= 1'b1;
                launched     <= 1'b0;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bready <= 1'b0;
            end

            init_done <= (next_state == ST_INIT_DONE);
        end
    end

endmodule