`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Politecnico di Milano
// Engineer: 
// (1) KOTSABA MYKHAYLO  <mykhaylo.kotsaba@mail.polimi.it>
// (2) MELACARNE ENRICO  <enrico.melacarne@mail.polimi.it>
// 
// Create Date: 03/17/2020 06:38:45 PM
// Design Name: 
// Module Name: SQRT_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 1.01 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module core_SQRT(clk, rst, DoSqrt_i, DoInvSqrt_i, s_i, res_o, valid_o);

import lampFPU_pkg::*;
localparam IDLE=2'b00, COMPUTATION=2'b01, FINE=2'b10;  

input                                           clk;
input                                           rst;
input                                           DoSqrt_i;
input                                           DoInvSqrt_i;
input           [LAMP_FLOAT_F_DW+1 :0]          s_i;
output logic    [LAMP_FLOAT_F_DW+1 :0]          res_o;
output logic                                    valid_o;

logic           [1:0]                           ss,ss_n;
logic           [LAMP_FLOAT_F_DW+1:0]           B,B_n;               
logic           [LAMP_FLOAT_F_DW+1:0]           Y,Y_n;     
logic           [LAMP_FLOAT_F_DW+1 :0]          res_o_n; // or X and X_n   

logic           [3*(LAMP_FLOAT_F_DW+2)-1:0]     aux_b;                                         
logic           [2*(LAMP_FLOAT_F_DW+2)-1:0]     aux_res;

logic                                           valid_o_n;
logic           [7:0]                           counter,counter_n;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               SERIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk)
    begin
        if(rst)
            begin 
                valid_o     <=1'b0;
                counter     <=0;
                ss          <=IDLE;
                B           <=0;
                res_o       <=0;
                Y           <=0;
            end    
        else
            begin 
                B           <=B_n;
                res_o       <=res_o_n;
                Y           <=Y_n;
                ss          <=ss_n;
                counter     <=counter_n;
                valid_o     <=valid_o_n;
            end
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(*) 
    begin    
        B_n         =   B; 
        Y_n         =   Y;
        res_o_n     =   res_o;
        valid_o_n   =   1'b0;
        ss_n        =   ss;
        counter_n   =   counter;
        valid_o_n   =   1'b0;
        
        case (ss)
        IDLE: //////////////////////////////////////////////////////////////////////////////////////--IDLE STATE
        begin   
            if (DoSqrt_i || DoInvSqrt_i)                
            begin        
                B_n           =   s_i;
                Y_n           =   9'b110000000-(B_n>>1);  // {FUNC_approxInvSqrt(B_n),4'b0000};                                       
                ss_n          =   COMPUTATION;                              
                counter_n     =   0;
                aux_res       =   s_i*Y_n;
                if(DoSqrt_i)    begin res_o_n = aux_res[16:8]; end
                else            begin res_o_n = Y_n; end
            end
        end
                  
        COMPUTATION: ////////////////////////////////////////////////////////////////////////--COMPUTATION STATE
        begin 
            if (counter<=5)
            begin                         
                aux_b       =   B*Y*Y;
                B_n=aux_b[24:16];      
                Y_n=9'b110000000-(B_n>>1);    
                aux_res     =   res_o*Y_n;
                res_o_n=aux_res[16:8];                
                counter_n=counter+1;             
                if (counter == 5) 
                begin 
                    valid_o_n = 1'b1;
                    ss_n=FINE;  
                end
            end 
        end
                                
        FINE:   //////////////////////////////////////////////////////////////////////////////////-- FINAL STATE
        begin 
            ss_n=IDLE;
        end
        endcase
        
    end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
endmodule