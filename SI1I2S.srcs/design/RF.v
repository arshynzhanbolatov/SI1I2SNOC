//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arshyn Zhanbolatov
// 
// Create Date: 06.2019 
// Design Name: RF
// Module Name: routingFunction
// Project Name: SI1I2S
//////////////////////////////////////////////////////////////////////////////////


module routingFunction #(parameter X=0, Y=0, NETWORK_SIZE=256, X_SIZE=16, Y_SIZE=16)(
    input [$clog2(NETWORK_SIZE)-1:0] destAddress,
    output reg rf_west_valid,
    output reg rf_north_valid,
    output reg rf_east_valid,
    output reg rf_south_valid,
    output reg rf_center_valid
    );
        
    //localparam X_SIZE=2**($clog2(NETWORK_SIZE)/2), Y_SIZE=X_SIZE;
    
    wire [2:0] x_comparator_output, y_comparator_output;
    
    comparator x_comparator(
    .in0(destAddress[0+:$clog2(X_SIZE)]),
    .in1(X[$clog2(X_SIZE)-1:0]),
    .\= (x_comparator_output[2]),
    .\> (x_comparator_output[1]),
    .\< (x_comparator_output[0])
    );
    defparam x_comparator.WIDTH=$clog2(X_SIZE);
    
    comparator y_comparator(
    .in0(destAddress[$clog2(X_SIZE)+:$clog2(Y_SIZE)]),
    .in1(Y[$clog2(Y_SIZE)-1:0]),
    .\= (y_comparator_output[2]),
    .\> (y_comparator_output[1]),
    .\< (y_comparator_output[0])
    );
    defparam y_comparator.WIDTH=$clog2(Y_SIZE);
    
    always @(*)
    begin
        casex({x_comparator_output, y_comparator_output})
        6'b100100: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}= 5'b00001;
        6'b010xxx: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}= 5'b00100;
        6'b001xxx: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}= 5'b10000;
        6'b100010: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}= 5'b01000;
        6'b100001: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}= 5'b00010;
        default: {rf_west_valid, rf_north_valid, rf_east_valid,rf_south_valid, rf_center_valid}=5'b00001;
        endcase
    end
    
    
endmodule