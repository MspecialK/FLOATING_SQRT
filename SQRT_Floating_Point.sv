`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// University: POLITECNICO DI MILANO
// Engineer(s): 
// (1) KOTSABA MYKHAYLO  <mykhaylo.kotsaba@mail.polimi.it>
// (2) MELACARNE ENRICO  <enrico.melacarne@mail.polimi.it>
// 
// Create Date: 03/26/2020 02:08:58 PM
// Design Name: 
// Module Name: SQRT_Floating_Point_TOP
// Project Name: SQRT_Floating_Point
// Target Devices: 
// Tool Versions: 
// Description: 
// Sqrt Management block that adapt the imput to be performed and normalize the output result to 8 bit.
// 
// Dependencies: FPU_LAMP
// 
// Revision:
// Revision 1.5
// Additional Comments:
// 
//[  ] Gestione casi speciali
//[XX] Gestione segno negativo 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SQRT_Floating_Point(
    clk, rst, 
    doSqrt_i, doInvSqrt_i, s_i, e_i, f_i, nlz_i,isZ_i,isInf_i,isSNAN_i,isQNAN_i, 
    s_o, e_o, f_o, valid_o, isOverflow_o, isUnderflow_o,isToRound_o
    );

import lampFPU_pkg::*; 

    input                                           clk;
    input                                           rst;
    input                                           doSqrt_i;
    input                                           doInvSqrt_i;
    input           [LAMP_FLOAT_S_DW-1 :0]          s_i;
    input signed    [LAMP_FLOAT_E_DW-1 :0]          e_i;
    input           [LAMP_FLOAT_F_DW   :0]          f_i;
    input           [$clog2(LAMP_FLOAT_F_DW+1)-1:0] nlz_i;    // serve davvero a noi?
    
    input                                           isZ_i;
    input                                           isInf_i;
    input                                           isSNAN_i;
    input                                           isQNAN_i;    
    
    output logic    [LAMP_FLOAT_S_DW-1 :0]          s_o;
    output logic    [LAMP_FLOAT_E_DW-1 :0]          e_o;
    output logic    [LAMP_FLOAT_F_DW+4 :0]          f_o;
    output logic                                    valid_o;
    
    output logic                                    isOverflow_o;  //come??
    output logic                                    isUnderflow_o; //come?
    output logic                                    isToRound_o;   //cioe`??
    // logic means only two states

    logic  signed   [LAMP_FLOAT_E_DW-1 :0]          e_i_r;          // Register for the input: exponent (Signed)
    logic           [LAMP_FLOAT_F_DW+1 :0]          f_i_r;          // Register fot the input: Mantissa
    logic           [LAMP_FLOAT_S_DW-1 :0]          s_i_r;          // Register for the input: Sign
    logic                                           isZ_i_r;
    logic                                           isInf_i_r;
    logic                                           isSNAN_i_r;
    logic                                           isQNAN_i_r;
    // non metto i registri per doSqrt e InvSqrt
    
    logic           [(2*(LAMP_FLOAT_F_DW+1)-1):0]   res_fract;       // Output of the fract module (mantissa) 
    logic                                           valid_fract;     // Valid output of the fract module
    
    logic                                           s_o_r,s_o_nxt;
    logic           [LAMP_FLOAT_F_DW+4 :0]          f_o_r,f_o_nxt;              // Mantissa output next
    logic  signed   [LAMP_FLOAT_E_DW-1 :0]          e_o_r,e_o_nxt;              // Exponent output next
    logic                                           valid_o_r,valid_o_nxt;      // Valid output next
    
    logic           [4:0]                           shift_left;      // Shift left of the core output 
    
///////////////////////////////////////////////////////////////////////////////////////////////////////LINKING
core_SQRT core_SQRT_0 (
        .clk         (clk),
        .rst         (rst),
        .doSqrt_i    (doSqrt_i),
        .doInvSqrt_i (doInvSqrt_i),
        .f_i         (f_i_r),
        .result_o    (res_fract),
        .valid_o     (valid_fract)
    );
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             SEQUENTIAL BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk)
begin 
    if (rst)
   
    begin
       valid_o_r=0;
    end
    else
    begin
        valid_o_r<=valid_fract;
        e_o_r<=e_o_nxt;
        f_o_r<=f_o_nxt;
        s_o_r<=s_o_nxt;
    end
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////      
//                                                                           MULTIPLEXER EXPONENT AND MANTISSA
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ ( doSqrt_i or doInvSqrt_i )
begin
    s_o_r = s_i;
    casez({doSqrt_i,doInvSqrt_i,e_i[0]})
        3'b100: begin f_i_r = {f_i,1'b0}; e_i_r = (e_i)       >>>1;   end   //SQRT | EVEN
        3'b010: begin f_i_r = {f_i,1'b0}; e_i_r = (-e_i)      >>>1;   end   //INV_SQRT | EVEN
        3'b101: begin f_i_r = {1'b0,f_i}; e_i_r = (e_i+1)     >>>1;   end   //SQRT | ODD
        3'b011: begin f_i_r = {1'b0,f_i}; e_i_r = (-(e_i+1))  >>>1;   end   //INV_SQRT | ODD
    endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               NORMALIZARION
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (valid_fract) 
begin
    if(valid_fract)
    begin
        shift_left = FUNC_sqrt_zeros(res_fract);
        f_o_nxt = res_fract[2*(LAMP_FLOAT_F_DW+1)-1-shift_left-:(LAMP_FLOAT_F_DW+5)];
        e_o_nxt = e_i_r - shift_left;
        s_o_nxt = s_i;
    end
end
 
/////////////////////////////////////////////////////////////////////////////////////////////////ASSIGNMENTS
assign s_o      = s_o_r;
assign f_o      = f_o_r;
assign e_o      = e_o_r;
assign valid_o  = valid_o_r;

endmodule
