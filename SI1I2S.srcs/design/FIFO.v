//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: FIFO
// Module Name: fifo
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module fifo #(parameter DEPTH=4, WIDTH=13)( 
input clk, 
input rst, 
input [WIDTH-1:0] din,
input wr_en, 
input rd_en, 
output [WIDTH-1:0] dout,
output ready,
output valid
    );
    
reg [WIDTH-1:0] memory [DEPTH-1:0]; 
reg [$clog2(DEPTH)-1:0] writePointer, readPointer;
reg [$clog2(DEPTH):0] counter;
 
always @(posedge clk)
begin
        if(wr_en&ready)
            memory[writePointer]<=din; 
end

always @(posedge clk)
begin
    if(rst)
    begin
        writePointer<=0;
        readPointer<=0;
    end
    else 
    begin
        if(wr_en&ready)                    
            writePointer<=writePointer+1;
        if(rd_en&valid)                    
            readPointer<=readPointer+1;
    end  
end

always @(posedge clk)
begin
    if(rst)
    begin
        counter<=0;
    end
    else 
    begin
        if((wr_en&ready)&~(rd_en&valid))                    
            counter<=counter+1;
        if((rd_en&valid)&~(wr_en&ready))                    
            counter<=counter-1;
    end  
end

assign ready=counter!=DEPTH;
assign valid=counter!=0;
assign dout=memory[readPointer];
endmodule