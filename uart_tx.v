module uart_tx
#(parameter clk_freq=1000000,//input clock from the user on which our module will be operated (1MHz)
parameter baud_rate=9600//output baud rate
)
(
  input clk,    //clock input
  input rst,    //reset the transmitter
  input newd,   //whenever user have a new data it will convey by making the newd=1 
  input [7:0] tx_data,//8 bit of data that will transmitted to the receiver
  output reg tx,//serially transmitting the data one by one
  output reg donetx //donetx=1 when all the 8 bit of data is transmitted
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

//reset decoder............... 
reg [7:0] din;//input data of 8 bits

reg [1:0] state;//declare the 4 states 
localparam IDLE=2'b00; // representing the idle state where no transmission is happen
localparam START=2'b01;// when start bit=0
localparam TRANSFER=2'b10;//transmitting state
localparam DONE=2'b11;//when transmission is completed

always @(posedge uclk) //we use the slower clk
begin
  if(rst) begin
  state<=IDLE; //if rst =1 then we stay in the idle state
end

else begin
case(state)
IDLE:
begin
  counts<=0;
  tx<=1'b1;//in the idle state it transmitting 1
  donetx<=1'b0;


if(newd) //when newdata is incoming
begin
state<=TRANSFER;//move to transfer state
din<=tx_data;   //sample the data which is in temporay bus
tx<=1'b0;     //start of the transmission (start bit=0)
end
else 
  state<=IDLE;
end

TRANSFER:
begin
  if(counts<=7) begin //when 8 bits of data is transmitting
    counts<=counts+1; //counts gets increamented one by one
    tx<=din[counts];//we will first send din[counts=0]=LSB and similarly up to MSB
    state<=TRANSFER; // we will remain in transfer state
  end
  else begin
    counts<=0;//when 8 bit of data transmission is commpled count reset to 0
    tx<=1'b1;//this is the stop bit
    state<=IDLE;// we will move to idle state
    donetx<=1'b1;//done signal gets high after completion od the data
  end
end



default :state<=IDLE; 
endcase
end
end
endmodule