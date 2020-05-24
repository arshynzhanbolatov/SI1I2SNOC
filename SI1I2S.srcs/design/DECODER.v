//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: DECODER
// Module Name: decoder
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module decoder #(parameter WIDTH=2)(
input en,
input [WIDTH-1:0] in,
output reg [2**WIDTH-1:0] out
    );
    
integer i;

always @(*)
begin
    for(i=0;i<2**WIDTH;i=i+1)
    begin
        if(en&&(i==in))
            out[i]=1'b1;
        else
            out[i]=1'b0;
    end
end    

endmodule
