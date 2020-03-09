package lampFPU_pkg;

	parameter LAMP_FLOAT_DW		=	16;
	parameter LAMP_FLOAT_S_DW 	=	1;
	parameter LAMP_FLOAT_E_DW 	=	8;
	parameter LAMP_FLOAT_F_DW 	=	7;

	parameter LAMP_INTEGER_DW	=	32;
	parameter LAMP_INTEGER_S_DW	=	1;
	parameter LAMP_INTEGER_F_DW	=	31;

	parameter LAMP_FLOAT_E_BIAS	=	(2 ** (LAMP_FLOAT_E_DW - 1)) - 1;
	parameter LAMP_FLOAT_E_MAX	=	(2 ** LAMP_FLOAT_E_DW) - 1;

	parameter INF				=	15'h7f80;
	parameter ZERO				=	15'h0000;
	parameter SNAN				=	15'h7fbf;
	parameter QNAN				=	15'h7fc0;

	//	used in TB only
	parameter PLUS_INF			=	16'h7f80;
	parameter MINUS_INF			=	16'hff80;
	parameter PLUS_ZERO			=	16'h0000;
	parameter MINUS_ZERO		=	16'h8000;

	parameter INF_E_F			=	15'b111111110000000; // w/o sign
	parameter SNAN_E_F			=	15'b111111110111111; // w/o sign
	parameter QNAN_E_F			=	15'b111111111000000; // w/o sign
	parameter ZERO_E_F			=	15'b000000000000000; // w/o sign

	//	div-only
	parameter LAMP_APPROX_DW	=	4;
	parameter LAMP_PREC_DW		=	8;
	parameter LAMP_APPROX_MULS	=	$clog2 ((LAMP_FLOAT_DW+1)/LAMP_APPROX_DW);

	typedef enum logic
	{
		FPU_RNDMODE_NEAREST		=	'd0,
		FPU_RNDMODE_TRUNCATE	=	'd1
	} rndModeFPU_t;

	typedef enum logic[3:0]
	{
		FPU_IDLE	= 4'd0,

		FPU_I2F		= 4'd1,
		FPU_F2I		= 4'd2,

		FPU_ADD		= 4'd3,
		FPU_SUB		= 4'd4,
		FPU_MUL		= 4'd5,
		FPU_DIV		= 4'd6,

		FPU_EQ		= 4'd7,
		FPU_LT		= 4'd8,
		FPU_LE		= 4'd9
	} opcodeFPU_t;

	function automatic logic[LAMP_APPROX_DW-1:0] FUNC_approxRecip(
            input [(1+LAMP_FLOAT_F_DW)-1:0] f_i
        );
            case(f_i[(1+LAMP_FLOAT_F_DW)-2-:LAMP_APPROX_DW])
                'b0000    :    return 'b1111;
                'b0001    :    return 'b1101;
                'b0010    :    return 'b1100;
                'b0011    :    return 'b1010;
                'b0100    :    return 'b1001;
                'b0101    :    return 'b1000;
                'b0110    :    return 'b0111;
                'b0111    :    return 'b0110;
                'b1000    :    return 'b0101;
                'b1001    :    return 'b0100;
                'b1010    :    return 'b0011;
                'b1011    :    return 'b0011;
                'b1100    :    return 'b0010;
                'b1101    :    return 'b0001;
                'b1110    :    return 'b0001;
                'b1111    :    return 'b0000;
            endcase
    endfunction


	// NEW PART ADDED FOR SQRT ONLY
	function automatic logic[LAMP_APPROX_DW-1+1:0] FUNC_approxInvSqrt(
						input [(1+LAMP_FLOAT_F_DW)-1:0] f_i
				);
						case(f_i[(1+LAMP_FLOAT_F_DW)-1-:LAMP_APPROX_DW])
								'b0100    :    return 'b10110;
								'b0101    :    return 'b10100;
								'b0110    :    return 'b10010;
								'b0111    :    return 'b10001;
								'b1000    :    return 'b10000;
								'b1001    :    return 'b01111;
								'b1010    :    return 'b01110;
								'b1011    :    return 'b01101;
								'b1100    :    return 'b01101;
								'b1101    :    return 'b01100;
								'b1110    :    return 'b01100;
								'b1111    :    return 'b01011;
						endcase
		endfunction

endpackage
