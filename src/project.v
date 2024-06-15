////////////////////////////////////////////////////////////////////////////////// 
// By: Ritish Behera 
// Company : National Institute of Technology, Warangal
//
// Create Date: 17.04.2024 16:05:21
// Design Name: Digital 12 Hour Clock
// Module Name: digitalClock
// Project Name: 12 Hour Clock Implemented and Tested on FPGA Board
// Target Device: Artix-7 Power FPGA Board 
// Tool Versions: 10:01 02-05-2024
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tt_um_ritish_behera_digitalClock(

    input wire clk,        					// Clock signal
    input wire reset,  						// Reset button signal
  	input en,								// Enable
  	output reg [7:0]dispEn,					// Output disply position
  	output reg [6:0] seg,					// Seven segment digit code
  	output dp								// Seven Segment Display Dot
); 
  
  reg [3:0] hour2,hour1,minute2,minute1,sec2,sec1,display;
  wire tranSpeed1,tranSpeed2;
  reg [2:0] display_counter=3'b000 ;
  
  
  user_clock1 g1(clk,tranSpeed1);				// For slowing down internal clock for counting
  user_clock2 g2(clk,tranSpeed2);				// For slowing down internal clock for changing display 
  
  assign dp=1'b1;								//For seven seg display dots to be off 
  
  always @(posedge tranSpeed1 or  posedge reset) begin		// Code for 12 hour clock with reset signal
        if (reset) begin
            sec1 <= 4'b0000;
            sec2 <= 4'b0000;
            minute1 <= 4'b0000;
            minute2 <= 4'b0000;
            hour1 <= 4'b0000;
            hour2 <= 4'b0000;
        end
        else begin
            if (en) begin
                if (sec1 == 4'b1001) begin 
                    sec1 <= 4'b0000;
                  if (sec2 == 4'b0101) begin
                        sec2 <= 4'b0000;
                        if (minute1 == 4'b1001) begin
                            minute1 <= 4'b0000;
                          if (minute2 == 4'b0101) begin
                                minute2 <= 4'b0000;
                                if (hour1 == 4'b1001) begin
                                    hour1 <= 4'b0000;
                                    if (hour2 == 1 && hour1 ==1 && minute2 ==5 && minute1 ==9 && sec2 ==5 && sec1 ==9) begin														// When clock reaches 11:59:59 it resets
                                        sec1 <= 4'b0000;
                                        sec2 <= 4'b0000;
                                        minute1 <= 4'b0000;
                                        minute2 <= 4'b0000;
                                        hour1 <= 4'b0000;
                                        hour2 <= 4'b0000;
                                    end
                                    else begin
                                        hour2 <= hour2 + 1;
                                    end
                                end
                                else begin
                                    hour1 <= hour1 + 1;
                                end
                            end
                            else begin
                                minute2 <= minute2 + 1;
                            end
                        end
                        else begin
                            minute1 <= minute1 + 1;
                        end
                    end
                    else begin
                        sec2 <= sec2 + 1;
                    end
                end
                else begin
                    sec1 <= sec1 + 1;
                end
            end
        end
    end
    
    
    
  always@(posedge tranSpeed1)							// Codes for showing digit 0-9 in seven segment display
    begin
            case(display)
                0: seg <=7'b0000001;
                1: seg <=7'b1001111;
                2: seg <=7'b0010010;
                3: seg <=7'b0000110;
                4: seg <=7'b1001100;
                5: seg <=7'b0100100;
                6: seg <=7'b0100000;
                7: seg <=7'b0001111;
                8: seg <=7'b0000000;
                9: seg <=7'b0000100;
                default: seg <=7'b1111111;
              endcase
                              
    end
    
    
always @(posedge tranSpeed2) begin				// Chooses which display to be turned on
    case(display_counter)
        3'b000: begin
            display<=sec1;
            dispEn <= 8'b11111110; 				// First display turns on
        end
        3'b001: begin
            display<=sec2;
            dispEn <= 8'b11111101; 				// Second display turns on
        end
        3'b010: begin
            display<=minute1;
            dispEn <= 8'b11111011; 				// Third display turns on
        end
        3'b011: begin
            display<=minute2;
            dispEn <= 8'b11110111;				// Fourth display turns on 
        end
        3'b100: begin
            display <=hour1;
            dispEn <= 8'b11101111; 				// Fifth display turns on
        end
        3'b101: begin
            display <=hour2;
            dispEn <= 8'b11011111; 				// Sixth display turns on
        end
    endcase

    display_counter <= display_counter + 1;			// Increment the display counter
end

endmodule

 


module user_clock1(clk,tranSpeed);				// module for fpga clock1 to control the transition speed of 1 to 9

  input clk;
  output tranSpeed;
  
  reg clk_out = 0;
  reg [25:0] count = 0;
  
  always @(posedge clk)
 begin
    count <= count + 1;
   if (count == 1000000) begin
      	count <= 0;
      	clk_out <= ~clk_out;
      end
  end
  
  assign tranSpeed = clk_out;
endmodule




module user_clock2(clk,tranSpeed);				// module for fpga clock2 to control transition speed of turning on different displays
  
  input clk;
  output tranSpeed;
  
  reg clk_out = 0;
  reg [25:0] count = 0;
  
  always @(posedge clk)
 begin
    count <= count + 1;
   if (count == 10) begin
      	count <= 0;
      	clk_out <= ~clk_out;
      end
  end
  
  assign tranSpeed = clk_out;
endmodule

