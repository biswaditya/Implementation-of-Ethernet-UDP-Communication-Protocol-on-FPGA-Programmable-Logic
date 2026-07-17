`timescale 1ns / 1ps

module udp_header(
    output reg [63:0] udp_header_data
);

reg [15:0] source_port      = 16'd1234; // FPGA Port
reg [15:0] destination_port = 16'd5678; // PC port 
reg [15:0] udp_length       = 16'h001A; // 8 + 18 Data
reg [15:0] udp_checksum ;  // RTL Calculation

wire [159:0] ipv4_header_data;
wire [143:0] udp_data_payload;


ipv4_header testchecksum1 (
    .ipv4_header_data(ipv4_header_data)
);

udp_data testchecksum2 (
    .udp_data_payload(udp_data_payload)
);


wire [31:0] source_ip      = ipv4_header_data[63:32];
wire [31:0] destination_ip = ipv4_header_data[31:0];
wire [7:0]  protocol       = ipv4_header_data[87:80];

//udp checksum
reg [31:0] temp_sum;
reg [31:0] payload_sum;
integer i;

always @(*) begin

    payload_sum = 32'd0;
    for (i = 0; i < 9; i = i + 1)
        payload_sum = payload_sum + udp_data_payload[i*16 +: 16];

    while (payload_sum[31:16] != 16'h0000)
        payload_sum = payload_sum[15:0] + payload_sum[31:16];

    temp_sum =
          source_ip[31:16]
        + source_ip[15:0]
        + destination_ip[31:16]
        + destination_ip[15:0]
        + {8'h00, protocol}
        + udp_length
        + source_port
        + destination_port
        + udp_length
        + 16'h0000      
        + payload_sum[15:0];

    while (temp_sum[31:16] != 16'h0000)
        temp_sum = temp_sum[15:0] + temp_sum[31:16];

    udp_checksum = ~temp_sum[15:0];

end

always @(*) begin
    udp_header_data = {
        source_port[15:0],
        destination_port[15:0],
        udp_length[15:0],
        udp_checksum[15:0]
                      };
end

endmodule