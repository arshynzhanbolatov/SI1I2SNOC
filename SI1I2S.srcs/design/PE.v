//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: PE
// Module Name: processingElement
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module processingElement(
input clk,
input rst,
input [1:0] NI_PE_statuses,
input \NI_PE_pr[0][0] ,
input \NI_PE_pr[1][0] ,
input [2:0] NI_PE_initialStatus,  
input NI_PE_valid,
output NI_PE_ready,
output [1:0] PE_NI_statuses,
output PE_NI_valid,
input PE_NI_ready
 );

wire [1:0] input_statuses, output_statuses;
wire \input_pr[0][0] ;
wire \input_pr[1][0] ;
wire [2:0] input_initialStatus;
wire input_valid, output_valid;
wire input_ready, output_ready;
wire [1:0] input_prioritizedStatuses;

registerSlice input_registerSlice (
  .aclk(clk),                    // input wire aclk
  .aresetn(~rst),              // input wire aresetn
  .s_axis_tvalid(NI_PE_valid),  // input wire s_axis_tvalid
  .s_axis_tready(NI_PE_ready),  // output wire s_axis_tready
  .s_axis_tdata({NI_PE_statuses, \NI_PE_pr[0][0] , \NI_PE_pr[1][0] , NI_PE_initialStatus}),    // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(input_valid),  // output wire m_axis_tvalid
  .m_axis_tready(input_ready),  // input wire m_axis_tready
  .m_axis_tdata({input_statuses, \input_pr[0][0] , \input_pr[1][0] , input_initialStatus})    // output wire [7 : 0] m_axis_tdata
);

priorityLogic priorityLogic(
clk,
rst,
input_statuses,
input_prioritizedStatuses
    );

infectionStatusStateMachine infectionStatusStateMachine(
clk,
rst,
input_prioritizedStatuses,
\input_pr[0][0] ,
\input_pr[1][0] ,
input_initialStatus,
input_valid,
output_statuses,
output_ready
    );

assign input_ready=output_ready|~input_valid;
assign output_valid=input_valid;

registerSlice output_registerSlice (
  .aclk(clk),                    // input wire aclk
  .aresetn(~rst),              // input wire aresetn
  .s_axis_tvalid(output_valid),  // input wire s_axis_tvalid
  .s_axis_tready(output_ready),  // output wire s_axis_tready
  .s_axis_tdata(output_statuses),    // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(PE_NI_valid),  // output wire m_axis_tvalid
  .m_axis_tready(PE_NI_ready),  // input wire m_axis_tready
  .m_axis_tdata(PE_NI_statuses)    // output wire [7 : 0] m_axis_tdata
);

endmodule