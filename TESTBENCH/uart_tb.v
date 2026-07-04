`timescale 1s / 1ms
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 10:50:35
// Design Name: 
// Module Name: uart_tb
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


module uart_tb;
reg clk=0;
reg rst=0;
reg rx=1;
reg [7:0] dintx;
reg newd;
wire tx;
wire [7:0] doutrx;
wire donetx;
wire donerx;

integer i, j,k,l;

//instatiating the top module
uart_top #(1000000, 9600) dut (clk, rst, rx, dintx, newd, tx, doutrx, donetx, donerx);

always #5 clk=~clk;

//temporary reg that will hold the data
reg [7:0] rx_data=0;//serially collecting the on rx_data and when donerx=1 then we can compare the data with doutrx
reg [7:0] tx_data=0;//serially collecting the on tx_data and when donetx=1 then we can compare the data with dintx

initial begin

  $dumpfile("uart_waves.vcd"); 
  $dumpvars(0, uart_tb);

  rst=1;        //keep the reset =1
  newd=0;
  repeat(5) @(posedge clk); //keep it for 5 clock tick
  rst=0;         //then rst=0

//for the transmitter 
//we are sending 10 random transcation to dintx
for(i=0;i<10;i=i+1)
begin
  rst=0;
  newd=1;
  dintx=$random;//random signal

 //wait for the psedge of the uclk comes
wait(tx==0);
@(posedge dut.txuut.uclk);

for(j=0;j<8;j=j+1)
begin
  @(posedge dut.txuut.uclk);
  tx_data={tx,tx_data[7:1]};//reverse the bits of the data to  tx_data 
end

//wait untill donetx becomes high
@(posedge donetx);

// Compare the transmitted data with the original data
    if (tx_data == dintx)
      $display("TX PASS: dintx = %b, tx_data = %b", dintx, tx_data);
    else
      $display("TX FAIL: dintx = %b, tx_data = %b", dintx, tx_data);
  end

//for the receiver

for(k=0;k<10;k=k+1)
begin
  rst=0;
  newd=0;

  rx=1'b0;//during start of the reception  rx=0
@(negedge dut.rxuut.uclk); //we keep rx=0 untill single clk tick of uart arrives

for(l=0;l<8;l=l+1)
begin
  @(negedge dut.rxuut.uclk);
  
  rx=$random;//we generate the random data and simultaneously store it in reverse order into the rx_data
  rx_data={rx,rx_data[7:1]};
end


  // 4. Wait for the receiver to assert done
  @(posedge donerx);


// Compare the received data with the DUT's output data
    if (rx_data == doutrx)
      $display("RX PASS: rx_data = %b, doutrx = %b", rx_data, doutrx);
    else
      $display("RX FAIL: rx_data = %b, doutrx = %b", rx_data, doutrx);
end


// Stop simulation gracefully
  $finish;

end

endmodule
