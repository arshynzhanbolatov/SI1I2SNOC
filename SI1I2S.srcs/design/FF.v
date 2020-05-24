//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: FF
// Module Name: flipFlop
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////



module flipFlop (
input clk, 
input reset,
input en,
input d,
output reg q
    );

always @(posedge clk) 
begin
    if(reset)
        q<=0;
    else if(en)
        q<=d;
end 
  
endmodule
