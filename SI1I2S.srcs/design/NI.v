//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: NI
// Module Name: networkInterface
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

//Input block

module networkInterface_inputBlock #(parameter NETWORK_SIZE=256, MAX_INDEX_INPUT=3, MAX_INDEX_PP=10, MAX_INDEX=10)(
input clk,
input clk2,
input rst,
input [4+$clog2(NETWORK_SIZE):0] SWITCH_NI_packet,
input SWITCH_NI_valid,
output SWITCH_NI_ready,
output [1:0] NI_PE_statuses,
output \NI_PE_pr[0][0] ,
output \NI_PE_pr[1][0] ,
output [2:0] NI_PE_initialStatus, 
output NI_PE_valid,  
input NI_PE_ready
    );

localparam CONF_PR_0=3'b000, CONF_PR_1=3'b001, CONF_PI_0=3'b010, CONF_PI_1=3'b011, CONF_INPUT=3'b100, CONF_STATUS=3'b101, RUN=3'b110;  

wire [4+$clog2(NETWORK_SIZE):0] packet;
wire valid;

wire [2:0] mode;
wire [1:0] pr_confEn, pi_confEn;
wire input_confEn, status_confEn;
wire [$clog2(MAX_INDEX)-1:0] index;
wire isLast, isNext;
wire [$clog2(NETWORK_SIZE*2-1)-1:0] inputNum;
wire buffer_valid, \pi[0][0] , \pi[1][0] , isNextSeqNum, buffer_ready;


afifo afifo (
.m_aclk(clk),                // input wire m_aclk
.s_aclk(clk2),                // input wire s_aclk
.s_aresetn(~rst),          // input wire s_aresetn
.s_axis_tvalid(SWITCH_NI_valid),  // input wire s_axis_tvalid
.s_axis_tready(SWITCH_NI_ready),  // output wire s_axis_tready
.s_axis_tdata(SWITCH_NI_packet),    // input wire [15 : 0] s_axis_tdata
.m_axis_tvalid(valid),  // output wire m_axis_tvalid
.m_axis_tready(valid),  // input wire m_axis_tready
.m_axis_tdata(packet)    // output wire [15 : 0] m_axis_tdata
    );

buffer #(.MAX_INPUT(2*(NETWORK_SIZE-1))) buffer(
clk, 
rst,
buffer_valid,
packet[2],
packet[1],
packet[0],
\pi[0][0] ,
\pi[1][0] ,
inputNum,
isNextSeqNum,
NI_PE_statuses,
buffer_ready
    );
assign buffer_ready=(mode==RUN)&NI_PE_ready;

workingModeStateMachine #(.MAX_INDEX_PP(MAX_INDEX_PP), .MAX_INDEX_INPUT(MAX_INDEX_INPUT), .MAX_INDEX(MAX_INDEX)) workingModeStateMachine(
clk,
rst,
valid,
packet[(3+$clog2(NETWORK_SIZE))+:2],
index,
mode,
pr_confEn,
pi_confEn,
input_confEn,
status_confEn,
isNext,
isLast,
buffer_valid
    );

indexCounter #(.MAX_INDEX(MAX_INDEX)) indexCounter(
clk,
rst,
isNext,
isLast,
index
    );

shiftRegister #(.SEGMENT_WIDTH(3+$clog2(NETWORK_SIZE)),.MAX_INDEX(MAX_INDEX_PP)) \pr[0] (
clk,
mode,
packet[$clog2(NETWORK_SIZE)+2:0],
index,
\NI_PE_pr[0][0] ,
pr_confEn[0]
);

shiftRegister #(.SEGMENT_WIDTH(3+$clog2(NETWORK_SIZE)),.MAX_INDEX(MAX_INDEX_PP)) \pr[1] (
clk,
mode,
packet[$clog2(NETWORK_SIZE)+2:0],
index,
\NI_PE_pr[1][0] ,
pr_confEn[1]
);

shiftRegister #(.SEGMENT_WIDTH(3+$clog2(NETWORK_SIZE)),.MAX_INDEX(MAX_INDEX_PP)) \pi[0] (
clk,
mode,
packet[$clog2(NETWORK_SIZE)+2:0],
index,
\pi[0][0] ,
pi_confEn[0]
);

shiftRegister #(.SEGMENT_WIDTH(3+$clog2(NETWORK_SIZE)),.MAX_INDEX(MAX_INDEX_PP)) \pi[1] (
clk,
mode,
packet[$clog2(NETWORK_SIZE)+2:0],
index,
\pi[1][0] ,
pi_confEn[1]
);

inputNumber #(.MAX_INPUT(2*(NETWORK_SIZE-1)), .SEGMENT_WIDTH(3), .MAX_INDEX(MAX_INDEX_INPUT)) inputNumber(
clk,
input_confEn,
index,
packet[2:0],
inputNum
);

assign NI_PE_valid=(mode==RUN)?isNextSeqNum:status_confEn;
assign NI_PE_initialStatus=packet[2:0];

endmodule

//Output block

module networkInterface_outputBlock #(parameter ADDRESS=0, NETWORK_SIZE=256)(
input clk,
input clk2,
input rst,
input [1:0] PE_NI_statuses,
input PE_NI_valid,
output PE_NI_ready,
output [4+$clog2(NETWORK_SIZE):0] NI_SWITCH_packet,
output NI_SWITCH_valid,
input NI_SWITCH_ready
    );

wire [4+$clog2(NETWORK_SIZE):0] packet;
wire valid, ready;

wire isNextSeqNum, currSeqNum;

packetTransferStateMachine packetTransferStateMachine(
clk,
rst,
PE_NI_valid,
PE_NI_statuses,
PE_NI_ready,
valid,
packet[0],
packet[2],
ready,
isNextSeqNum
    );

flipFlop currSeqNum_flipFlop (
clk, 
rst,
isNextSeqNum,
~currSeqNum,
currSeqNum
    );

assign packet[1]=currSeqNum;
assign packet[3+:$clog2(NETWORK_SIZE)]=ADDRESS;
assign packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b01;

afifo afifo (
.m_aclk(clk2),                // input wire m_aclk
.s_aclk(clk),                // input wire s_aclk
.s_aresetn(~rst),          // input wire s_aresetn
.s_axis_tvalid(valid),  // input wire s_axis_tvalid
.s_axis_tready(ready),  // output wire s_axis_tready
.s_axis_tdata(packet),    // input wire [15 : 0] s_axis_tdata
.m_axis_tvalid(NI_SWITCH_valid),  // output wire m_axis_tvalid
.m_axis_tready(NI_SWITCH_ready),  // input wire m_axis_tready
.m_axis_tdata(NI_SWITCH_packet)    // output wire [15 : 0] m_axis_tdata
    );

endmodule