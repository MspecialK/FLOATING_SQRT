`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: POLITECNICO DI MILANO
// Engineer: MYKHAYLO KOTSABA 
// 
// Create Date: 02/22/2020 01:35:11 PM
// Module Name: floating_point_sqrt
// Project Name: Floating Point SQRT
// Revision: 0.0
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module floating_point_sqrt(input clk, input rst, input sqrt_start, input [15:0] num_i, output [15:0] num_o, output error, output valid_o);

localparam IDLE=0, COMPUTATION=1, FINE=2;
reg state,state_next;
reg [7:0] mantissa, exponent;

reg [7:0] B,Bnext;
reg [7:0] X,Xnext;
reg [7:0] Y,Ynext;
reg [7:0] counter,counter_next;


always@(posedge clk)///////////////////////////////////////////////////////////////////////////////////////SERIAL BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    begin
        B<=Bnext;
        X<=Xnext;
        Y<=Ynext;
        state<=state_next;
        counter<=counter_next;
    end



always@(*) /////////////////////////////////////////////////////////////////////////////////////////// SEQUENTIAL BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    begin
    
    Bnext=B;
    Xnext=X;
    Ynext=Y;
    if(rst)
        begin 
            counter_next=0;
            state_next=IDLE;
        end
    else
    begin
        case (state)
        IDLE: //////////////////////////////////////////////////////////////////////////////////////--IDLE STATE
        begin   
          if (sqrt_start) 
          begin 
              if ( num_i[15]==1'b0)  begin state_next=FINE; end
              else  begin
                    state_next=COMPUTATION; 
                    if (num_i[7]) begin exponent=num_i[15:7]+1; mantissa=8'b1000000; end
                    else          begin exponent=num_i[15:7]+2; mantissa=8'b1000000; end
              end  
          end 
        end
          
        COMPUTATION: ////////////////////////////////////////////////////////////////////////--COMPUTATION STATE
        begin 
            if (counter<5)
            begin 

            end 
        end
        
        FINE:   //////////////////////////////////////////////////////////////////////////////////-- FINAL STATE
        begin 
        end
        
        endcase
    end     
end

endmodule 
