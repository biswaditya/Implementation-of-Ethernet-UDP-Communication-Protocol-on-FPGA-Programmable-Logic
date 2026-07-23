`timescale 1ns / 1ps

module ethernet_header(
output reg [111:0]ethernet_header_data
);

reg [47:0] dest_mac   = 48'h0060E09817EA; // PC MAC
reg [47:0] source_mac = 48'h02123456789A; // FPGA MAC
reg [15:0] ether_type = 16'h0800; //IPV4 (Layer 3 Protocol)

always@(*)
  begin
       ethernet_header_data={
                             dest_mac[47:0],
                             source_mac[47:0],
                             ether_type[15:0]
                             };

  end 
endmodule