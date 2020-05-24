//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: SI1I2NOC
// Module Name: SI1I2SNetworkOnChip
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module SI1I2SNetworkOnChip #(parameter NETWORK_SIZE=256, X_SIZE=16, Y_SIZE=16, FIFO_DEPTH=4, MAX_INDEX_INPUT=3, MAX_INDEX_PP=10, MAX_INDEX=10)(
input clk_gen,
output clk_host,
input rst,
input [4+$clog2(NETWORK_SIZE):0] input_packet,
input input_valid,
output input_ready,
output [4+$clog2(NETWORK_SIZE):0] output_packet,
output output_valid,
input output_ready,
output locked
);   

wire clk_pe, clk_switch, clk_fb;

wire [4+$clog2(NETWORK_SIZE):0] output_fifo_packet, input_fifo_packet;
wire output_fifo_valid, input_fifo_valid;
wire output_fifo_ready, input_fifo_ready;

wire [1:0] NI_PE_statuses[Y_SIZE-1:0][X_SIZE-1:0], PE_NI_statuses[Y_SIZE-1:0][X_SIZE-1:0];
wire [2:0] NI_PE_initialStatus[Y_SIZE-1:0][X_SIZE-1:0];
wire  \NI_PE_pr[0][0] [Y_SIZE-1:0][X_SIZE-1:0], \NI_PE_pr[1][0] [Y_SIZE-1:0][X_SIZE-1:0];
wire NI_PE_valid[Y_SIZE-1:0][X_SIZE-1:0], PE_NI_valid[Y_SIZE-1:0][X_SIZE-1:0];
wire NI_PE_ready[Y_SIZE-1:0][X_SIZE-1:0], PE_NI_ready[Y_SIZE-1:0][X_SIZE-1:0];

wire [4+$clog2(NETWORK_SIZE):0] west_east_packet[Y_SIZE-1:0][X_SIZE-2:0], east_west_packet[Y_SIZE-1:0][X_SIZE-2:0], south_north_packet[Y_SIZE-2:0][X_SIZE-1:0], north_south_packet[Y_SIZE-2:0][X_SIZE-1:0], SWITCH_NI_packet[Y_SIZE-1:0][X_SIZE-1:0], NI_SWITCH_packet[Y_SIZE-1:0][X_SIZE-1:0];
wire west_east_valid[Y_SIZE-1:0][X_SIZE-2:0], east_west_valid[Y_SIZE-1:0][X_SIZE-2:0], south_north_valid[Y_SIZE-2:0][X_SIZE-1:0], north_south_valid[Y_SIZE-2:0][X_SIZE-1:0], SWITCH_NI_valid[Y_SIZE-1:0][X_SIZE-1:0], NI_SWITCH_valid[Y_SIZE-1:0][X_SIZE-1:0];
wire west_east_ready[Y_SIZE-1:0][X_SIZE-2:0], east_west_ready[Y_SIZE-1:0][X_SIZE-2:0], south_north_ready[Y_SIZE-2:0][X_SIZE-1:0], north_south_ready[Y_SIZE-2:0][X_SIZE-1:0], SWITCH_NI_ready[Y_SIZE-1:0][X_SIZE-1:0], NI_SWITCH_ready[Y_SIZE-1:0][X_SIZE-1:0];

