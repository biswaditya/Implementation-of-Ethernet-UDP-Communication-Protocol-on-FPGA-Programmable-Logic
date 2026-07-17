
`timescale 1ns / 1ps

module axi_txd_packet_builder_tb;

    reg         clk;
    reg         rst_n;
    reg         start;
    reg         tready;

    wire [31:0] tdata;
    wire        tvalid;
    wire        tlast;
    wire [3:0]  tkeep;


    axi_txd_packet_builder dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .start  (start),
        .tdata  (tdata),
        .tvalid (tvalid),
        .tready (tready),
        .tlast  (tlast),
        .tkeep  (tkeep)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n  = 1'b0;
        start  = 1'b0;
        tready = 1'b1;

        #20;
        rst_n = 1'b1;

        #20;
        start = 1'b1;

        #10;
        start = 1'b0;

        #500;

        $finish;

    end


    always @(posedge clk) begin

        if(tvalid && tready) begin

            $display(
                "TIME=%0t DATA=%h KEEP=%b LAST=%b",
                $time,
                tdata,
                tkeep,
                tlast
            );

        end

    end

endmodule
