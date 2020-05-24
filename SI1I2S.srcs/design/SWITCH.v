//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: SWITCH
// Module Name: switch
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module switch #(parameter X=0, Y=0, NETWORK_SIZE=256, X_SIZE=16, Y_SIZE=16, FIFO_DEPTH=4) (
input clk,
input rst,
input [4+$clog2(NETWORK_SIZE):0] input_west_packet,
input input_west_valid,
output input_west_ready,
input [4+$clog2(NETWORK_SIZE):0] input_north_packet,
input input_north_valid,
output input_north_ready,
input [4+$clog2(NETWORK_SIZE):0] input_east_packet,
input input_east_valid,
output input_east_ready,
input [4+$clog2(NETWORK_SIZE):0] input_south_packet,
input input_south_valid,
output input_south_ready,
input [4+$clog2(NETWORK_SIZE):0] input_center_packet,
input input_center_valid,
output input_center_ready,

output [4+$clog2(NETWORK_SIZE):0] output_west_packet,
output output_west_valid,
input output_west_ready,
output [4+$clog2(NETWORK_SIZE):0] output_north_packet,
output output_north_valid,
input output_north_ready,
output [4+$clog2(NETWORK_SIZE):0] output_east_packet,
output output_east_valid,
input output_east_ready,
output [4+$clog2(NETWORK_SIZE):0] output_south_packet,
output output_south_valid,
input output_south_ready,
output [4+$clog2(NETWORK_SIZE):0] output_center_packet,
output output_center_valid,
input output_center_ready
    );

wire [4+$clog2(NETWORK_SIZE):0] input_fifo_west_packet, input_fifo_north_packet, input_fifo_east_packet, input_fifo_south_packet, input_fifo_center_packet;                                                                                                                                                                                                                  
wire input_fifo_west_valid, input_fifo_north_valid, input_fifo_east_valid, input_fifo_south_valid, input_fifo_center_valid;
wire input_fifo_west_ready, input_fifo_north_ready, input_fifo_east_ready, input_fifo_south_ready, input_fifo_center_ready;

wire input_fifo_west_grant, input_fifo_north_grant, input_fifo_east_grant, input_fifo_south_grant, input_fifo_center_grant; 
wire [4+$clog2(NETWORK_SIZE):0] input_fifo_packet; 
wire input_fifo_valid;

reg pipeline_1_west_grant, pipeline_1_north_grant, pipeline_1_east_grant, pipeline_1_south_grant, pipeline_1_center_grant, pipeline_2_west_grant, pipeline_2_north_grant, pipeline_2_east_grant, pipeline_2_south_grant, pipeline_2_center_grant; 
reg [4+$clog2(NETWORK_SIZE):0] pipeline_1_packet, pipeline_2_packet;
reg pipeline_1_valid, pipeline_2_valid;
wire re_west_valid, re_north_valid, re_east_valid, re_south_valid, re_center_valid;
reg pipeline_2_west_valid, pipeline_2_north_valid, pipeline_2_east_valid, pipeline_2_south_valid, pipeline_2_center_valid;

wire output_fifo_valid;

wire [4+$clog2(NETWORK_SIZE):0] output_fifo_west_packet, output_fifo_north_packet, output_fifo_east_packet, output_fifo_south_packet, output_fifo_center_packet;                                                                                                                                                                                                                  
wire output_fifo_west_valid, output_fifo_north_valid, output_fifo_east_valid, output_fifo_south_valid, output_fifo_center_valid;
wire output_fifo_west_ready, output_fifo_north_ready, output_fifo_east_ready, output_fifo_south_ready, output_fifo_center_ready;
     
fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) input_west_fifo(
.clk(clk),    
.rst(rst),    
.din(input_west_packet),     
.wr_en(input_west_valid),  
.rd_en(input_fifo_west_ready), 
.dout(input_fifo_west_packet),    
.ready(input_west_ready),    
.valid(input_fifo_west_valid)  
); 

fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) input_north_fifo(
.clk(clk),      
.rst(rst),   
.din(input_north_packet),    
.wr_en(input_north_valid),  
.rd_en(input_fifo_north_ready), 
.dout(input_fifo_north_packet),    
.ready(input_north_ready),    
.valid(input_fifo_north_valid)  
); 

fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) input_east_fifo(
.clk(clk),    
.rst(rst),   
.din(input_east_packet),      
.wr_en(input_east_valid),  
.rd_en(input_fifo_east_ready),  
.dout(input_fifo_east_packet),   
.ready(input_east_ready),    
.valid(input_fifo_east_valid)  
); 
 
fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) input_south_fifo(
.clk(clk),      
.rst(rst),   
.din(input_south_packet),    
.wr_en(input_south_valid),  
.rd_en(input_fifo_south_ready), 
.dout(input_fifo_south_packet),    
.ready(input_south_ready),    
.valid(input_fifo_south_valid)  
);                        
           
fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) input_center_fifo(      
.clk(clk),  
.rst(rst),     
.din(input_center_packet),      
.wr_en(input_center_valid), 
.rd_en(input_fifo_center_ready),  
.dout(input_fifo_center_packet),    
.ready(input_center_ready),    
.valid(input_fifo_center_valid)  
); 

ringCounter #(.WIDTH(5)) arbiter (
clk,
rst,
{input_fifo_center_grant, input_fifo_south_grant, input_fifo_east_grant, input_fifo_north_grant, input_fifo_west_grant}
  );

mux_5 #(.WIDTH(5+$clog2(NETWORK_SIZE))) mux_packet(
.select({input_fifo_center_grant, input_fifo_south_grant, input_fifo_east_grant, input_fifo_north_grant,input_fifo_west_grant}),
.in0(input_fifo_west_packet),
.in1(input_fifo_north_packet),
.in2(input_fifo_east_packet),
.in3(input_fifo_south_packet),
.in4(input_fifo_center_packet),
.out(input_fifo_packet)
);

mux_5 #(1) mux_valid(
.select({input_fifo_center_grant, input_fifo_south_grant, input_fifo_east_grant, input_fifo_north_grant,input_fifo_west_grant}),
.in0(input_fifo_west_valid),
.in1(input_fifo_north_valid),
.in2(input_fifo_east_valid),
.in3(input_fifo_south_valid),
.in4(input_fifo_center_valid),
.out(input_fifo_valid)
);
        
always @(posedge clk)
begin
    if(rst)
    begin
        pipeline_1_packet<=0;
        pipeline_1_valid<=0;
        pipeline_1_west_grant<=0;
        pipeline_1_north_grant<=0;
        pipeline_1_east_grant<=0;
        pipeline_1_south_grant<=0;
        pipeline_1_center_grant<=0;
    end
    else
    begin
        pipeline_1_packet<=input_fifo_packet;
        pipeline_1_valid<=input_fifo_valid;
        pipeline_1_west_grant<=input_fifo_west_grant;
        pipeline_1_north_grant<=input_fifo_north_grant;
        pipeline_1_east_grant<=input_fifo_east_grant;
        pipeline_1_south_grant<=input_fifo_south_grant;
        pipeline_1_center_grant<=input_fifo_center_grant;
    end
end

routingEngine #(.X(X), .Y(Y), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE)) routingEngine(
.clk(clk),
.rst(rst),
.packet(pipeline_1_packet),
.valid(pipeline_1_valid),
.west_valid(re_west_valid),
.north_valid(re_north_valid),
.east_valid(re_east_valid),
.south_valid(re_south_valid),
.center_valid(re_center_valid)
);
       
