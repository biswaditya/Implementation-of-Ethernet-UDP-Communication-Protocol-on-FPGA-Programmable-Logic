`timescale 1ns / 1ps

module udp_data(
    output  reg [143:0] udp_data_payload
);


reg [143:0]data_in = "Hello, I'm ZCU102!";


always @(*)
begin

udp_data_payload = data_in;

end



endmodule