`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2024 02:18:52 PM
// Design Name: 
// Module Name: stopwatch
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


module stopwatch(clk, btnS, btnR, sw, an, seg);

input clk;
input btnS, btnR;
input [7:0] sw;
output reg [3:0] an;
output reg [7:0] seg;

reg [3:0] seg_value;
reg [3:0] seg3, seg2, seg1, seg0;
reg adj_sec = 0;
reg adj = 0;
reg digits_on = 0;

wire one_hz_clk;
wire two_hz_clk;
wire segment_clk;
wire blink_clk;
wire debounce_clk;

reg [1:0] state;
reg [31:0] sec_counter = 0;
reg [1:0] seg_index = 0;
	
// instantiate four clocks with clock divider
clock #(.start_time(0), .end_time(100_000_000)) my_one_hz_clk(.in(clk), .out(one_hz_clk));
clock #(.start_time(0), .end_time(50_000_000)) my_two_hz_clk(.in(clk), .out(two_hz_clk));
clock #(.start_time(0), .end_time(1_000)) my_segment_clk(.in(clk), .out(segment_clk));
clock #(.start_time(0), .end_time(10_000_000)) my_blink_clk(.in(clk), .out(blink_clk));
clock #(.start_time(0), .end_time(5_000_000)) my_debounce_clk(.in(clk), .out(debounce_clk));



always @(posedge segment_clk) begin
    adj_sec = sw[1];
    adj = sw[0];

	seg_index = seg_index + 1;
	an = 4'b1111;
	an[seg_index] = 0;

	// set the number of each digit
	seg0 = (sec_counter % 60)  % 10;
	seg1 = (sec_counter % 60)  / 10;
	seg2 = (sec_counter / 60)  % 10;
	seg3 = (sec_counter / 600) % 10;

    case (seg_index)
        0: seg_value = (digits_on || ~adj_sec) ? seg0 : 10;
        1: seg_value = (digits_on || ~adj_sec) ? seg1 : 10;
        2: seg_value = (digits_on ||  adj_sec) ? seg2 : 10;
        3: seg_value = (digits_on ||  adj_sec) ? seg3 : 10;
    endcase

	case (seg_value)
		0: seg = ~8'b11111100;
		1: seg = ~8'b01100000;
		2: seg = ~8'b11011010;
		3: seg = ~8'b11110010;
		4: seg = ~8'b01100110;
		5: seg = ~8'b10110110;
		6: seg = ~8'b10111110;
		7: seg = ~8'b11100000;
		8: seg = ~8'b11111110;
		9: seg = ~8'b11110110;
		default: seg = 8'b11111111;
	endcase
end

reg [1:0] reset_state = 2'b00;
reg [2:0] pause_state = 3'b000;
reg stop_tick = 0;
reg has_ticked_once = 0;

always @(posedge debounce_clk) begin
   reset_state[1:0] = {btnR, reset_state[1]};
   pause_state[2:0] = {pause_state[2] && btnS, btnS, pause_state[1]};

   if (reset_state == 2'b11) begin
       reset_state = 2'b00;
       sec_counter   = 0;
   end else if (pause_state == 3'b011) begin
       pause_state = 3'b100;
       stop_tick   = ~stop_tick;
   end else if (adj ? two_hz_clk : one_hz_clk) begin
       if (~has_ticked_once && ~stop_tick) begin
           has_ticked_once = 1;
           if (adj && ~adj_sec) begin
               sec_counter = (sec_counter / 50 >= 99)
                         ? (sec_counter % 60)
                         : (sec_counter + 60);
           end else if (adj) begin
               sec_counter = (sec_counter / 60) * 60 + ((sec_counter + 1) % 60);
           end else begin
               sec_counter = sec_counter + 1;
           end
       end
   end else has_ticked_once = 0;
end

always @(posedge blink_clk) begin
    digits_on = (~adj || ~digits_on);
end

endmodule