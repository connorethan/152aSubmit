
module stopwatch_tb;

// Inputs
reg clk;
reg btnS, btnR;
reg [7:0] sw;

// Outputs
wire [3:0] an;
wire [7:0] seg;

// Instantiate the Unit Under Test (UUT)
stopwatch uut (
    .clk(clk), 
    .btnS(btnS), 
    .btnR(btnR), 
    .sw(sw), 
    .an(an), 
    .seg(seg)
);

always begin
    #500 clk <= ~clk;
end

// Test stimulus
initial begin
    // Ensure that input-sensitive signals are well-defined
    sw = 8'b00000000;
    btnS = 0;
    btnR = 0;
    clk = 1'b0;
    $monitor(uut.start_sec);
end

endmodule
