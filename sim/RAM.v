// Pretty much the same as the DE1 except writes are instantaneous instead of delayed
module RAM(address, clock, data, wren, q);
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 256;

    input [ADDR_WIDTH - 1:0] address;
    input clock;
    input [DATA_WIDTH - 1:0] data;
    input wren;
    output reg [DATA_WIDTH - 1:0] q;

    //reg [DATA_WIDTH - 1:0] temp_data;
    reg [DATA_WIDTH - 1:0] mem [0:DEPTH-1];

    always @(posedge clock) begin
       if (wren) mem[address] <= data;
       
       q <= mem[address];
    end

endmodule

module decrypted_msg(address, clock, data, wren, q); // RAM
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 256;

    input [ADDR_WIDTH - 1:0] address;
    input clock;
    input [DATA_WIDTH - 1:0] data;
    input wren;
    output reg [DATA_WIDTH - 1:0] q;

    //reg [DATA_WIDTH - 1:0] temp_data;
    reg [DATA_WIDTH - 1:0] mem [0:DEPTH-1];

    always @(posedge clock) begin
       if (wren) mem[address] <= data;
       
       q <= mem[address];
    end

endmodule


module encrypted_msg(address, clock, q); // ROM
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 32;

    input [ADDR_WIDTH - 1:0] address;
    input clock;

    output reg [DATA_WIDTH - 1:0] q;

    parameter reg [DATA_WIDTH - 1:0] data [0:DEPTH - 1] = 
    '{
        8'd45,      //  0 
        8'd143,     //  1 
        8'd122,     //  2 
        8'd169,     //  3 
        8'd56,      //  4 
        8'd115,     //  5 
        8'd95,      //  6 
        8'd135,     //  7 
        8'd69,      //  8 
        8'd27,      //  9 
        8'd130,     //  10
        8'd134,     //  11
        8'd75,      //  12
        8'd155,     //  13
        8'd127,     //  14
        8'd157,     //  15
        8'd239,     //  16
        8'd13,      //  17
        8'd196,     //  18
        8'd187,     //  19
        8'd249,     //  20
        8'd119,     //  21
        8'd153,     //  22
        8'd117,     //  23
        8'd255,     //  24
        8'd213,     //  25
        8'd96,      //  26
        8'd115,     //  27
        8'd1,       //  28
        8'd248,     //  29
        8'd22,      //  30
        8'd37        //  31
    };

    //reg [DATA_WIDTH - 1:0] temp_data;
    reg [DATA_WIDTH - 1:0] mem [0:DEPTH-1];

    always @(posedge clock) begin
       q <= mem[address];
    end

endmodule

