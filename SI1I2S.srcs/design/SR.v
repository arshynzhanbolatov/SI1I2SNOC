//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: SR
// Module Name: shiftRegister
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module shiftRegister #(parameter SEGMENT_WIDTH=11, integer MAX_INDEX=10) (
input clk,
input [2:0] mode,
input [SEGMENT_WIDTH-1:0] segment,
input [$clog2(MAX_INDEX)-1:0] index,
output \shiftRegister[0] ,
input confEn
);
     
localparam CONF_PR_0=3'b000, CONF_PR_1=3'b001, CONF_PI_0=3'b010, CONF_PI_1=3'b011, CONF_INPUT=3'b100, CONF_STATUS=3'b101, RUN=3'b110;  
  
reg [99:0] shiftRegister;
integer i;

always @(posedge clk)
begin
    case(mode)
    RUN:
    begin
        shiftRegister[0]<=shiftRegister[99];
        for(i=0;i<99;i=i+1) 
            shiftRegister[i+1]<=shiftRegister[i];      
    end  
    default:
    begin 
        if(confEn) 
            shiftRegister[index*SEGMENT_WIDTH+:SEGMENT_WIDTH]<=segment; 
    end  
    endcase
end

assign \shiftRegister[0] =shiftRegister[0];
endmodule
