`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Politecnico di Milano
//
// Authors in alphabetical order:
// (2) Enrico Melacarne <enrico.melacarne@mail.polimi.it>
// (1) Kotsaba Mykhaylo <.....@.....>
// 
// Create Date: 23.02.2020 18:18:08
// Design Name: lampFPU
// Module Name: lampFPU_fractSqrt
// Project Name: lampFPU Square Root Function
// Target Devices: 
//
// Description: Module devoted to the implementation of the Goldschmidt algorithm for square root calcolaton of a floating point number mantissa
// it takes a number expressed in format 1.xxxxxxx or 0.1xxxxxx (rispettivamente 1.M e 1.M/2) and applies Goldschmidt algorithm, returning
// the answer in the x.xxxxxxxxxxxxxxx (16 bit) format
// NB: for inputs belonging to the [.5;2] range we will have outputs belongin to the same range! (the maximum correction for the esponent E will be of "+1")
// 
// To do:
// [ ?? ] (1) Complete "dummy" TB if needed
// [    ] (2) Create an advanced verification TB (with tasks and DPI) --- Magari questo solo alla fine con la FPU completa?
// [DONE] (3) Correct the input mantissa's format
// [DONE] (4) Check if the invSqrt function works properly
// [DONE] (5) Utilize approxInvSqrt (non ho trovato un modo per riutilizzare approxRecip)
// [    ] (6) Check/correct the use of the expression "r_r*r_r" instead of "r_r^2" what actually vivado does in the two cases? (It removes the use of a DSP for sure)
// [    ] (7) Find information and introcude control of the convergence time
// [    ] (8) FUN_approxInvSqrt() restituisce xxxxx per valori in input <1/2 perchè ho considerato che non verranno mai proposti in input, ma è una scelta reliable?
// [    ] (9) ...?
//////////////////////////////////////////////////////////////////////////////////

module lampFPU_fractSqrt(
    // Timing Signals
    clk, rst,
    // Inputs
    doSqrt_i, doInvSqrt_i, s_i,
    // Outputs
    result_o, valid_o
    );


import lampFPU_pkg::*;

//  Timing Signals
input                                        clk;
input                                        rst;

//	Inputs
input                                        doSqrt_i;
input                                        doInvSqrt_i;
input	        [(1+LAMP_FLOAT_F_DW)-1:0]	 s_i;

//	Outputs
output	logic	[2*(1+LAMP_FLOAT_F_DW)-1:0]	 result_o;
output	logic                                valid_o;

// Internal Wires
logic	 [3*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]      b_tmp;
logic    [2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]      result_tmp;
logic    [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]        x0_tmp;
logic    [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]        b_r, b_next;
logic    [(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1:0]        r_r, r_next;
logic    [$clog2(LAMP_APPROX_MULS)-1:0]                i_r, i_next;
logic    [2*(1+LAMP_FLOAT_F_DW)-1:0]                   result_next;
logic                                                  valid_next;

// Definition and Declaration of FSM's State Signals
typedef enum logic [1:0]
	{
		IDLE	= 'd0,
		OP1     = 'd1,
		COMPL	= 'd2,
		OP2     = 'd3
	}	ssSigSqrt_t;

ssSigSqrt_t    ss, ss_next;

// Sequential Logic
always_ff @(posedge clk)
	begin
		if (rst)
		  begin
			ss		 <=	 IDLE;
			b_r		 <=	 '0;
			r_r		 <=	 '0;
			i_r		 <=	 '0;
			result_o <=	 '0;
			valid_o	 <=	 1'b0;
		  end
		else
		  begin
			ss		 <=	 ss_next;
			b_r		 <=	 b_next;
			r_r		 <=	 r_next;
			i_r		 <=	 i_next;
			result_o <=	 result_next;
			valid_o  <=	 valid_next;
		  end
	end

// Combinational Logic
always_comb
	begin
	
		ss_next		=	ss;
	
		b_tmp		=	b_r * r_r * r_r;
		x0_tmp      =   (s_i * FUNC_approxInvSqrt(s_i))<< (1+LAMP_PREC_DW+LAMP_FLOAT_F_DW-(LAMP_APPROX_DW+1+LAMP_FLOAT_F_DW+1));
		result_tmp  =   result_o * r_r;
	
		b_next		=	b_r;
		r_next		=	r_r; 
		i_next		=	i_r;
		result_next	=	result_o;
	
		valid_next	=	1'b0;	
		
		case (ss)
		
			IDLE:
			begin
				if (doInvSqrt_i||doSqrt_i)
                    begin
                        ss_next		=	OP1;
                        b_next		=	s_i << LAMP_PREC_DW;
                        r_next      =   FUNC_approxInvSqrt(s_i) <<(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW-(LAMP_APPROX_DW+1));
                        i_next		=	'0;
                        
                        if(doInvSqrt_i) 
                            result_next = r_next;
                        else 
                            result_next = x0_tmp << 1;
                        
                    end
			end
			
			OP1:
			begin
			
            ////// BISOGNA AGGIUNGERE UN IF/ELSE PER CONTROLLARE IL NUMERO DI ITERAZIONI ///////
            //
            // O qui o in OP2.
            // Bisogna impostare valid_o a 1 e tornare nello stato IDLE
            //
            ////////////////////////////////////////////////////////////////////////////////////
          
					ss_next		    =	COMPL;
				    b_next			=	b_tmp[(3*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1-2)-:(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)];
				    
			end
			
			COMPL:
			begin
				ss_next			=	OP2;
				r_next			=	(2'b11<<(LAMP_FLOAT_F_DW+LAMP_PREC_DW+1-2)) - (b_r>>1);
			end
			
			OP2:
			begin
			    ss_next         =   OP1;
			    result_next	    =	result_tmp[(2*(1+LAMP_FLOAT_F_DW+LAMP_PREC_DW)-1-1)-:(2*(1+LAMP_FLOAT_F_DW))];
			    i_next          =   i_r + 1;
			end
			
		endcase
	end

endmodule