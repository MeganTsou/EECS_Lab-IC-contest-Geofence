module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output valid;
output is_inside;

// Declaration
reg valid;
reg is_inside;
reg [9:0] x[5:0];
reg [9:0] y[5:0];
reg [9:0] sub;
reg [9:0] tarX;
reg [9:0] tarY;
reg [3:0] currState, nextState;
reg [3:0] inputCount;
reg [3:0] sortInnerCount;
reg [3:0] sortOuterCount;
reg [3:0] detCount;
reg signed [10:0] Ax, Ay, Bx, By;
reg signed [20:0] AxBy, BxAy;
reg [1:0] detSign[5:0];

parameter IDLE = 3'd0, INPUT = 3'd1, CALCULATION = 3'd2, DETERMINATION = 3'd3, OUTPUT = 3'd4, DELAY = 3'd5;

/////////// FSM //////////

// CS
always@(posedge clk or negedge reset)
begin
    if (~reset) currState <= nextState;
    else currState <= IDLE;
end

// NL
always@(*)
begin
    case (currState)
    IDLE :         nextState = INPUT;
    INPUT:         nextState = (inputCount == 4'd7)? CALCULATION : INPUT;
    CALCULATION:   nextState = (sortOuterCount == 4'd6)? DETERMINATION : CALCULATION;
    DETERMINATION: nextState = (detCount == 4'd7)? OUTPUT : DETERMINATION;
    OUTPUT:        nextState = DELAY;
    DELAY:         nextState = INPUT;
    default:       nextState = IDLE;
    endcase
end



always@(posedge clk)
begin
    if ((currState == INPUT && inputCount >= 4'd1 && inputCount <= 4'd6) || (currState == INPUT && inputCount == 4'd0))
    begin
        inputCount <= inputCount + 4'd1;
    end
    else
    begin
        inputCount <= 4'd0;
    end
end

//INPUT: target
always@(posedge clk)
begin
    if (currState == INPUT && inputCount == 4'd0)
    begin
        tarX <= X;
        tarY <= Y;
    end

end

// Calculate Ax, By in different states
always@(*)
begin
    
    if (currState == CALCULATION && sortInnerCount <= 4'd3)
    begin
        Ax = x[sortInnerCount + 4'd1] - x[0];
        Ay = y[sortInnerCount + 4'd1] - y[0];
        Bx = x[sortInnerCount + 4'd2] - x[0];
        By = y[sortInnerCount + 4'd2] - y[0];
        
    end
    else if (currState == DETERMINATION)
    begin
        if (detCount <= 4'd5)
        begin
            sub = detCount;
        end
        else if (detCount == 4'd6)
        begin
            sub = 4'd0;
        end
        else
        begin
        end
        Ax = x[detCount-4'd1] - tarX;
        Ay = y[detCount-4'd1] - tarY;
        Bx = x[sub] - x[detCount-4'd1];
        By = y[sub] - y[detCount-4'd1];
        
    end
    else
    begin
        sub = 4'd0;
        Ax = 11'd0;
        Bx = 11'd0;
        Ay = 11'd0;
        By = 11'd0;
    end

end

always@(*)
begin
    if (currState == CALCULATION || currState == DETERMINATION)
    begin
        AxBy = Ax * By;
        BxAy = Bx * Ay;
    end
    else
    begin
        AxBy = 21'd0;
        BxAy = 21'd0;
    end
end

// CALCULATION: Bubble Sort + Handling x[] and y[]
always@(posedge clk)
begin
    if (currState == INPUT && inputCount >= 4'd1 && inputCount <= 4'd6)
    begin
        x[inputCount-4'd1] <= X;
        y[inputCount-4'd1] <= Y;
    end

    if (currState == CALCULATION )
    begin
        if ( AxBy < BxAy && sortInnerCount <= 4'd3)
        begin
            
            x[sortInnerCount + 4'd2] <= x[sortInnerCount + 4'd1];
            x[sortInnerCount + 4'd1] <= x[sortInnerCount + 4'd2];
            y[sortInnerCount + 4'd2] <= y[sortInnerCount + 4'd1];
            y[sortInnerCount + 4'd1] <= y[sortInnerCount + 4'd2];  
        end
    end
end

always@(posedge clk)
begin
    if (currState == CALCULATION )
    begin
        sortInnerCount <= sortInnerCount + 4'd1;
        if ( sortInnerCount == 4'd5 ) 
        begin
            sortOuterCount <= sortOuterCount + 4'd1;
            sortInnerCount <= 4'd0;
        end
    end
    else
    begin
        sortInnerCount <= 4'd0;
        sortOuterCount <= 4'd0;
    end
end

// DETERMINATION
always@(posedge clk)
begin
    if (currState == DETERMINATION)
    begin
        if (AxBy > BxAy)  detSign[detCount-4'd1] <= 2'd2;
        else if (AxBy < BxAy)  detSign[detCount-4'd1] <= 2'd1;
        else if (AxBy == BxAy) detSign[detCount-4'd1] <= 2'd0;
    end
end
always@(posedge clk)
begin
    if (currState == DETERMINATION)
    begin
        detCount <= detCount + 4'd1;
    end
    else
    begin
        detCount <= 4'd0;
    end
end

// OUTPUT
always@(posedge clk or negedge reset)
begin
    if (~reset)
    begin
        if (currState == OUTPUT)
        begin
            valid <= 1'd1;
            if (detSign[0] == 2'd2 && detSign[1] == 2'd2 && detSign[2] == 2'd2 && detSign[3] == 2'd2 && detSign[4] == 2'd2 && detSign[5] == 2'd2) is_inside <= 1'd1;
            else if (detSign[0] == 2'd1 && detSign[1] == 2'd1 && detSign[2] == 2'd1 && detSign[3] == 2'd1 && detSign[4] == 2'd1 && detSign[5] == 2'd1) is_inside <= 1'd1;
            else is_inside <= 1'd0;
        end
        else
        begin
            valid <= 1'd0;
            is_inside <= 1'd0;
        end
    end
    else
    begin
        valid <= 1'd0;
        is_inside <= 1'd0;
    end
end

endmodule

