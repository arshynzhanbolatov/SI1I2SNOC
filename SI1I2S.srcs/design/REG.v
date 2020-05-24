//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: REG
// Module Name: register
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////



module register #(parameter WIDTH=9) (
input clk, 
input reset,
input en,
input [WIDTH-1:0] in,
output [WIDTH-1:0] out
    );

genvar i;
generate
    for(i=0;i<WIDTH;i=i+1)
    begin: index
        flipFlop flipFlop (clk, reset, en, in[i], out[i]);
    end
endgenerate
  
endmodule