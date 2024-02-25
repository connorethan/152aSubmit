`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 02:24:46 PM
// Design Name: 
// Module Name: clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock #(parameter start_time = 0, parameter end_time = 100)(
    input wire in,
    output reg out = 0
);

    reg [31:0] counter = start_time;

    always @(posedge in) begin
         counter <= (counter >= (end_time >> 1)) ? 1 : counter + 1;
         out <= (counter >= (end_time >> 1)) ? ~out : out;
    end

endmodule
