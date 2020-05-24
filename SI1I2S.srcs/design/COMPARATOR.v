//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: COMPARATOR
// Module Name: comparator
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module comparator #(parameter WIDTH=4) (
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    output \= ,
    output \> ,
    output \< 
    );
    
    assign \= =in0==in1;
    assign \> =in0>in1;
    assign \< =in0<in1;
    
endmodule
