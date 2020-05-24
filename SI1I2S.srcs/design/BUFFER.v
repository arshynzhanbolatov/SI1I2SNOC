//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: BUFFER
// Module Name: buffer
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module buffer #(parameter MAX_INPUT=510)(
input clk, 
input rst,
input valid,
input layer,
input seqNum,
input status,
input \pi[0][0] ,
input \pi[1][0] ,
input [$clog2(MAX_INPUT+1)-1:0] inputNum,
output isNextSeqNum,
output [1:0] statuses,
input ready
    );

wire cumStatus[1:0][1:0];
wire [3:0] cumStatus_writeEn;
wire [1:0] counter_writeEn;
wire [1:0] reset;
wire [$clog2(MAX_INPUT+1)-1:0] counter[1:0];
wire currSeqNum;

decoder #(.WIDTH(2)) cumStatus_writeEn_decoder(
.en(valid),
.in({layer,seqNum}),
.out(cumStatus_writeEn)
    );

decoder #(.WIDTH(1)) counter_writeEn_decoder(
.en(valid),
.in(seqNum),
.out(counter_writeEn)
    );

decoder #(.WIDTH(1)) reset_decoder(
.en(ready&isNextSeqNum),
.in(currSeqNum),
.out(reset)
    );    

flipFlop \cumStatus_flipFlop[0][0] (
.clk(clk), 
.reset(rst|reset[0]),
.en(cumStatus_writeEn[0]),
.d((status&\pi[0][0] )|cumStatus[0][0]),
.q(cumStatus[0][0])
);

flipFlop \cumStatus_flipFlop[0][1] (
.clk(clk), 
.reset(rst|reset[1]),
.en(cumStatus_writeEn[1]),
.d((status&\pi[0][0] )|cumStatus[0][1]),
.q(cumStatus[0][1])
);

flipFlop \cumStatus_flipFlop[1][0] (
.clk(clk), 
.reset(rst|reset[0]),
.en(cumStatus_writeEn[2]),
.d((status&\pi[1][0] )|cumStatus[1][0]),
.q(cumStatus[1][0])
);

flipFlop \cumStatus_flipFlop[1][1] (
.clk(clk), 
.reset(rst|reset[1]),
.en(cumStatus_writeEn[3]),
.d((status&\pi[1][0] )|cumStatus[1][1]),
.q(cumStatus[1][1])
);  

register #(.WIDTH($clog2(MAX_INPUT+1))) \counter_register[0] (
clk, 
rst|reset[0],
counter_writeEn[0],
(counter[0]+1),
counter[0]
);

register #(.WIDTH($clog2(MAX_INPUT+1))) \counter_register[1] (
clk, 
rst|reset[1],
counter_writeEn[1],
(counter[1]+1),
counter[1]
);

flipFlop \currSeqNum_flipFlop (
.clk(clk), 
.reset(rst),
.en(isNextSeqNum&ready),
.d(~currSeqNum),
.q(currSeqNum)
);  

assign isNextSeqNum=counter[currSeqNum]==inputNum;
assign statuses={cumStatus[1][currSeqNum], cumStatus[0][currSeqNum]};

endmodule
