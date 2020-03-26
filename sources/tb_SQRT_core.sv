`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2020 07:50:23 PM
// Design Name: 
// Module Name: tb_lampFPU_fractSQRT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_SQRT_core();
    reg                 clk;
    reg                 rst;
    reg                 DoSqrt_i, DoInvSqrt_i;
    reg [8:0]           s_i;
    reg [8:0]           res_o;
    reg                 valid_o;
    reg [8:0]           counter_sqrt,counter_invsqrt;
    
    real numero_in, numero_o, errore_mantissa;
    
    always #5 clk=~clk;
    
    initial
        begin
           
            clk<=0;
            DoInvSqrt_i=0;
            counter_sqrt=0;
            counter_invsqrt=0;
            rst=1;
            repeat(1) @(posedge clk);
            rst<=0;
            
            repeat(20) ////////////////////////////////////////////////////////////////////SQRT_TB
            begin
                counter_sqrt=counter_sqrt+1;
                s_i = $random;
                numero_in= s_i[8]*1 + s_i[7]*0.5 + s_i[6]*0.25 + s_i[5]*0.125 + s_i[4]*0.0625 + s_i[3]*0.03125 + s_i[2]*0.015625 + s_i[1]*0.0078125 + s_i[0]*0.000390625;
                DoSqrt_i=1;
                repeat(1) @(posedge clk);
                DoSqrt_i=0;
                repeat(7) @(posedge clk);
                if (valid_o)
                begin
                    numero_o = res_o[8]*1 + res_o[7]*0.5 + res_o[6]*0.25 + res_o[5]*0.125 + res_o[4]*0.0625 + res_o[3]*0.03125 + res_o[2]*0.015625 + res_o[1]*0.0078125 + res_o[0]*0.000390625;
                    errore_mantissa=numero_in-numero_o*numero_o;
                    $display("PROVA RADICE [%d] : Input = [%f] || Output = [%f] || errore %f  ",counter_sqrt, numero_in, numero_o,errore_mantissa);
                end
            end
            
            repeat(20) ////////////////////////////////////////////////////////////////////INVSQRT_TB
            begin
                counter_invsqrt=counter_invsqrt+1;
                s_i = $random;
                numero_in= s_i[8]*1 + s_i[7]*0.5 + s_i[6]*0.25 + s_i[5]*0.125 + s_i[4]*0.0625 + s_i[3]*0.03125 + s_i[2]*0.015625 + s_i[1]*0.0078125 + s_i[0]*0.000390625;
                DoInvSqrt_i=1;
                repeat(1) @(posedge clk);
                DoInvSqrt_i=0;
                repeat(7) @(posedge clk);
                if (valid_o)
                begin
                    numero_o = res_o[8]*1 + res_o[7]*0.5 + res_o[6]*0.25 + res_o[5]*0.125 + res_o[4]*0.0625 + res_o[3]*0.03125 + res_o[2]*0.015625 + res_o[1]*0.0078125 + res_o[0]*0.000390625;
                    errore_mantissa=numero_in-1/(numero_o*numero_o);
                    $display("PROVA RADICE INVERSA [%d] : Input = [%f] || Output = [%f] || errore %f  ",counter_invsqrt, numero_in, numero_o,errore_mantissa);
                end
            end
        
    end
    
    core_SQRT core_SQRT_0( .clk(clk), .rst(rst), .DoSqrt_i(DoSqrt_i), .DoInvSqrt_i(DoInvSqrt_i), .s_i(s_i), .res_o(res_o), .valid_o(valid_o)); 

endmodule

