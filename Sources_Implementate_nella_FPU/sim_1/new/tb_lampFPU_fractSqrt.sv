`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Politecnico di Milano
//
// Authors in alphabetical order: 
// (1) Melacarne Enrico <enrico.melacarne@mail.polimi.it>
// (2) Kotsaba Mykhaylo <.....@.....>
// 
// Create Date: 27.02.2020 13:36:39
// Design Name: lampFPU
// Module Name: tb_lampFPU_fractSqrt
// Project Name: lampFPU Square Root Function
// Target Devices:

// Description: DUMMY tb to check in the fractSqrt.sv module is at least working in the right way
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_lampFPU_fractSqrt;

import lampFPU_pkg::*;
parameter HALF_CLK_PERIOD_NS=20;

logic	                             clk;
logic	                             rst;
logic                                tb_doSqrt;
logic                                tb_doInvSqrt;
logic   [(1+LAMP_FLOAT_F_DW)-1:0]    tb_s;
logic   [2*(1+LAMP_FLOAT_F_DW)-1:0]  tb_result;
logic                                tb_valid;

initial 
begin
clk <= 0;
rst <= 1;
repeat(2) @(posedge clk);
        rst <= 0;
        tb_doSqrt <= 0;
        tb_doInvSqrt <= 1;
        tb_s <= 8'b01000000;

end

lampFPU_fractSqrt lampFPU_fractSqrt0 (
		.clk		 (clk),
		.rst		 (rst),
		.doSqrt_i	 (tb_doSqrt),
		.doInvSqrt_i (tb_doInvSqrt),
		.s_i		 (tb_s),
		.result_o	 (tb_result),
		.valid_o	 (tb_valid)
	);




always #HALF_CLK_PERIOD_NS clk = ~clk;

//always@(posedge clk)
//begin
//    $display("B_tmp: %t %b", $time, tb_lampFPU_fractSqrt.lampFPU_fractSqrt0.b_tmp);
//    $display("B_r:   %t %b", $time, tb_lampFPU_fractSqrt.lampFPU_fractSqrt0.b_r);
//    $display("R_r:   %t %b", $time, tb_lampFPU_fractSqrt.lampFPU_fractSqrt0.r_r);
//end




endmodule

