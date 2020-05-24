localparam X_SIZE=2**($clog2(NETWORK_SIZE)/2), Y_SIZE=X_SIZE;
localparam integer SEGMENT_SIZE_PP=$clog2(NETWORK_SIZE)+3;
localparam integer MAX_INDEX_PP=$ceil(100.0/(SEGMENT_SIZE_PP));
localparam integer SEGMENT_SIZE_INPUT=3;
localparam integer WIDTH_INPUT=$clog2(NETWORK_SIZE*2-1);
localparam integer MAX_INDEX_INPUT=$ceil(WIDTH_INPUT*1.0/SEGMENT_SIZE_INPUT);
localparam integer MAX_INDEX=MAX_INDEX_INPUT>MAX_INDEX_PP?MAX_INDEX_INPUT:MAX_INDEX_PP;

task simulateSI1I2Smodel;

input integer adjacencyMatrix_fd;   //File descriptor for an adjacency matrix with comma for column delimeter and the last row representing the initial infection statuses
input integer AX_SIZE;   //Size of the contact network
input integer AY_SIZE; 
input reg isConfigureRoutingTable;   //If set to 0, the configuration of routing table is skipped
input reg [6:0] \probabilityOfRecovery[0] ;   //Determines the number of bits set high in PRBS generator for probability of recovery 
input reg [6:0] \probabilityOfRecovery[1] ; 
input reg [6:0] \probabilityOfInfection[0] ;   //Determines the number of bits set high in PRBS generator for probability of infection 
input reg [6:0] \probabilityOfInfection[1] ;
input integer simulationTime;   //Determines how much discrete time to simulate 
input integer output_mcd;   //Multichannel descriptor for storing output results

begin 
    //reset
    rst<=1;
    repeat(10)      
        @(posedge clk);
    rst<=0;     
    //end reset
    fork  
        begin: output_block            
            output_valid<=1'b1;
            if(isConfigureRoutingTable)
                configureRoutingTable(adjacencyMatrix_fd, AX_SIZE, AY_SIZE);
            configureProbabilityPattern(\probabilityOfRecovery[0] );
            configureProbabilityPattern(\probabilityOfRecovery[1] );
            configureProbabilityPattern(\probabilityOfInfection[0] );
            configureProbabilityPattern(\probabilityOfInfection[1] );
            configureNode(adjacencyMatrix_fd, AX_SIZE, AY_SIZE);
            output_valid<=1'b0;
        end          
        begin: input_block
            input_ready<=1'b1;
            monitor(simulationTime, output_mcd, AX_SIZE, AY_SIZE);
            input_ready<=1'b0;
        end
    join
end
endtask

task configureRoutingTable(input integer adjacencyMatrix_fd, input integer AX_SIZE, input integer AY_SIZE);

reg adjacencyMatrix[1:0][NETWORK_SIZE-1:0][NETWORK_SIZE-1:0];
reg [4:0] routingTable[1:0][NETWORK_SIZE-1:0][NETWORK_SIZE-1:0];
integer i, j, k, x, y;
reg [$clog2(NETWORK_SIZE)-1:0] input_address, output_address;
reg [(4+$clog2(NETWORK_SIZE)):0] packet;

