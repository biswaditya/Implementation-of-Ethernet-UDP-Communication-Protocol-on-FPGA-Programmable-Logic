
`timescale 1ns / 1ps

module axi_txc_packet_builder_tb;

    reg         clk;
    reg         rst_n;
    reg         start;
    reg         tready;

    wire [31:0] tdata;
    wire        tvalid;
    wire        tlast;
    wire [3:0]  tkeep;


    axi_txc_packet_builder dut (
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

        #200;

        $finish;

    end


    always @(posedge clk) begin

        if(tvalid && tready) begin

            $display(
                "Time=%0t  DATA=%h  TVALID=%b  TKEEP=%b  TLAST=%b",
                $time,
                tdata,
                tvalid,
                tkeep,
                tlast
            );

        end

    end

endmodule

