//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: TB
// Module Name: testbench
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module testbench;

localparam NETWORK_SIZE=256;
localparam FIFO_DEPTH=4;

reg clk_gen=0, rst=0;
wire [4+$clog2(NETWORK_SIZE):0] input_packet;
wire input_valid, output_ready;
reg [4+$clog2(NETWORK_SIZE):0] output_packet;
reg output_valid=0, input_ready=0;
wire locked, clk;

`include "TB_HEADER.vh"

always
begin
    #5 clk_gen=!clk_gen;
end

initial
begin
    #100;
    @(locked);
    @(posedge clk)
    //descriptions for the tasks and function used in the testbench are provided in "TB_HEADER.file"
    simulateSI1I2Smodel($fopen("matrices/BA_16-16.txt","r"), 16, 16, 1, 20, 30, 40, 50, 100, $fopen("results/BA_16-16_output_20-30_40-50_100_2.txt"));
    $finish;
end

SI1I2SNetworkOnChip #(.NETWORK_SIZE(NETWORK_SIZE), .X_SIZE(X_SIZE), .Y_SIZE(Y_SIZE), .FIFO_DEPTH(FIFO_DEPTH), .MAX_INDEX_INPUT(MAX_INDEX_INPUT), .MAX_INDEX_PP(MAX_INDEX_PP), .MAX_INDEX(MAX_INDEX)
) SI1I2SNetworkOnChip(
clk_gen,
clk,
rst,
output_packet,
output_valid,
output_ready,
input_packet,
input_valid,
input_ready,
locked
);

endmodule