//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: PTSM
// Module Name: packetTransferStateMachine
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module packetTransferStateMachine(
input clk,
input rst,
input in_valid,
input [1:0] in_statuses,
output reg in_ready,
output reg out_valid,
output reg out_status,
output reg out_layer,
input out_ready,
output reg isNextSeqNum
    );

localparam IDLE=2'b00, LAYER_0=2'b01, LAYER_1=2'b10;
reg [1:0] state, nextState;

always @(posedge clk)    
begin
    state<=nextState;
end
    
always @(*) 
begin
    if(rst)
    begin
        nextState=IDLE;
        in_ready=1'b0;
        out_valid=1'b0;
        out_status=1'b0;
        out_layer=1'b0;
        isNextSeqNum=1'b0;        
    end
    else 
    case(state)
        IDLE:
        begin
            if(in_valid)
            begin
                nextState=LAYER_0;
                in_ready=1'b0;
                out_valid=1'b0;
                out_status=1'b0;
                out_layer=1'b0; 
                isNextSeqNum=1'b0;
            end
            else
            begin
                nextState=IDLE;
                in_ready=1'b0;
                out_valid=1'b0;
                out_status=1'b0;
                out_layer=1'b0;  
                isNextSeqNum=1'b0;           
            end
        end
        LAYER_0:
        begin
            if(out_ready)
            begin
                nextState=LAYER_1;
                in_ready=1'b0;
                out_valid=1'b1;
                out_status=in_statuses[0];
                out_layer=1'b0;
                isNextSeqNum=1'b0; 
            end
            else
            begin
                nextState=LAYER_0;
                in_ready=1'b0;
                out_valid=1'b1;
                out_status=in_statuses[0];
                out_layer=1'b0; 
                isNextSeqNum=1'b0;            
            end
        end
        LAYER_1:
        begin
            if(out_ready)
            begin
                nextState=IDLE;
                in_ready=1'b1;
                out_valid=1'b1;
                out_status=in_statuses[1];
                out_layer=1'b1; 
                isNextSeqNum=1'b1;
            end
            else
            begin
                nextState=LAYER_1;
                in_ready=1'b0;
                out_valid=1'b1;
                out_status=in_statuses[1];
                out_layer=1'b1;
                isNextSeqNum=1'b0;             
            end
        end    
    endcase
end   
endmodule
