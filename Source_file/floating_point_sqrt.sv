`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: POLITECNICO DI MILANO
// Engineer: MYKHAYLO KOTSABA & ENRICO MELACARNE (Ordine Alfabetico) 
// 
// Create Date: 02/22/2020 01:35:11 PM
// Module Name: floating_point_sqrt
// Project Name: Floating Point SQRT
// Revision: 0.0
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module floating_point_sqrt(input clk, input rst, input sqrt_start, input [15:0] num_i, output [15:0] num_o, output error_o, output valid_o);

localparam IDLE=2'b00, COMPUTATION=2'b01, FINE=2'b10;

reg [7:0] mantissa_in, mantissa_in_next;
reg [7:0] exponent_in, exponent_in_next;
reg sign_in, sign_in_next;

reg [8:0] B,Bnext;
reg [8:0] Y,Ynext;
reg [8:0] y,ynext;
reg [8:0] x,xnext;

reg [1:0] state,state_next;
reg [7:0] counter,counter_next;

reg [7:0] exponent_out;
reg [7:0] mantissa_out;
reg sign_out;
reg valid_out;
reg error_out;

reg [8:0] valore = 9'b110000000;
reg [26:0] aux_b;                        //dim a + dim b + dim c 
reg [17:0] aux_y;                        //dim a + dim b 
reg [17:0] aux_x;

reg [8:0] exponente_b, exponente_y, exponent_x;


always@(posedge clk)///////////////////////////////////////////////////////////////////////////////////////SERIAL BLOCK
    begin
        if(rst)
            begin 
                valid_out=1'b0;
                error_out=1'b0;
                counter=0;
                state=IDLE;
                B=0;
                x=0;
                y=0;
                Y=0;
            end    
        else
            begin 
                B<=Bnext;
                x<=xnext;
                Y<=Ynext;
                y<=ynext;
                state<=state_next;
                counter<=counter_next;
                mantissa_in<=mantissa_in_next;
                exponent_in<=exponent_in_next;
                sign_in<=sign_in_next;
            end
    end

always@(*) /////////////////////////////////////////////////////////////////////////////////////////// SEQUENTIAL BLOCK
    begin    
        Bnext=B;
        xnext=x;
        ynext=y;
        Ynext=Y;
        state_next=state;
        counter_next=counter;
        mantissa_in_next=mantissa_in;
        exponent_in_next=exponent_in;
        sign_in_next= sign_in;

        case (state)
            IDLE: //////////////////////////////////////////////////////////////////////////////////////--IDLE STATE
                begin   
                    if (sqrt_start)                
                        begin
                            mantissa_in_next={1'b1,num_i[6:0]};
                            exponent_in_next=num_i[14:7];
                            sign_in_next = num_i[15]; 
                                if (num_i[7]) 
                                    begin 
                                        Bnext={1'b0,mantissa_in_next};  // Se e` dispari 0.1M
                                        exponent_out=(exponent_in_next+1)>>1;
                                    end   
                                 else 
                                    begin 
                                        Bnext={mantissa_in_next,1'b0};  // Se e` pari 1.M0 
                                        exponent_out=exponent_in_next>>1;
                                    end        
                                        
                            Ynext=valore-(Bnext>>1); 
                            ynext=Ynext;                            
                            aux_x=(Bnext*Ynext);
                            
                            if (aux_x[17])
                                begin 
                                    xnext=aux_x[17:9];
                                    exponent_x=1;
                                end
                            else 
                                begin
                                    xnext=aux_x[16:8];
                                    exponent_x=0;
                                end
                            state_next=COMPUTATION;  
                         end
                  end
          
            COMPUTATION: ////////////////////////////////////////////////////////////////////////--COMPUTATION STATE
                begin 
                    if (sign_in) 
                        begin 
                            state_next=FINE; 
                            valid_out=1'b0;
                            error_out=1'b1; 
                        end        
                    else
                        begin
                            if (counter<=5)
                                begin 
                                    aux_b=B*Y*Y;               // risultato di 27 bit 3*9
                                    Bnext=aux_b[25:17];        // prendo i 9 bit piu` significativi 
                                            //+3 zeri
                                    Ynext=valore-(Bnext>>1);   // operazione su 9 bit;
                                            
                                    aux_x=x*Ynext;           // risultato in 18 bit
                                    xnext=aux_x[17:9];         // prendo i 9 piu` significativi 
                                            //+2 zeri
                                    aux_y=y*Ynext;           // risultato in 18 bit
                                    ynext=aux_y[17:9];         // prendo i 9 piu` significativi 
                                            //+ 2 zeri 
                                            
                                    counter_next=counter+1;
                                        if (counter==5) 
                                            begin 
                                                state_next=FINE;  
                                                mantissa_out=xnext;
                                                exponent_out=(exponent_in+1)>>1;
                                                sign_out=sign_in;
                                                valid_out=1'b1;
                                                error_out=1'b0;
                                            end
                                        end 
                                end
                         end
        
                FINE:   //////////////////////////////////////////////////////////////////////////////////-- FINAL STATE
                    begin 
                        state_next=IDLE;
                        valid_out=1'b0;
                        error_out=1'b0;
                        counter_next=0;
                        Bnext=0;
                        xnext=0;
                        ynext=0;    
                        Ynext=0;
                    end
        endcase
    end     

assign error_o=error_out;
assign valid_o=valid_out;
assign num_o ={sign_out, exponent_out, mantissa_out};

endmodule 
