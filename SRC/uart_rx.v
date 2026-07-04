//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 10:42:31
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
#(
parameter clk_freq=1000000,//input or systems clock
parameter  baud_rate=9600//uart baud_rate 
)
(
input clk, //input clk or systems clock
input rst, //input rst signal
input rx,  //
output reg done,//output signal =1 when data receiving will be completed
output reg [7:0] rxdata//incoming data 
);


//baud_rate generator 
localparam clkcount=(clk_freq/baud_rate);//

integer count=0;//we make a count variable which tracks the count for uartclk
integer counts=0;//this count for the 8 bit data transmission

reg uclk=0;//that is the uart clock(slower clock or the bit duration)


//uart_clock generator module//..................
always @(posedge clk)
begin
  if(count<clkcount/2) //when count value<clkcount/2 count gets incremntd 
  count<=count+1;
  
  else begin
    count<=0;//when count crossed the clkcount/2 value it will restet for again counting form start
    uclk<=~uclk;
  end
end

reg [1:0] state;
localparam IDLE=2'b00; // representing the idle state where no transmission is happen
localparam START=2'b01;//

always @(posedge uclk)
begin
  if(rst) begin //when rst signal is high
    rxdata<=8'h00; //no data received
    counts<=0; 
    done<=1'b0;
    state<=IDLE;
  end
  else begin
    case(state)

    IDLE:
    begin
      // rxdata<=8'h00;//no data received
      counts<=0;
      done<=1'b0;
      
      if(rx==1'b0) begin//jif rx=0 means start bit dering receivd is high means transmitted data is incoming
       state<=START;//move to the start state
       rxdata <= 8'h00;
      end
      else begin
        state<=IDLE;//else remains in the idle state
      end
    end


    START:
    begin
    if(counts<=7)
    begin
      counts<=counts+1;//counts gets incremented
      rxdata<={rx,rxdata[7:1]};//right shifting of the data bec receiver first gets the LSB bit
      state<=START;
    end
    else begin
      counts<=0;
      done<=1'b1;
      state<=IDLE;
    end
  end
    default:state<=IDLE;
    endcase
  end
end

endmodule
