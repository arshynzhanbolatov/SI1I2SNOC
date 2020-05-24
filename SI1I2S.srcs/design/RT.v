//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: RT
// Module Name: routingTable
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module routingTable #(parameter NETWORK_SIZE=256)(
input clk,
input writeEnable,
input [$clog2(NETWORK_SIZE)-1:0] writeAddress,
input [$clog2(NETWORK_SIZE):0] readAddress,
input [9:0] in,
output reg [4:0] out
); 

wire [9:0] dpo;

generate
    if(NETWORK_SIZE==256) 
    begin   
        dram_256 dram (
          .a(writeAddress),       
          .d(in),       
          .dpra(readAddress[1+:$clog2(NETWORK_SIZE)]),  
          .clk(clk),   
          .we(writeEnable),     
          .dpo(dpo)    
        );
    end
    else if(NETWORK_SIZE==1024)
    begin
        dram_1024 dram (
          .a(writeAddress),        
          .d(in),       
          .dpra(readAddress[1+:$clog2(NETWORK_SIZE)]),  
          .clk(clk),   
          .we(writeEnable),      
          .dpo(dpo)    
        );
    end
endgenerate

always @(*)
begin
    case(readAddress[0])
    1'b1: out=dpo[9:5];
    1'b0: out=dpo[4:0];
    endcase
end
   
endmodule