begin
    //Fill Adjacency Matrix from a file
    for(k=0;k<2;k=k+1)
        for(j=0;j<NETWORK_SIZE;j=j+1)
            for(i=0;i<NETWORK_SIZE;i=i+1)
                if(i==(NETWORK_SIZE-1))
                    $fscanf(adjacencyMatrix_fd,"%b\n", adjacencyMatrix[k][j][i]);
                else
                    $fscanf(adjacencyMatrix_fd,"%b,", adjacencyMatrix[k][j][i]);
    //End Fill Adjacency Matrix from a file
   
    //Initialize Routing Table 
    for(k=0;k<2;k=k+1)
        for(j=0;j<NETWORK_SIZE;j=j+1)
            for(i=0;i<NETWORK_SIZE;i=i+1)
                routingTable[k][j][i]=5'b00000;            
    //End Initialize Routing Table  
     
    //Provide Route to Home
    for(k=0;k<2;k=k+1)
        for(j=0;j<NETWORK_SIZE;j=j+1)
        begin 
            output_address=j;
            for(x=output_address[$clog2(X_SIZE)-1:0];x>0;x=x-1)
            begin
                routingTable[k][output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)]*X_SIZE+x][output_address][4]=1'b1;
            end
            for(y=output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)];y>0;y=y-1)
            begin
                routingTable[k][y*X_SIZE][output_address][1]=1'b1;
            end  
            routingTable[k][0][output_address][4]=1'b1;                         
        end     
    //End Provide Route to Home  

      
    //Fill Routing Table from Adjacency Matrix
    for(k=0;k<2;k=k+1)
    begin
        for(j=0;j<NETWORK_SIZE;j=j+1)
        begin
            for(i=0;i<NETWORK_SIZE;i=i+1)
            begin
                if(adjacencyMatrix[k][j][i]==1'b1)
                begin 
                    output_address=j;
                    input_address=i;
                    if(output_address[$clog2(X_SIZE)-1:0]>input_address[$clog2(X_SIZE)-1:0])
                    begin
                        for(x=output_address[$clog2(X_SIZE)-1:0]; x>input_address[$clog2(X_SIZE)-1:0]; x=x-1)
                        begin
                            routingTable[k][output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)]*X_SIZE+x][output_address][4]=1'b1;
                        end                    
                    end
                    else 
                    begin
                        for(x=output_address[$clog2(X_SIZE)-1:0]; x<input_address[$clog2(X_SIZE)-1:0]; x=x+1)
                        begin
                            routingTable[k][output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)]*X_SIZE+x][output_address][2]=1'b1;
                        end                    
                    end
                    if(output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)]>input_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)])
                    begin
                        for(y=output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)];y>input_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)];y=y-1)
                        begin
                            routingTable[k][y*X_SIZE+input_address[$clog2(X_SIZE)-1:0]][output_address][1]=1'b1;
                        end
                    end
                    else 
                    begin
                        for(y=output_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)];y<input_address[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)];y=y+1)
                        begin
                            routingTable[k][y*X_SIZE+input_address[$clog2(X_SIZE)-1:0]][output_address][3]=1'b1;
                        end
                    end
                    routingTable[k][input_address][output_address][0]=1'b1;
                end
            end
        end 
    end    
    //End Fill Routing Table from Adjacency Matrix
     
    for(j=0;j<NETWORK_SIZE;j=j+1)
    begin
        if((j[$clog2(NETWORK_SIZE)-1:$clog2(X_SIZE)]<AY_SIZE)&(j[$clog2(X_SIZE)-1:0]<AX_SIZE))
            for(i=0;i<NETWORK_SIZE;i=i+1)
            begin                                   
                packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b11;
                packet[2+$clog2(NETWORK_SIZE)]=(i==(NETWORK_SIZE-1))?1'b1:1'b0;
                packet[9:0]={routingTable[1][j][i],routingTable[0][j][i]};
                sendPacket(packet);  
            end
        else
            begin
                packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b11;
                packet[2+$clog2(NETWORK_SIZE)]=1'b1;
                packet[9:0]={10{1'b0}};
                sendPacket(packet);             
            end
    end
end
endtask

task configureProbabilityPattern(input reg [6:0] probability);

integer i;
reg [99:0] probabilityPattern;
reg [(4+$clog2(NETWORK_SIZE)):0] packet;

begin
    for(i=0;i<100;i=i+1)
    begin
        if(i<probability)
            probabilityPattern[i]=1'b1;
        else
            probabilityPattern[i]=1'b0;
    end
    
    repeat(10)
    begin
        probabilityPattern=shuffledVector(probabilityPattern);
    end
    
    for(i=0;i<MAX_INDEX_PP;i=i+1)
    begin
        packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b10;
        packet[SEGMENT_SIZE_PP-1:0]=probabilityPattern[i*SEGMENT_SIZE_PP+:SEGMENT_SIZE_PP];
        sendPacket(packet);
    end   
end
endtask

function [99:0] shuffledVector(input [99:0] vector);
integer i;
reg temp;
integer index;
begin
    shuffledVector=vector;
    for(i=0;i<99;i=i+1)
    begin
        index=i+{$random()}%(100-i);
        temp=shuffledVector[i];
        shuffledVector[i]=shuffledVector[index];
        shuffledVector[index]=temp;        
    end
end
endfunction

task configureNode(input integer adjacencyMatrix_fd, input integer AX_SIZE, input integer AY_SIZE);

reg adjacencyMatrix[1:0][NETWORK_SIZE-1:0][NETWORK_SIZE-1:0];
reg [WIDTH_INPUT-1:0] inputNum[NETWORK_SIZE-1:0];
reg [2:0] initialStatus [NETWORK_SIZE-1:0];
integer i,j,k;
reg [(4+$clog2(NETWORK_SIZE)):0] packet;

begin
    //Initialize Input Number
    for(i=0;i<NETWORK_SIZE;i=i+1)
        inputNum[i]=0;
    //End Initialize Input Number 
    
    //Fill Adjacency Matrix from a file
    $fseek(adjacencyMatrix_fd, 0, 0);
    for(k=0;k<2;k=k+1)
        for(j=0;j<NETWORK_SIZE;j=j+1)
            for(i=0;i<NETWORK_SIZE;i=i+1)
                if(i==(NETWORK_SIZE-1))
                    $fscanf(adjacencyMatrix_fd,"%b\n", adjacencyMatrix[k][j][i]);
                else
                    $fscanf(adjacencyMatrix_fd,"%b,", adjacencyMatrix[k][j][i]);
     $fclose(adjacencyMatrix_fd);
    //End Fill Adjacency Matrix from a file
    
       
    //Fill Input Number from Adjacency Matrix
    for(k=0;k<2;k=k+1)
        for(j=0;j<NETWORK_SIZE;j=j+1)
            for(i=0;i<NETWORK_SIZE;i=i+1)
                if(adjacencyMatrix[k][j][i]==1'b1)
                    inputNum[j]=inputNum[j]+1;                      
    //End Fill Input Number from Adjacency Matrix  
            
   //Fill Initial Infection Status 
    for(i=0;i<NETWORK_SIZE;i=i+1)
        if((i==4)|(i==51)|(i==89)|(i==157))
            initialStatus[i]=3'b010;
        else if((i==101)|(i==132)|(i==187)|(i==247))
            initialStatus[i]=3'b100;
        else
            initialStatus[i]=3'b001;
   //End Fill Initial Infection Status    
   
    for(j=0;j<AY_SIZE;j=j+1)
        for(i=0;i<AX_SIZE;i=i+1) 
        begin
            for(k=0;k<MAX_INDEX_INPUT;k=k+1)
            begin
                packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b00;
                packet[3+:$clog2(NETWORK_SIZE)]=j*X_SIZE+i;
                packet[SEGMENT_SIZE_INPUT-1:0]=inputNum[j*X_SIZE+i][k*SEGMENT_SIZE_INPUT+:SEGMENT_SIZE_INPUT];
                sendPacket(packet);                   
            end
            packet[(3+$clog2(NETWORK_SIZE))+:2]=2'b00;
            packet[3+:$clog2(NETWORK_SIZE)]=j*X_SIZE+i;
            packet[2:0]=initialStatus[j*X_SIZE+i];
            sendPacket(packet); 
        end      
end
endtask

task sendPacket(input [4+$clog2(NETWORK_SIZE):0] packet);
begin
    output_packet<=packet;
    forever
    begin
        @(posedge clk)
        if(output_ready)
        begin
            disable sendPacket; 
        end
    end
end
endtask

task monitor(input integer simulationTime, input integer output_mcd, input integer AX_SIZE, input integer AY_SIZE);

integer i,j,k, x,y,lyr, discreteTime,runTime,configurationTime;
reg [5:0] currCounter; 
reg [5:0] counter[Y_SIZE-1:0][X_SIZE-1:0][1:0];
reg status[Y_SIZE-1:0][X_SIZE-1:0][1:0][63:0];
reg valid[Y_SIZE-1:0][X_SIZE-1:0][1:0][63:0];
reg [$clog2(NETWORK_SIZE+1)-1:0] I1, I2, S; 
reg isNextDiscreteTime; 
reg isRun;

begin
    $fdisplay(output_mcd,"time, I1, I2, S");
    
    //initialization    
    for(j=0;j<AY_SIZE;j=j+1)
        for(i=0;i<AX_SIZE;i=i+1)
            for(k=0;k<2;k=k+1)
                counter[j][i][k]=0;
    currCounter=0;    
    isRun=0;
    discreteTime=0;  
    runTime=0;
    configurationTime=0; 
    //end initialization
                             
    forever 
    begin
        @(posedge clk)
        
        if(input_valid)
        begin
            lyr=input_packet[2];
            x=input_packet[3+:$clog2(X_SIZE)];
            y=input_packet[(3+$clog2(X_SIZE))+:$clog2(Y_SIZE)];
            valid[y][x][lyr][counter[y][x][lyr]]=1'b1;
            status[y][x][lyr][counter[y][x][lyr]]=input_packet[0];
            counter[y][x][lyr]=counter[y][x][lyr]+1;
            if(isRun==0)
                isRun=1;
        end
        
        if(isRun)
           runTime=runTime+1;
        else
           configurationTime=configurationTime+1;  
                    
         for(isNextDiscreteTime=1'b1,j=0;j<AY_SIZE;j=j+1)  
            for(i=0;i<AX_SIZE;i=i+1)
                for(k=0;k<2;k=k+1)
                    isNextDiscreteTime=isNextDiscreteTime&valid[j][i][k][currCounter];
               
         if(isNextDiscreteTime)
         begin  
            I1=0;
            I2=0;
            S=0;                           
            for(j=0;j<AY_SIZE;j=j+1)
                for(i=0;i<AX_SIZE;i=i+1)                           
                    case({status[j][i][1][currCounter],status[j][i][0][currCounter]})
                    2'b01: I1=I1+1;
                    2'b10: I2=I2+1;
                    default: S=S+1;
                    endcase
            
            for(j=0;j<AY_SIZE;j=j+1)
                for(i=0;i<AX_SIZE;i=i+1)
                    for(k=0;k<2;k=k+1)
                        valid[j][i][k][currCounter]=1'b0; 
            
            currCounter=currCounter+1;            
            $fdisplay(output_mcd, "%0d, %0d, %0d, %0d ",discreteTime, I1, I2, S);
            
            discreteTime=discreteTime+1;             
            if(discreteTime>simulationTime) 
            begin 
                $fwrite(output_mcd, "Configuration time: %0d, Run time: %0d", configurationTime, runTime);
                $fclose(output_mcd);
                disable monitor;   
            end              
         end                      
    end
end
endtask 

/*
task average(input integer numOfPoints,input integer fd1,input integer fd2,input integer fd3,input integer fd4,input integer fd5,input integer fd6,input integer fd7,input integer fd8,input integer fd9,input integer fd10,input integer mcd);
integer value[10:1];
integer i;
begin
    $fwrite(mcd,"time, infected, susceptable\n");
    for(i=0;i<numOfPoints;i=i+1)
    begin
        $fscanf(fd1, "%d ", value[1]);
        $fscanf(fd2, "%d ", value[2]);
        $fscanf(fd3, "%d ", value[3]);
        $fscanf(fd4, "%d ", value[4]);
        $fscanf(fd5, "%d ", value[5]);
        $fscanf(fd6, "%d ", value[6]);
        $fscanf(fd7, "%d ", value[7]);
        $fscanf(fd8, "%d ", value[8]);
        $fscanf(fd9, "%d ", value[9]);
        $fscanf(fd10, "%d ", value[10]);
        $fwrite(mcd, "%0d, %.3f, %.3f\n",i, (value[1]+value[2]+value[3]+value[4]+value[5]+value[6]+value[7]+value[8]+value[9]+value[10])/(10.000*AX_SIZE*AY_SIZE), (1.000-(value[1]+value[2]+value[3]+value[4]+value[5]+value[6]+value[7]+value[8]+value[9]+value[10])/(10.000*AX_SIZE*AY_SIZE)));
    end
    $fclose(fd1);
    $fclose(fd2);
    $fclose(fd3);
    $fclose(fd4);
    $fclose(fd5);
    $fclose(fd6);
    $fclose(fd7);
    $fclose(fd8);
    $fclose(fd9);
    $fclose(fd10);
    $fclose(mcd);
end
endtask
*/