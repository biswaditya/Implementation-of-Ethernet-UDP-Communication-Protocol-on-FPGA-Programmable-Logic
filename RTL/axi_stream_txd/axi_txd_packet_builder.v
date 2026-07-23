
`timescale 1ns / 1ps

module axi_txd_packet_builder(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,

    output reg [31:0] tdata,
    output reg        tvalid,
    input  wire       tready,
    output reg        tlast,
    output reg [3:0]  tkeep
);

    parameter IDLE = 2'd0;
    parameter LOAD = 2'd1;
    parameter SEND = 2'd2;
    parameter END  = 2'd3;

    reg [1:0] state;
    reg [7:0] ptr;

    integer i;
    integer a,b,c,d;

    wire [111:0] ethernet_header_data;
    wire [159:0] ipv4_header_data;
    wire [63:0]  udp_header_data;
    wire [143:0]  udp_data_payload;

    ethernet_header u_eth (
        .ethernet_header_data(ethernet_header_data)
    );

    ipv4_header u_ip (
        .ipv4_header_data(ipv4_header_data)
    );

    udp_header u_udp (
        .udp_header_data(udp_header_data)
    );

    udp_data u_data (
        .udp_data_payload(udp_data_payload)
    );



    reg [7:0] ether_header [0:13];
    reg [7:0] ip_header    [0:19];
    reg [7:0] udp_head     [0:7];
    reg [7:0] data_header  [0:17];

    reg [7:0] packet_mem   [0:59];


    always @(*) begin

        for(a = 0; a < 14; a = a + 1)
            ether_header[a] = ethernet_header_data[111-(a*8)-:8];

        for(b = 0; b < 20; b = b + 1)
            ip_header[b] = ipv4_header_data[159-(b*8)-:8];

        for(c = 0; c < 8; c = c + 1)
            udp_head[c] = udp_header_data[63-(c*8)-:8];

        for(d = 0; d < 18; d = d + 1)
            data_header[d] = udp_data_payload[143-(d*8)-:8];

    end



reg start_d;
wire start_pulse;

always @(posedge clk) begin
    if (!rst_n)
        start_d <= 1'b0;
    else
        start_d <= start;
end

assign start_pulse = start & ~start_d;





    always @(posedge clk or negedge rst_n) begin

        if(!rst_n) begin

            state  <= IDLE;
            ptr    <= 8'd0;

            tdata  <= 32'd0;
            tvalid <= 1'b0;
            tlast  <= 1'b0;
            tkeep  <= 4'b0000;

        end
        else begin

            case(state)


            IDLE: begin

                ptr    <= 8'd0;
                tdata  <= 32'd0;
                tvalid <= 1'b0;
                tlast  <= 1'b0;
                tkeep  <= 4'b0000;

                if(start_pulse)
                    state <= LOAD;

            end

            LOAD: begin

                for(i = 0; i < 14; i = i + 1)
                    packet_mem[i] <= ether_header[i];

                for(i = 0; i < 20; i = i + 1)
                    packet_mem[14+i] <= ip_header[i];

                for(i = 0; i < 8; i = i + 1)
                    packet_mem[34+i] <= udp_head[i];

                for(i = 0; i < 18; i = i + 1)
                    packet_mem[42+i] <= data_header[i];

                ptr   <= 8'd0;
                state <= SEND;

            end


            SEND: begin

                tvalid <= 1'b1;

                if(tready) 
                begin
                   tdata <= { 
                             packet_mem[ptr+3],
                             packet_mem[ptr+2],
                             packet_mem[ptr+1],
                             packet_mem[ptr]
                                        };
                                        
                   tkeep <= 4'b1111;                    

                    if(ptr == 8'd56) 
                    begin
                        tlast <= 1'b1;
                        state <= END;
                    end


                    else 
                    begin
                        tlast <= 1'b0;
                        ptr <= ptr + 4;
                    end

                end

            end

            END: begin

                tdata  <= 32'd0;
                tvalid <= 1'b0;
                tlast  <= 1'b0;
                tkeep  <= 4'b0000;
                ptr <= 8'd0;
                state <= IDLE;

            end

            default: begin

                state <= IDLE;

            end

            endcase

        end

    end

endmodule
