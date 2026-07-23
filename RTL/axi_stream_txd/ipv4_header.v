`timescale 1ns / 1ps

module ipv4_header(
    output reg [159:0] ipv4_header_data
);

reg [7:0]  version_ihl       = 8'h45;    // Version=4, IHL=5
reg [7:0]  dscp_ecn          = 8'h00;
reg [15:0] total_length      = 16'h002E; // 20(IP)+8(UDP)+18("DATA")
reg [15:0] identification    = 16'h0000;
reg [15:0] flags_fragment    = 16'h4000; // Fragment
reg [7:0]  ttl               = 8'h40;    // 64(standard)
reg [7:0]  protocol          = 8'h11;    // UDP(17)(Layer 4 protocol)
reg [15:0] header_checksum ; // RTL Calculation
reg [31:0] source_ip         = 32'h0A1F29E6; // 10.31.41.230
reg [31:0] destination_ip    = 32'h0A1F29E0; // 10.31.41.224


// IPV4 Checksum
reg [31:0] temp_sum;

always @(*) begin

    
    temp_sum =
        {version_ihl, dscp_ecn} +
        total_length +
        identification +
        flags_fragment +
        {ttl, protocol} +
        source_ip[31:16] +
        source_ip[15:0] +
        destination_ip[31:16] +
        destination_ip[15:0];

    
    while (temp_sum[31:16] != 16'h0000)
        temp_sum = temp_sum[15:0] + temp_sum[31:16];

    header_checksum = ~temp_sum[15:0];
    
end

always @(*)
begin
    ipv4_header_data = {
        version_ihl,
        dscp_ecn,
        total_length[15:0],
        identification[15:0],
        flags_fragment[15:0],
        ttl,
        protocol,
        header_checksum[15:0],
        source_ip[31:0],
        destination_ip[31:0]

    };
end

endmodule