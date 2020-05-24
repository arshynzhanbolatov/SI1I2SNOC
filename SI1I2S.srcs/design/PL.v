//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: PL
// Module Name: priorityLogic
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module priorityLogic(
input clk,
input rst,
input [1:0] in,
output reg [1:0] out
    );

reg priority;

always @(posedge clk)
begin
    if(rst)
        priority<=0;
    else
        priority<=~priority;
end

always @(*)
begin
    case(priority)
    1'b0:
    begin
        casex(in)
        2'bx1:out=2'b01;
        default:out=in;
        endcase
    end
    1'b1:
    begin
        casex(in)
        2'b1x:out=2'b10;
        default:out=in;
        endcase    
    end
    endcase
end

endmodule
