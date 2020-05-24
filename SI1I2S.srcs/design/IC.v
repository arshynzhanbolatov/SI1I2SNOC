//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: IC
// Module Name: indexCounter
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module indexCounter #(parameter MAX_INDEX=10)(
input clk,
input rst,
input isNext,
input isLast,
output [$clog2(MAX_INDEX)-1:0] index
    );

register #(.WIDTH($clog2(MAX_INDEX))) register (
clk, 
rst|isNext&isLast,
isNext,
(index+1),
index
);
    
endmodule
