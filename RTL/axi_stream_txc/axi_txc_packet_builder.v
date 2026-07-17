`timescale 1ns / 1ps

module axi_txc_packet_builder(

    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,

    output reg [31:0]  tdata,
    output reg         tvalid,
    input  wire        tready,
    output reg         tlast,
    output reg [3:0]   tkeep

);

    // FSM States

    parameter IDLE = 2'd0;
    parameter LOAD = 2'd1;
    parameter SEND = 2'd2;
    parameter END  = 2'd3;

    reg [1:0] state;
    
    // Pointer
    reg [2:0] ptr;

    // Control Packet Memory
    reg [31:0] control_mem [0:5];
    
    reg start_d;
    wire start_rise;
    

    always @(posedge clk) begin
    if (!rst_n)
        start_d <= 1'b0;
    else
        start_d <= start;
    end

    assign start_rise = start & ~start_d;
    

    // FSM 
    always @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            state  <= IDLE;
            ptr    <= 3'd0;

            tdata  <= 32'd0;
            tvalid <= 1'b0;
            tlast  <= 1'b0;
            tkeep  <= 4'b0000;

        end

        else
        begin

            case(state)

            IDLE:
            begin

                ptr    <= 3'd0;

                tdata  <= 32'd0;
                tvalid <= 1'b0;
                tlast  <= 1'b0;
                tkeep  <= 4'b0000;

                if(start_rise)
                    state <= LOAD;

            end

            LOAD:
            begin

                // Word0
                // Normal Transmit
                control_mem[0] <= 32'hA0000000;
                
                // Word1
                // Checksum Offload Disabled
                control_mem[1] <= 32'h00000000;
                
                // Word2
                control_mem[2] <= 32'h00000000;
                
                // Word3
                control_mem[3] <= 32'h00000000;
                
                // Word4
                control_mem[4] <= 32'h00000000;

                // Word5
                control_mem[5] <= 32'h00000000;

                ptr <= 3'd0;

                state <= SEND;

            end
            
            SEND:
            begin

                tvalid <= 1'b1;

                if(tready)
                begin

                    tdata <= control_mem[ptr];

                    tkeep <= 4'b1111;

                    if(ptr == 3'd5)
                    begin

                        tlast <= 1'b1;
                        state <= END;

                    end

                    else
                    begin

                        tlast <= 1'b0;
                        ptr   <= ptr + 1'b1;

                    end

                end

            end

            END:
            begin

                tdata  <= 32'd0;
                tvalid <= 1'b0;
                tlast  <= 1'b0;
                tkeep  <= 4'b0000;

                ptr <= 3'd0;

               state <= IDLE;

            end

            default:
                state <= IDLE;

            endcase

        end

    end

endmodule