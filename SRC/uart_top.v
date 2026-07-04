module uart_top
#(
parameter clk_freq=1000000,
parameter baud_rate=9600

)
(
  //input signal
  input clk, //input clk signal or system clk 
  input rst, //reset signal
  input rx,  //receiver input
  input [7:0] dintx,//input8 bit data loaded parally to the uart
  input newd, //whenever user have a new data it will convey by making the newd=1 

  //output signal
  output tx,//one bit output of transmitter
  output [7:0] doutrx,//receiver 8 bit output data
  output donetx,//that confirms the transmission r
  output donerx //that confirms the recption
);

//module instantiation

uart_tx txuut(clk, rst, newd, dintx, tx, donetx);
uart_rx rxuut (clk, rst, rx, donerx, doutrx);

endmodule