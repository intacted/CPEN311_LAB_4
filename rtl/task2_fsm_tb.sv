
`default_nettype none

module tb_task2 ();

reg res,clk;
reg [7:0] key [2:0];
reg [7:0] q;

wire [7:0] i;
wire wren;

task2_fsm dut (
    //input
    .reset(res),
    .clk(clk),
    .secret_key(key),
    .q(q),

    //output
    .iterator(i),
    .wren(wren)
);

initial begin
    clk=0;
    #5;
    forever begin
        clk=1;
        #5;
        clk=0;
        #5;
    end
end

initial begin
    res=0;
    key[0]=8'h00;
    key[1]=8'h02;
    key[2]=8'h49;
    q=0;
    #5;
    res=1;
    #5;
    #400;
$stop;

    
end

endmodule