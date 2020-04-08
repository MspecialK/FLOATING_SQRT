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
//[X-] Need comments 
//[X-] Style revision 
//[XX] Ottimization if possible.
//[XX] 16 bit in uscita dal modulo? 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module core_SQRT(
        clk, rst,                             // Timing signals
        doSqrt_i, doInvSqrt_i, f_i,           // Inputs
        result_o, valid_o                     // Outputs
        );

    import lampFPU_pkg::*;
    localparam IDLE=1'b0, COMPUTATION=1'b1;  
    
    //Input and Outputs
    input                                           clk;        
    input                                           rst;
    input                                           doSqrt_i;                  //Start Sqrt operation.
    input                                           doInvSqrt_i;               //Start Inverse Sqrt operation.
    input           [LAMP_FLOAT_F_DW+1:0]           f_i;                       //Mantissa input.
    output logic    [(2*(LAMP_FLOAT_F_DW+1)-1):0]   result_o;                  //Result that can be both, sqrt or  invSqrt.
    output logic                                    valid_o;                   //Valid output bit.

    //Internal wires 
    logic                                           ss,ss_nxt;                 //State counter and next_state counter. 1 bit because we have only two states.
    logic           [LAMP_FLOAT_F_DW+1:0]           b,b_nxt;                     
    logic           [LAMP_FLOAT_F_DW+1:0]           y,y_nxt;                       
    logic           [3*(LAMP_FLOAT_F_DW+2)-1:0]     aux_b;                     //Auxiliar register to store the multiplication for the B parameter.                     
    logic           [LAMP_FLOAT_F_DW+1:0]           res,res_nxt;          
    logic           [2*(LAMP_FLOAT_F_DW+2)-1:0]     aux_res;                   //Auxiliar register to store the multiplication for the Result parameter.   

    logic                                           valid_o_nxt;
    logic           [2:0]                           i,i_nxt;                   //Counter up to five cycles. 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                SERIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk)
    begin
        if(rst)
        begin 
            valid_o     <= 0;
            i           <= 0;
            ss          <= IDLE;
            b           <= 0;
            res         <= 0;
            y           <= 0;
        end    
        else
        begin 
            b           <= b_nxt;
            res         <= res_nxt;
            y           <= y_nxt;
            ss          <= ss_nxt;
            i           <= i_nxt;
            valid_o     <= valid_o_nxt;
        end
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                           SEQUENTIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(*) 
    begin    
        b_nxt         =   b_nxt; 
        y_nxt         =   y;
        res_nxt       =   res;  
        valid_o_nxt   =   1'b0;
        ss_nxt        =   ss;
        i_nxt         =   i;
        valid_o_nxt   =   1'b0;
        
        case (ss)
        IDLE: /////////////////////////////////////////////////////////////////////////////////////// IDLE STATE
        begin   
            if (doSqrt_i || doInvSqrt_i)                
            begin        
                b_nxt           =   f_i;
                y_nxt           =   9'b110000000-(b_nxt>>1);                                 
                ss_nxt          =   COMPUTATION;                              
                i_nxt           =   0;
                aux_res         =   b_nxt*y_nxt;
                if(doSqrt_i)    begin res_nxt = aux_res[2*(LAMP_FLOAT_F_DW+2)-2-:(LAMP_FLOAT_F_DW+2)]; end     
                else            begin res_nxt = y_nxt; end        //res_o_n depend on the selected operation  
            end
        end
              
        COMPUTATION: ///////////////////////////////////////////////////////////////////////// COMPUTATION STATE
        begin 
            if (i<=5)
            begin                         
                aux_b       =   b*y*y;
                b_nxt       =   aux_b[3*(LAMP_FLOAT_F_DW+2)-3-:(LAMP_FLOAT_F_DW+2)];    
                y_nxt       =   9'b110000000-(b_nxt>>1);    
                aux_res     =   res*y_nxt;
                res_nxt     =   aux_res[2*(LAMP_FLOAT_F_DW+2)-2-:(LAMP_FLOAT_F_DW+2)];                
                i_nxt       =   i+1;        
                if (i == 5) 
                begin 
                    valid_o_nxt   =   1'b1;   //Go back to IDLE, we set the valid_o and we are ready in the same clock cycle to start another operation
                    ss_nxt        =   IDLE;  
                end
            end 
        end
        endcase
    end
    
    assign result_o = aux_res[2*(LAMP_FLOAT_F_DW+2)-2-:(2*(LAMP_FLOAT_F_DW+1))];
    
endmodule