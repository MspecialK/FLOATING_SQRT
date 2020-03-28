`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Politecnico di Milano
//
// Authors in alphabetical order:
// (1) Kotsaba Mykhaylo <.....@.....>
// (2) Melacarne Enrico <enrico.melacarne@mail.polimi.it>
//
// Create Date: 23.02.2020 18:18:08
// Design Name: lampFPU
// Module Name: lampFPU_fractSqrt
// Project Name: lampFPU Square Root Function
// Target Devices:
//
// Description:
//
// To do:
//////////////////////////////////////////////////////////////////////////////////

module lampFPU_sqrt(
    // Timing Signals
    clk, rst,
    // Inputs
    doSqrt_i, doInvSqrt_i,
    s_i, extF_i, extE_i, nlz_i, /////////////// nota bene la extF Ã© una extShF!!!!!! magari cambio il nome
    isZ_i, isInf_i, isSNAN_i, isQNAN_i,
    // Outputs
    s_res_o, e_res_o, f_res_o, valid_o,
    isOverflow_o,isUnderflow_o, isToRound_o
    );


import lampFPU_pkg::*;

// Timing Signals
input                                  clk;
input                                  rst;

// Inputs
input                                  doSqrt_i;
input                                  doInvSqrt_i;
input [LAMP_FLOAT_S_DW-1:0]			   s_i;
input [(1+LAMP_FLOAT_F_DW)-1:0]		   extF_i;
input [(LAMP_FLOAT_E_DW+1)-1:0]		   extE_i;  // cosa mi rappresenta il bit extra?
input [$clog2(LAMP_FLOAT_F_DW+1)-1:0]  nlz_i;
input								   isZ_i;
input								   isInf_i;
input								   isSNAN_i;
input								   isQNAN_i;

// Outputs
output	logic						   s_res_o;
output	logic [LAMP_FLOAT_E_DW-1:0]	   e_res_o;
output	logic [LAMP_FLOAT_F_DW+5-1:0]  f_res_o;
output	logic						   valid_o;
output	logic						   isOverflow_o;
output	logic						   isUnderflow_o;
output	logic						   isToRound_o;

// Internal Wires
logic [LAMP_FLOAT_S_DW-1:0]			   s_r;
logic [(1+LAMP_FLOAT_F_DW)-1:0]		   extF_r;
logic [(LAMP_FLOAT_E_DW+1)-1:0]		   extE_r;
logic								   isZ_r;
logic								   isInf_r;
logic								   isSNAN_r;
logic								   isQNAN_r;
logic								   doSqrt_r;
logic								   doInvSqrt_r;

logic						           s_res;
logic [LAMP_FLOAT_E_DW-1:0]	           e_res;
logic [LAMP_FLOAT_F_DW+5-1:0]	       f_res;
logic						   	       valid;
logic							       isOverflow;
logic							       isUnderflow;
logic						           isToRound;

logic [LAMP_FLOAT_E_DW-1:0]	           e_res_postNorm, e_res_preNorm;
logic [LAMP_FLOAT_F_DW+5-1:0]	       f_res_postNorm;
logic [2*(1+LAMP_FLOAT_F_DW)-1:0]      f_res_preNorm;
logic                                  stickyBit;

logic			   					   isCheckNanInfValid;
logic								   isZeroRes;
logic								   isCheckInfRes;
logic								   isCheckNanRes;
logic								   isCheckSignRes;

// FractSqrt Signals
logic                                  fs_doSqrt;
logic                                  fs_doInvSqrt;
logic [(1+LAMP_FLOAT_F_DW)-1:0]        fs_f;
logic [2*(1+LAMP_FLOAT_F_DW)-1:0]      fs_result;
logic                                  fs_valid;


logic									s_initial_res_div;
logic	[1+1+LAMP_FLOAT_E_DW-1:0]		e_initial_res_div_temp;		// 1+ care for ovf or 2'compl, result of the difference of exponents
logic	[1+1+LAMP_FLOAT_E_DW-1:0]		e_initial_extra_neg_temp;	// 1+ care for ovf or 2'compl, result of the difference of exponents
logic	[1+1+LAMP_FLOAT_E_DW-1:0]		e_initial_res_div;			// 1+ care for ovf or 2'compl, result of the difference of exponents
logic	[2*(1+LAMP_FLOAT_F_DW)-1:0]		f_initial_dsp_res_div;		// f = f_op1 / f_op2 (twice the width)
logic	[(1+1+LAMP_FLOAT_F_DW+3)-1:0]	f_initial_res_div;			// f = f_op1 / f_op2
logic                                   leftShift;
logic	[1+1+LAMP_FLOAT_E_DW-1:0]		e_initial_res_div_r;
logic   [1+1+LAMP_FLOAT_E_DW-1:0]       e_initial_extra_neg_r;
logic   [1+1+LAMP_FLOAT_E_DW-1:0]       e_initial_extra_neg;




// FractSqrt Module
lampFPU_fractSqrt lampFPU_fractSqrt0 (
        .clk         (clk),
        .rst         (rst),
        .doSqrt_i    (fs_doSqrt),
        .doInvSqrt_i (fs_doInvSqrt),
        .s_i         (fs_f),
        .result_o    (fs_result),
        .valid_o     (fs_valid)
    );


// Sequential Logic
always_ff @(posedge clk)
begin
    if(rst)
    begin
        s_r            <= '0;
        isZ_r          <= '0;
        isInf_r        <= '0;
        isSNAN_r       <= '0;
        isQNAN_r       <= '0;
        doSqrt_r       <= '0;
        doInvSqrt_r    <= '0;
        s_res_o        <= '0;
        e_res_o        <= '0;
        f_res_o        <= '0;
        valid_o        <= '0;
        isOverflow_o   <= '0;
        isUnderflow_o  <= '0;
        isToRound_o    <= '0;
        
        e_initial_res_div_r		<=	'0;
        e_initial_extra_neg_r    <=    '0;
    end
    else
    begin
        if(doSqrt_i|doInvSqrt_i) begin
        s_r            <= s_i;
        isZ_r          <= isZ_i;
        isInf_r        <= isInf_i;
        isSNAN_r       <= isSNAN_i;
        isQNAN_r       <= isQNAN_i;
        doSqrt_r       <= doSqrt_i;
        doInvSqrt_r    <= doInvSqrt_i;
        end
        s_res_o        <= s_res;
        e_res_o        <= e_res;
        f_res_o        <= f_res;
        valid_o        <= valid;
        isOverflow_o   <= isOverflow;
        isUnderflow_o  <= isUnderflow;
        isToRound_o    <= isToRound;
        
        e_initial_res_div_r		<=	e_initial_res_div_temp;
        e_initial_extra_neg_r    <=    e_initial_extra_neg_temp;
    end
end

// Wire Assignement
assign fs_doSqrt    = doSqrt_i;
assign fs_doInvSqrt = doInvSqrt_i;

// Combinational logic for mantissa computation (F) --preFract --preNorm
always_comb
begin
    if(extE_i[0])
        fs_f = extF_i;
    else
        fs_f = extF_i>>1;
end

// Combinational logic for exponent computation (E) --preNorm
always_comb
begin
    if(doSqrt_i)
        e_res_preNorm = (LAMP_FLOAT_E_BIAS-1)/2 + ((extE_i-nlz_i)>>1) + 1;
    else if(doInvSqrt_i)
        e_res_preNorm = 3*(LAMP_FLOAT_E_BIAS-1)/2 - ((extE_i-nlz_i)>>1) + 1;  // il primo termine e' un parametro, posso permettermi il "3*", non dovrebbero venire utilizzati DSP
end

// Exponent and FractSqrt-Output Normalization
always_comb
begin
    f_res_preNorm = fs_result;//[2*(1+LAMP_FLOAT_F_DW)-1-:LAMP_FLOAT_F_DW+5];
    if(~f_res_preNorm[2*(1+LAMP_FLOAT_F_DW)-1])
    begin // FORMA 01.xxxx
        stickyBit         =|f_res_preNorm[0 +:(2*(1+LAMP_FLOAT_F_DW)-1)-(1+1+LAMP_FLOAT_F_DW+3)-1];
        f_res_postNorm    = f_res_preNorm[2*(1+LAMP_FLOAT_F_DW)-1 -: LAMP_FLOAT_F_DW+5]; // lascio nella forma 01.xxx, il rounding elimina i primi due bit 
        //f_res_postNorm[1] = f_res_preNorm[(2*(1+LAMP_FLOAT_F_DW)-1)-(1+1+LAMP_FLOAT_F_DW+3)-1]|stickyBit;
        e_res_postNorm    = e_res_preNorm - 1;
    end
    else
    begin // FORMA 1.xxxxx
        stickyBit         =|f_res_preNorm[0 +:(2*(1+LAMP_FLOAT_F_DW)-1)-(1+1+LAMP_FLOAT_F_DW+3)];
        f_res_postNorm    = {1'b0, f_res_preNorm[2*(1+LAMP_FLOAT_F_DW)-1 -: LAMP_FLOAT_F_DW+5 - 1]}; // aggiungo 0 all'inizio ---> forma 01.xxx e rounding taglierà "01"
        //f_res_postNorm[1] = f_res_preNorm[(2*(1+LAMP_FLOAT_F_DW)-1)-(1+1+LAMP_FLOAT_F_DW+3)]|stickyBit;
        e_res_postNorm    = e_res_preNorm;
    end

    f_res_postNorm[0] = stickyBit;
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // CHIEDERE CONFERME SULLO STICKY BIT PERCHE' IO NON SONO SICURO
    //
    ///////////////////////////////////////////////////////////////////////////////////
end


// Condition detection
always_comb
begin

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // BISOGNA ANCHE INSERIRE IL CASO InvSqrt NELLA FUNC_calcInfNanZeroResSqrt(...)
    //
    ///////////////////////////////////////////////////////////////////////////////////

    {isCheckNanInfValid, isZeroRes, isCheckInfRes, isCheckNanRes, isCheckSignRes} = FUNC_calcInfNanZeroResSqrt(isZ_r, isInf_r, s_r, isSNAN_r, isQNAN_r, doSqrt_r, doInvSqrt_r);

    unique if (isZeroRes)
        {s_res, e_res, f_res} = {isCheckSignRes, ZERO_E_F, 5'b0};  // ZERO_E_F contiene sia esponente che mantissa, gli ultimi 5 bit sono quelli per il rounding
    else if (isCheckInfRes)
        {s_res, e_res, f_res} = {isCheckSignRes, INF_E_F,  5'b0};
    else if (isCheckNanRes) 
        {s_res, e_res, f_res} = {isCheckSignRes, QNAN_E_F, 5'b0};
    else
        {s_res, e_res, f_res} = {isCheckSignRes, e_res_postNorm[LAMP_FLOAT_E_DW-1:0], f_res_postNorm};

    valid       = fs_valid;
    isToRound   = ~isCheckNanInfValid;
    isOverflow  = 1'b0;
    isUnderflow = 1'b0;

end


endmodule
