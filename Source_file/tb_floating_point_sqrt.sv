`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Politecnico di Milano 
// Engineer: Mykhaylo Kotsaba &  Enrico Melacarne
// 
// Create Date: 03/09/2020 11:21:17 AM
// Design Name: 
// Module Name: tb_floating_point_sqrt
// Project Name: Floating Point SQRT
// Description: 
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_floating_point_sqrt();
reg clk;
reg rst;
reg sqrt_start;
reg [15:0] num_i;
reg [15:0] num_o;
reg valid_o, error_o;

always #5 clk=~clk;

initial
    begin
        $dumpfile("out.vcd");
        $dumpvars(0,floating_point_sqrt);

        clk<=0;
        rst=1;
        
        repeat(10) @(posedge clk);
        rst<=0;
        
        repeat(1) @(posedge clk);
        num_i=16'b0_00000101_0010000;   // 36 in floating point 
        sqrt_start=1;
        repeat(1) @(posedge clk);
        sqrt_start=0;
        repeat(10) @(posedge clk);
        
        rst=1;
        repeat(2) @(posedge clk);
        rst=0;
        repeat(1) @(posedge clk);
        num_i=16'b0_00000100_1001000;   // 25 in floating point 
        sqrt_start=1;
        repeat(1) @(posedge clk);
        sqrt_start=0;
        
        
        
        $finish;
        
    end
    
floating_point_sqrt floating_point_sqrt_0( .clk(clk), .rst(rst), .sqrt_start(sqrt_start), .num_i(num_i), .res_o(num_o), .error_o(error_o), .valid_o(valid_o)); 
endmodule