always @(posedge clk)
begin
    if(rst)
    begin
        pipeline_2_packet<=0;
        pipeline_2_valid<=0;
        pipeline_2_west_grant<=0;
        pipeline_2_north_grant<=0;
        pipeline_2_east_grant<=0;
        pipeline_2_south_grant<=0;
        pipeline_2_center_grant<=0;
        pipeline_2_west_valid<=0;
        pipeline_2_north_valid<=0;
        pipeline_2_east_valid<=0;
        pipeline_2_south_valid<=0;
        pipeline_2_center_valid<=0;
    end
    else
    begin
        pipeline_2_packet<=pipeline_1_packet;
        pipeline_2_valid<=pipeline_1_valid;
        pipeline_2_west_grant<=pipeline_1_west_grant;
        pipeline_2_north_grant<=pipeline_1_north_grant;
        pipeline_2_east_grant<=pipeline_1_east_grant;
        pipeline_2_south_grant<=pipeline_1_south_grant;
        pipeline_2_center_grant<=pipeline_1_center_grant;
        pipeline_2_west_valid<=re_west_valid;
        pipeline_2_north_valid<=re_north_valid;
        pipeline_2_east_valid<=re_east_valid;
        pipeline_2_south_valid<=re_south_valid;
        pipeline_2_center_valid<=re_center_valid;
    end
end        

assign output_fifo_valid=~((pipeline_2_west_valid&~output_fifo_west_ready)|(pipeline_2_north_valid&~output_fifo_north_ready)|(pipeline_2_east_valid&~output_fifo_east_ready)|(pipeline_2_south_valid&~output_fifo_south_ready)|(pipeline_2_center_valid&~output_fifo_center_ready));
assign output_fifo_west_valid=pipeline_2_valid&pipeline_2_west_valid&output_fifo_valid;
assign output_fifo_north_valid=pipeline_2_valid&pipeline_2_north_valid&output_fifo_valid;
assign output_fifo_east_valid=pipeline_2_valid&pipeline_2_east_valid&output_fifo_valid;
assign output_fifo_south_valid=pipeline_2_valid&pipeline_2_south_valid&output_fifo_valid;
assign output_fifo_center_valid=pipeline_2_valid&pipeline_2_center_valid&output_fifo_valid;
assign {output_fifo_west_packet,output_fifo_north_packet,output_fifo_east_packet,output_fifo_south_packet,output_fifo_center_packet}={5{pipeline_2_packet}};

assign input_fifo_west_ready=pipeline_2_valid&output_fifo_valid&pipeline_2_west_grant;
assign input_fifo_north_ready=pipeline_2_valid&output_fifo_valid&pipeline_2_north_grant;
assign input_fifo_east_ready=pipeline_2_valid&output_fifo_valid&pipeline_2_east_grant;
assign input_fifo_south_ready=pipeline_2_valid&output_fifo_valid&pipeline_2_south_grant;
assign input_fifo_center_ready=pipeline_2_valid&output_fifo_valid&pipeline_2_center_grant;      


fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) output_west_fifo(
.clk(clk),    
.rst(rst),    
.din(output_fifo_west_packet),     
.wr_en(output_fifo_west_valid),  
.rd_en(output_west_ready), 
.dout(output_west_packet),    
.ready(output_fifo_west_ready),    
.valid(output_west_valid)  
); 

fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) output_north_fifo(
.clk(clk),      
.rst(rst),   
.din(output_fifo_north_packet),    
.wr_en(output_fifo_north_valid),  
.rd_en(output_north_ready), 
.dout(output_north_packet),    
.ready(output_fifo_north_ready),    
.valid(output_north_valid)  
); 

fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) output_east_fifo(
.clk(clk),    
.rst(rst),   
.din(output_fifo_east_packet),      
.wr_en(output_fifo_east_valid),  
.rd_en(output_east_ready),  
.dout(output_east_packet),   
.ready(output_fifo_east_ready),    
.valid(output_east_valid)  
); 
 
fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) output_south_fifo(
.clk(clk),      
.rst(rst),   
.din(output_fifo_south_packet),    
.wr_en(output_fifo_south_valid),  
.rd_en(output_south_ready), 
.dout(output_south_packet),    
.ready(output_fifo_south_ready),    
.valid(output_south_valid)  
);                        
           
fifo #(.WIDTH(5+$clog2(NETWORK_SIZE)), .DEPTH(FIFO_DEPTH)) output_center_fifo(      
.clk(clk),  
.rst(rst),     
.din(output_fifo_center_packet),      
.wr_en(output_fifo_center_valid), 
.rd_en(output_center_ready),  
.dout(output_center_packet),    
.ready(output_fifo_center_ready),    
.valid(output_center_valid)  
);  

endmodule
