`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// University: Politecnico di Milano
// Engineer(s): 
// (1) KOTSABA MYKHAYLO  <mykhaylo.kotsaba@mail.polimi.it>
// (2) MELACARNE ENRICO  <enrico.melacarne@mail.polimi.it>
// 
// Create Date: 03/17/2020 06:38:45 PM
// Design Name: 
// Module Name: SQRT_Floating_Point_CORE
// Project Name: SQRT_Floating_Point
// Target Devices: 
// Tool Versions: 

// Description: 
// The core performs both Square root and Inverse Square root of the mantissa in 9 bits [01|M] or [1|M|0]  already in input. 
// Could not working in different condition.
// 16 bit floating point number [s]|[e]|[m]  [1]|[8]|[7]
// The output is not normalized in the core, but in the top core. 
// 
// Dependencies: The core part of the SQRT_Floating_Point module 
// 
// Revision:
// Revision 1.5
// Additional Comments:
//[  ] Need comments 
//[  ] Style revision 
//[  ] Ottimization if possible.
//[  ] 12 bit in uscita dal modulo? 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module core_SQRT(clk, rst, DoSqrt_i, DoInvSqrt_i, m_i, res_o, valid_o);

    import lampFPU_pkg::*;
    localparam IDLE=1'b0, COMPUTATION=1'b1;  

    input                                           clk;        
    input                                           rst;
    input                                           DoSqrt_i;                  //Start Sqrt operation.
    input                                           DoInvSqrt_i;               //Start Inverse Sqrt operation.
    input           [LAMP_FLOAT_F_DW+1 :0]          m_i;                       //Mantissa input.
    output logic    [LAMP_FLOAT_F_DW+1 :0]          res_o;                     //Result that can be both, sqrt or  invSqrt.
    output logic                                    valid_o;                   //Valid output bit.

    logic                                           ss,ss_n;                   //State counter and next_state counter. 1 bit because we have only two states.
    logic           [LAMP_FLOAT_F_DW+1:0]           B,B_n;                     
    logic           [LAMP_FLOAT_F_DW+1:0]           Y,Y_n;     
    logic           [LAMP_FLOAT_F_DW+1 :0]          res_o_n;                    
    logic           [3*(LAMP_FLOAT_F_DW+2)-1:0]     aux_b;                     //Auxiliar register to store the multiplication for the B parameter.                     
    logic           [2*(LAMP_FLOAT_F_DW+2)-1:0]     aux_res;                   //Auxiliar register to store the multiplication for the Result parameter.   

    logic                                           valid_o_n;
    logic           [2:0]                           counter,counter_n;         //Counter up to five cycles. 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                SERIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk)
    begin
        if(rst)
        begin 
            valid_o     <= 1'b0;
            counter     <= 1'b0;
            ss          <= IDLE;
            B           <= 1'b0;
            res_o       <= 1'b0;
            Y           <= 1'b0;
        end    
        else
        begin 
            B           <= B_n;
            res_o       <= res_o_n;
            Y           <= Y_n;
            ss          <= ss_n;
            counter     <= counter_n;
            valid_o     <= valid_o_n;
        end
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                           SEQUENTIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(*) 
    begin    
        B_n         =   B; 
        Y_n         =   Y;
        res_o_n     =   res_o;  
        valid_o_n   =   1'b0;
        ss_n        =   ss;
        counter_n   =   counter;
        valid_o_n   =   1'b0;
        
        case (ss)
        IDLE: /////////////////////////////////////////////////////////////////////////////////////// IDLE STATE
        begin   
            if (DoSqrt_i || DoInvSqrt_i)                
            begin        
                B_n           =   m_i;
                Y_n           =   9'b110000000-(B_n>>1);                                 
                ss_n          =   COMPUTATION;                              
                counter_n     =   0;
                aux_res       =   m_i*Y_n;
                if(DoSqrt_i)    begin res_o_n = aux_res[2*(LAMP_FLOAT_F_DW+2)-2-:(LAMP_FLOAT_F_DW+2)]; end     
                else            begin res_o_n = Y_n; end        //res_o_n depend on the selected operation  
            end
        end
              
        COMPUTATION: ///////////////////////////////////////////////////////////////////////// COMPUTATION STATE
        begin 
            if (counter<=5)
            begin                         
                aux_b       =   B*Y*Y;
                B_n         =   aux_b[3*(LAMP_FLOAT_F_DW+2)-3-:(LAMP_FLOAT_F_DW+2)];    
                Y_n         =   9'b110000000-(B_n>>1);    
                aux_res     =   res_o*Y_n;
                res_o_n     =   aux_res[16:8];                
                counter_n   =   counter+1;        
                if (counter == 5) 
                begin 
                    valid_o_n   =   1'b1;
                    ss_n        =   IDLE;  
                end
            end 
        end
        endcase
    end
    
endmodule