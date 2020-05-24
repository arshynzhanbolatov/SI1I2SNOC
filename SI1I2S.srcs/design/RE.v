//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: RE
// Module Name: routingEngine
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module routingEngine #(parameter X=0, Y=0, NETWORK_SIZE=256, X_SIZE=16, Y_SIZE=16)(
    input rst,
    input clk,
    input [4+$clog2(NETWORK_SIZE):0] packet,
    input valid,
    output  reg west_valid,
    output  reg north_valid,
    output  reg east_valid,
    output  reg south_valid,
    output  reg center_valid
    );  

wire rf_west_valid, rf_north_valid, rf_east_valid, rf_south_valid, rf_center_valid;
wire rt_west_valid, rt_north_valid, rt_east_valid, rt_south_valid, rt_center_valid;

reg [$clog2(NETWORK_SIZE)-1:0] writeAddress;
reg [$clog2(NETWORK_SIZE)-1:0] router;

routingFunction #(.X(X), .Y(Y), .NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE)) routingFunction(
.destAddress(packet[3+:$clog2(NETWORK_SIZE)]),
.rf_west_valid(rf_west_valid),
.rf_north_valid(rf_north_valid),
.rf_east_valid(rf_east_valid),
.rf_south_valid(rf_south_valid),
.rf_center_valid(rf_center_valid)
);

routingTable #(.NETWORK_SIZE(NETWORK_SIZE)) routingTable(
.clk(clk),  
.writeAddress(writeAddress),
.in(packet[9:0]),  
.writeEnable(valid&(packet[(3+$clog2(NETWORK_SIZE))+:2]==2'b11)&(router==Y*X_SIZE+X)), 
.readAddress(packet[2+:($clog2(NETWORK_SIZE)+1)]), 
.out({rt_west_valid, rt_north_valid, rt_east_valid, rt_south_valid, rt_center_valid})
);

always @(posedge clk)
begin
    if(rst)
    begin
        writeAddress<=0;
        router<=0;
    end
    else
    begin
        if(valid&(packet[(3+$clog2(NETWORK_SIZE))+:2]==2'b11))
        begin  
               if(packet[2+$clog2(NETWORK_SIZE)]) 
               begin
                    router<=router+1;
                    writeAddress<=0; 
               end
               else
                    writeAddress<=writeAddress+1; 
        end
    end
end

always @(*)
begin
    case(packet[(3+$clog2(NETWORK_SIZE))+:2])
    2'b00: {west_valid,north_valid,east_valid,south_valid,center_valid}={rf_west_valid, rf_north_valid, rf_east_valid, rf_south_valid, rf_center_valid};
    2'b01: {west_valid,north_valid,east_valid,south_valid,center_valid}= {rt_west_valid, rt_north_valid, rt_east_valid, rt_south_valid, rt_center_valid};
    2'b10: {west_valid,north_valid,east_valid,south_valid,center_valid}={1'b0, 1'b1, (Y==0)?1'b1:1'b0, 1'b0, 1'b1};
    2'b11: {west_valid,north_valid,east_valid,south_valid,center_valid}={1'b0, 1'b1, (Y==0)?1'b1:1'b0, 1'b0, 1'b0};
    endcase     
end

endmodule
