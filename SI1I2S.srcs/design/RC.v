//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019
// Design Name: RC
// Module Name: ringCounter
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module ringCounter #(parameter WIDTH=5)(
    input clk,
    input rst,
    output reg [WIDTH-1:0] out
    );
    
integer i;

always @(posedge clk)
begin 
    if(rst)
    begin
        for(i=0; i<WIDTH; i=i+1) 
        begin   
            if(i==0)
                out[i]<=1'b1;
            else
                out[i]<=1'b0; 
        end 
    end
    else
    begin
        for(i=0; i<WIDTH; i=i+1) 
        begin   
            if(i==0)
                out[i]<=out[WIDTH-1];
            else
                out[i]<=out[i-1]; 
        end 
    end
end
endmodule