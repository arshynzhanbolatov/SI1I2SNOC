//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 05.2019 
// Design Name: WMSM
// Module Name: workingModeStateMachine
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////

module workingModeStateMachine #(parameter integer MAX_INDEX_PP=10, integer MAX_INDEX_INPUT=3, integer MAX_INDEX=10) (
input clk,
input rst,
input valid,
input [1:0] type,
input [$clog2(MAX_INDEX)-1:0] index,
output reg [2:0] mode,
output reg [1:0] pr_confEn,
output reg [1:0] pi_confEn,
output reg input_confEn,
output reg status_confEn,
output reg isNext,
output reg isLast,
output buffer_valid
    );
    
localparam CONF_PR_0=3'b000, CONF_PR_1=3'b001, CONF_PI_0=3'b010, CONF_PI_1=3'b011, CONF_INPUT=3'b100, CONF_STATUS=3'b101, RUN=3'b110;  

reg [2:0] nextMode;   


always @(posedge clk)
begin
    mode<=nextMode;
end

always @(*)
begin
    if(rst)
    begin
        pr_confEn=2'b00;
        pi_confEn=2'b00;
        input_confEn=1'b0; 
        status_confEn=1'b0; 
        isNext=1'b0;      
        nextMode=CONF_PR_0;
    end
    else
    case(mode)  
        CONF_PR_0: 
        begin
            if((type==2'b10)&valid&!isLast)
            begin
                pr_confEn=2'b01;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PR_0;
            end
            else if((type==2'b10)&valid&isLast)
            begin
                pr_confEn=2'b01;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PR_1;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_PR_0;                 
            end               
        end 
        CONF_PR_1: 
        begin
            if((type==2'b10)&valid&!isLast)
            begin
                pr_confEn=2'b10;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PR_1;
            end
            else if((type==2'b10)&valid&isLast)
            begin
                pr_confEn=2'b10;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PI_0;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_PR_1;                 
            end               
        end 
        CONF_PI_0: 
        begin
            if((type==2'b10)&valid&!isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b01;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PI_0;
            end
            else if((type==2'b10)&valid&isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b01;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PI_1;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_PI_0;                 
            end               
        end
        CONF_PI_1: 
        begin
            if((type==2'b10)&valid&!isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b10;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_PI_1;
            end
            else if((type==2'b10)&valid&isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b10;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_INPUT;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_PI_1;                 
            end               
        end
        CONF_INPUT: 
        begin
            if((type==2'b00)&valid&!isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b1; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_INPUT;
            end
            else if((type==2'b00)&valid&isLast)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b1; 
                status_confEn=1'b0;
                isNext=1'b1;        
                nextMode=CONF_STATUS;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_INPUT;                 
            end               
        end 
        CONF_STATUS: 
        begin
            if((type==2'b00)&valid)
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b1;
                isNext=1'b0;        
                nextMode=RUN;
            end
            else 
            begin
                pr_confEn=2'b00;
                pi_confEn=2'b00;
                input_confEn=1'b0; 
                status_confEn=1'b0;
                isNext=1'b0;        
                nextMode=CONF_STATUS;                 
            end               
        end 
        RUN: 
        begin
            pr_confEn=2'b00;
            pi_confEn=2'b00;
            input_confEn=1'b0; 
            status_confEn=1'b0;
            isNext=1'b0;        
            nextMode=RUN;                             
        end                   
    endcase
end

assign buffer_valid=valid&(type==2'b01);

always @(*)
begin
    case(mode)
    CONF_INPUT: isLast=index==(MAX_INDEX_INPUT-1);
    default: isLast=index==(MAX_INDEX_PP-1);
    endcase
end    
  
endmodule