PLLE2_BASE #(
  .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
  .CLKFBOUT_MULT(15),        // Multiply value for all CLKOUT, (2-64)
  .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
  .CLKIN1_PERIOD(10),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
  // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
  .CLKOUT0_DIVIDE(6),
  .CLKOUT1_DIVIDE(5),
  .CLKOUT2_DIVIDE(6),
  // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
  .CLKOUT0_DUTY_CYCLE(0.5),
  .CLKOUT1_DUTY_CYCLE(0.5),
  .CLKOUT2_DUTY_CYCLE(0.5),
  // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
  .CLKOUT0_PHASE(0.0),
  .CLKOUT1_PHASE(0.0),
  .CLKOUT2_PHASE(0.0),
  .DIVCLK_DIVIDE(1),        // Master division value, (1-56)
  .REF_JITTER1(0.0),        // Reference input jitter in UI, (0.000-0.999).
  .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
)
pll (
  // Clock Outputs: 1-bit (each) output: User configurable clock outputs
  .CLKOUT0(clk_pe),   // 1-bit output: CLKOUT0
  .CLKOUT1(clk_switch),   // 1-bit output: CLKOUT1
  .CLKOUT2(clk_host),   // 1-bit output: CLKOUT2
  // Feedback Clocks: 1-bit (each) output: Clock feedback ports
  .CLKFBOUT(clk_fb), // 1-bit output: Feedback clock
  .LOCKED(locked),     // 1-bit output: LOCK
  .CLKIN1(clk_gen),     // 1-bit input: Input clock
  // Control Ports: 1-bit (each) input: PLL control ports
  .PWRDWN(1'b0),     // 1-bit input: Power-down
  .RST(1'b0),           // 1-bit input: Reset
  // Feedback Clocks: 1-bit (each) input: Clock feedback ports
  .CLKFBIN(clk_fb)    // 1-bit input: Feedback clock
);

afifo input_afifo (
.m_aclk(clk_switch),                // input wire m_aclk
.s_aclk(clk_host),                // input wire s_aclk
.s_aresetn(~rst),          // input wire s_aresetn
.s_axis_tvalid(input_valid),  // input wire s_axis_tvalid
.s_axis_tready(input_ready),  // output wire s_axis_tready
.s_axis_tdata(input_packet),    // input wire [15 : 0] s_axis_tdata
.m_axis_tvalid(input_fifo_valid),  // output wire m_axis_tvalid
.m_axis_tready(input_fifo_ready),  // input wire m_axis_tready
.m_axis_tdata(input_fifo_packet)    // output wire [15 : 0] m_axis_tdata
    );

afifo output_afifo (
.m_aclk(clk_host),                // input wire m_aclk
.s_aclk(clk_switch),                // input wire s_aclk
.s_aresetn(~rst),          // input wire s_aresetn
.s_axis_tvalid(output_fifo_valid),  // input wire s_axis_tvalid
.s_axis_tready(output_fifo_ready),  // output wire s_axis_tready
.s_axis_tdata(output_fifo_packet),    // input wire [15 : 0] s_axis_tdata
.m_axis_tvalid(output_valid),  // output wire m_axis_tvalid
.m_axis_tready(output_ready),  // input wire m_axis_tready
.m_axis_tdata(output_packet)    // output wire [15 : 0] m_axis_tdata
    );  

genvar i,j;

generate for(j=0;j<Y_SIZE;j=j+1)
begin:y
    for(i=0;i<X_SIZE;i=i+1)
    begin:x
        processingElement processingElement(
        .clk(clk_pe),
        .rst(rst),
        .NI_PE_statuses(NI_PE_statuses[j][i]),
        .\NI_PE_pr[0][0] (\NI_PE_pr[0][0] [j][i]),
        .\NI_PE_pr[1][0] (\NI_PE_pr[1][0] [j][i]),
        .NI_PE_initialStatus(NI_PE_initialStatus[j][i]),
        .NI_PE_valid(NI_PE_valid[j][i]),
        .NI_PE_ready(NI_PE_ready[j][i]),
        .PE_NI_statuses(PE_NI_statuses[j][i]),
        .PE_NI_valid(PE_NI_valid[j][i]),
        .PE_NI_ready(PE_NI_ready[j][i])
        );
        
        networkInterface_inputBlock #(.NETWORK_SIZE(NETWORK_SIZE), .MAX_INDEX_INPUT(MAX_INDEX_INPUT), .MAX_INDEX_PP(MAX_INDEX_PP), .MAX_INDEX(MAX_INDEX)) networkInterface_inputBlock(
        .clk(clk_pe),
        .clk2(clk_switch),
        .rst(rst),
        .SWITCH_NI_packet(SWITCH_NI_packet[j][i]),
        .SWITCH_NI_valid(SWITCH_NI_valid[j][i]),
        .SWITCH_NI_ready(SWITCH_NI_ready[j][i]),
        .NI_PE_statuses(NI_PE_statuses[j][i]),
        .\NI_PE_pr[0][0] (\NI_PE_pr[0][0] [j][i]),
        .\NI_PE_pr[1][0] (\NI_PE_pr[1][0] [j][i]),
        .NI_PE_initialStatus(NI_PE_initialStatus[j][i]),
        .NI_PE_valid(NI_PE_valid[j][i]),
        .NI_PE_ready(NI_PE_ready[j][i])
        );
       
        networkInterface_outputBlock #(.ADDRESS(j*X_SIZE+i), .NETWORK_SIZE(NETWORK_SIZE)) networkInterface_outputBlock(
        .clk(clk_pe),
        .clk2(clk_switch),
        .rst(rst),
        .PE_NI_statuses(PE_NI_statuses[j][i]),
        .PE_NI_valid(PE_NI_valid[j][i]),
        .PE_NI_ready(PE_NI_ready[j][i]),
        .NI_SWITCH_packet(NI_SWITCH_packet[j][i]),
        .NI_SWITCH_valid(NI_SWITCH_valid[j][i]),
        .NI_SWITCH_ready(NI_SWITCH_ready[j][i])
        );
        
        if((j==0)&(i==0))
        begin
            switch #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(input_fifo_packet),
            .input_west_valid(input_fifo_valid),
            .input_west_ready(input_fifo_ready),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(),
            .input_south_valid(1'b0),
            .input_south_ready(),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
           
            .output_west_packet(output_fifo_packet),
            .output_west_valid(output_fifo_valid),
            .output_west_ready(output_fifo_ready),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(),
            .output_south_valid(),
            .output_south_ready(1'b1),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );
        end
        else if((j==Y_SIZE-1)&(i==0))
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(),
            .input_west_valid(1'b0),
            .input_west_ready(),
            .input_north_packet(),
            .input_north_valid(1'b0),
            .input_north_ready(),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(),
            .output_west_valid(),
            .output_west_ready(1'b1),
            .output_north_packet(),
            .output_north_valid(),
            .output_north_ready(1'b1),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );           
        end
        else if((j==(Y_SIZE-1))&(i==(X_SIZE-1)))
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(),
            .input_north_valid(1'b0),
            .input_north_ready(),
            .input_east_packet(),
            .input_east_valid(1'b0),
            .input_east_ready(),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(),
            .output_north_valid(),
            .output_north_ready(1'b1),
            .output_east_packet(),
            .output_east_valid(),
            .output_east_ready(1'b1),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );  
        end    
        else if((j==0)&(i==X_SIZE-1))
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(),
            .input_east_valid(1'b0),
            .input_east_ready(),
            .input_south_packet(),
            .input_south_valid(1'b0),
            .input_south_ready(),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(),
            .output_east_valid(),
            .output_east_ready(1'b1),
            .output_south_packet(),
            .output_south_valid(),
            .output_south_ready(1'b1),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );  
        end           
        else if(i==0)
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(),
            .input_west_valid(1'b0),
            .input_west_ready(),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(),
            .output_west_valid(),
            .output_west_ready(1'b1),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );  
        end
        else if(i==X_SIZE-1)
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(),
            .input_east_valid(1'b0),
            .input_east_ready(),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(),
            .output_east_valid(),
            .output_east_ready(1'b1),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            ); 
        end
        else if(j==0)
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(),
            .input_south_valid(1'b0),
            .input_south_ready(),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(),
            .output_south_valid(),
            .output_south_ready(1'b1),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            ); 
        end
        else if(j==Y_SIZE-1)
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(),
            .input_north_valid(1'b0),
            .input_north_ready(),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(),
            .output_north_valid(),
            .output_north_ready(1'b1),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );  
        end
        else
        begin
            switch  #(.Y(j), .X(i), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH)) switch (
            .clk(clk_switch),
            .rst(rst),
            .input_west_packet(east_west_packet[j][i-1]),
            .input_west_valid(east_west_valid[j][i-1]),
            .input_west_ready(east_west_ready[j][i-1]),
            .input_north_packet(south_north_packet[j][i]),
            .input_north_valid(south_north_valid[j][i]),
            .input_north_ready(south_north_ready[j][i]),
            .input_east_packet(west_east_packet[j][i]),
            .input_east_valid(west_east_valid[j][i]),
            .input_east_ready(west_east_ready[j][i]),
            .input_south_packet(north_south_packet[j-1][i]),
            .input_south_valid(north_south_valid[j-1][i]),
            .input_south_ready(north_south_ready[j-1][i]),
            .input_center_packet(NI_SWITCH_packet[j][i]),
            .input_center_valid(NI_SWITCH_valid[j][i]),
            .input_center_ready(NI_SWITCH_ready[j][i]),
            
            .output_west_packet(west_east_packet[j][i-1]),
            .output_west_valid(west_east_valid[j][i-1]),
            .output_west_ready(west_east_ready[j][i-1]),
            .output_north_packet(north_south_packet[j][i]),
            .output_north_valid(north_south_valid[j][i]),
            .output_north_ready(north_south_ready[j][i]),
            .output_east_packet(east_west_packet[j][i]),
            .output_east_valid(east_west_valid[j][i]),
            .output_east_ready(east_west_ready[j][i]),
            .output_south_packet(south_north_packet[j-1][i]),
            .output_south_valid(south_north_valid[j-1][i]),
            .output_south_ready(south_north_ready[j-1][i]),
            .output_center_packet(SWITCH_NI_packet[j][i]),
            .output_center_valid(SWITCH_NI_valid[j][i]),
            .output_center_ready(SWITCH_NI_ready[j][i])
            );  
        end
    end
end
endgenerate     
        
endmodule
