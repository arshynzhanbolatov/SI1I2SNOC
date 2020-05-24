//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: IN
// Module Name: inputNum
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module inputNumber #(parameter MAX_INPUT=510, SEGMENT_WIDTH=3, integer MAX_INDEX=3 )(
input clk,
input confEn,
input [$clog2(MAX_INDEX)-1:0] index,
input [SEGMENT_WIDTH-1:0] inputNumSegment,
output  reg [$clog2(MAX_INPUT+1)-1:0] inputNum
);
    
always @(posedge clk)
begin
    if(confEn)
            inputNum[index*SEGMENT_WIDTH+:SEGMENT_WIDTH]<=inputNumSegment;
end
endmodule

