//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 02.2019 
// Design Name: ISSM
// Module Name: infectionStatusStateMachine
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module infectionStatusStateMachine(
input clk,
input rst,
input [1:0] input_prioritizedStatuses,
input \input_pr[0][0] ,
input \input_pr[1][0] ,
input [2:0] input_initialStatus,
input input_valid,
output reg [1:0] output_statuses,
input output_ready
    );
    
localparam X=2'b11, S=2'b00, I0=2'b01, I1=2'b10;   

reg [1:0] state, nextState;

always @(posedge clk)
begin
    state<=nextState;
end

always @(*)
begin
    if(rst)
    begin
        nextState=X;
        output_statuses=2'b00;
    end
    else    
        case(state)
        X:
        begin
           if(input_valid&output_ready&input_initialStatus==3'b001)
           begin
                nextState=S; 
                output_statuses=2'b00;
           end
           else if(input_valid&output_ready&input_initialStatus==3'b010)
           begin
                nextState=I0;
                output_statuses=2'b01;
           end
           else if(input_valid&output_ready&input_initialStatus==3'b100)
           begin
                nextState=I1;
                output_statuses=2'b10;
           end
           else
           begin
                nextState=X;
                output_statuses=2'b00;
           end           
        end   
        S:
        begin
            if(input_valid&output_ready&input_prioritizedStatuses==2'b01)
            begin
                nextState=I0;
                output_statuses=2'b01;
            end
            else if(input_valid&output_ready&input_prioritizedStatuses==2'b10)
            begin
                nextState=I1;
                output_statuses=2'b10;
            end
            else
            begin
                nextState=S;
                output_statuses=2'b00;
            end
        end
        I0:
        begin
            if(input_valid&output_ready&\input_pr[0][0] )
            begin
                nextState=S;
                output_statuses=2'b00;
            end
            else
            begin
                nextState=I0;
                output_statuses=2'b01;
            end
        end
        I1:
        begin
            if(input_valid&output_ready&\input_pr[1][0] )
            begin
                nextState=S;
                output_statuses=2'b00;
            end
            else
            begin
                nextState=I1;
                output_statuses=2'b10;
            end
        end
        endcase
end
    
endmodule
