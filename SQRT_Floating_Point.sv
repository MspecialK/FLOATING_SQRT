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
//[  ] Gestione segno negativo 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SQRT_Floating_Point(clk, rst, DoSqrt_i, DoInvSqrt_i, s_i, e_i, m_i, s_o, e_o, m_o, valid_o);

import lampFPU_pkg::*; 
localparam IDLE=2'b00, COMPUTATION=2'b01, FINE=2'b10;  

    input                                           clk;
    input                                           rst;
    input                                           DoSqrt_i;
    input                                           DoInvSqrt_i;
    input           [LAMP_FLOAT_S_DW-1 :0]          s_i;
    input signed    [LAMP_FLOAT_E_DW-1 :0]          e_i;
    input           [LAMP_FLOAT_F_DW   :0]          m_i;

    output logic    [LAMP_FLOAT_S_DW-1 :0]          s_o;
    output logic    [LAMP_FLOAT_E_DW-1 :0]          e_o;
    output logic    [LAMP_FLOAT_F_DW+4 :0]          m_o;
    output logic                                    valid_o;         // logic means only two states

    logic  signed   [LAMP_FLOAT_E_DW-1 :0]          fs_e_i;          // Register for the input: exponent (Signed)
    logic           [LAMP_FLOAT_F_DW+1 :0]          fs_m_i;          // Register fot the input: Mantissa
    logic           [LAMP_FLOAT_S_DW-1 :0]          fs_s_i;          // Register for the input: Sign
    
    logic           [(2*(LAMP_FLOAT_F_DW+1)-1):0]   fs_res_o;        // Output of the core 
    logic           [LAMP_FLOAT_F_DW+4 :0]          m_o_n;           // Mantissa output next
    logic  signed   [LAMP_FLOAT_E_DW-1 :0]          e_o_n;           // Exponent output next
    logic                                           valid_o_n;       // Valid output next

    logic  signed   [LAMP_FLOAT_E_DW-1 :0]          fs_e_o;          // Register for the output: Exponent (signed)
    logic           [LAMP_FLOAT_F_DW+4 :0]          fs_m_o;          // Register for the output: Mantissa
    logic           [LAMP_FLOAT_S_DW-1 :0]          fs_s_o;          // Register for the output: Sign
    logic                                           fs_valid_o;      // Register for the output: Valid_o
    logic           [4:0]                           shift_left;      // Shift left of the core output 

///////////////////////////////////////////////////////////////////////////////////////////////////////LINKING
core_SQRT core_SQRT_0 (
        .clk         (clk),
        .rst         (rst),
        .DoSqrt_i    (DoSqrt_i),
        .DoInvSqrt_i (DoInvSqrt_i),
        .m_i         (fs_m_i),
        .res_o       (fs_res_o),
        .valid_o     (valid_o_n)
    );
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             SEQUENTIAL BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk)
begin 
    if (rst)
    begin
        fs_valid_o<=0;
        fs_e_o<=0;
        fs_m_o<=0;
        fs_s_o<=0;
    end
    else
    begin
        fs_valid_o<=valid_o_n;
        fs_e_o<=e_o_n;
        fs_m_o<=m_o_n;
        fs_s_o<=fs_s_i;
    end
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////      
//                                                                           MULTIPLEXER EXPONENT AND MANTISSA
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ ( DoSqrt_i or DoInvSqrt_i )
begin
    fs_s_i = s_i;
    casez({DoSqrt_i,DoInvSqrt_i,e_i[0]})
        3'b100: begin fs_m_i = {m_i,1'b0}; fs_e_i = (e_i)       >>>1;   end   //SQRT | EVEN
        3'b010: begin fs_m_i = {m_i,1'b0}; fs_e_i = (-e_i)      >>>1;   end   //INV_SQRT | EVEN
        3'b101: begin fs_m_i = {1'b0,m_i}; fs_e_i = (e_i+1)     >>>1;   end   //SQRT | ODD
        3'b011: begin fs_m_i = {1'b0,m_i}; fs_e_i = (-(e_i+1))  >>>1;   end   //INV_SQRT | ODD
    endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               NORMALIZARION
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (valid_o_n) 
begin
    if(valid_o_n)
    begin
        shift_left = FUNC_sqrt_zeros(fs_res_o);
        m_o_n = fs_res_o[2*(LAMP_FLOAT_F_DW+1)-1-shift_left-:(LAMP_FLOAT_F_DW+5)];
        e_o_n = fs_e_i - shift_left;
    end
end
 
/////////////////////////////////////////////////////////////////////////////////////////////////ASSIGNMENTS
assign s_o      = fs_s_o;
assign m_o      = fs_m_o;
assign e_o      = fs_e_o;
assign valid_o  = fs_valid_o;

endmodule
