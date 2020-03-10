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
// [x-] Moltiplicazione nel formato giusto;
// [  ] LUT for B_next_0;
// [x-] Mantissa output da definire;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module floating_point_sqrt(input clk, input rst, input sqrt_start, input [15:0] num_i, output [15:0] res_o, output error_o, output valid_o);

localparam IDLE=2'b00, COMPUTATION=2'b01, FINE=2'b10;

typedef struct {              // Struttura del Floating poin S|E|M
reg s;                  
reg [7:0] e;
reg [6:0] m;
} f_num;

f_num n_i, n_i_n;            // Input Register saver 
f_num n_o, n_o_n;            // Output register saver

logic [8:0] B,B_n;
logic [8:0] Y,Y_n;
logic [8:0] y,y_n;
logic [8:0] x,x_n;

logic [1:0] ss,ss_n;
logic [7:0] cnt,cnt_n;

logic valid_out, valid_out_n;
logic error_out;

logic [8:0] valore = 9'b110000000;
logic [26:0] aux_b;                        //dim a + dim b + dim c 
logic [17:0] aux_y;                        //dim a + dim b 
logic [17:0] aux_x;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               SERIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk)
    begin
        if(rst)
            begin 
                valid_out=1'b0;
                error_out=1'b0;
                cnt=0;
                ss=IDLE;
                B=0;
                x=0;
                y=0;
                Y=0;
            end    
        else
            begin 
                
                B<=B_n;
                x<=x_n;
                Y<=Y_n;
                y<=y_n;
                ss<=ss_n;
                cnt<=cnt_n;
                n_i<=n_i_n;
                n_o<=n_o_n;
                valid_out<=valid_out_n;
            end
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                            SEQUENTIAL BLOCK
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(*) 
    begin    
        B_n=B;       
        x_n=x;
        y_n=y;
        Y_n=Y;
        ss_n=ss;
        cnt_n=cnt;
        n_i_n.m=n_i.m;
        n_i_n.e=n_i.e;
        n_i_n.s= n_i.s;
        valid_out_n=1'b0;
        error_out=1'b0;
        n_o_n.s = n_i.s;
        

        case (ss)
            IDLE: //////////////////////////////////////////////////////////////////////////////////////--IDLE STATE
                begin   
                    if (sqrt_start)                
                        begin
                            n_i_n.m = num_i[6:0];
                            n_i_n.e = num_i[14:7];
                            n_i_n.s = num_i[15]; 
                            
                                if (num_i[7]) 
                                    begin 
                                        B_n={2'b01,n_i_n.m};  // Se e` dispari 0.1M
                                        n_o_n.e=(n_i_n.e+1)>>1;
                                        
                                    end   
                                 else 
                                    begin 
                                        B_n={1'b1,n_i_n.m,1'b0};  // Se e` pari 1.M0 
                                        n_o_n.e=(n_i_n.e)>>1;
                                    end        
                                        
                            Y_n=valore-(B_n>>1);                            // maybe a LUT
                            y_n=Y_n;       
                            aux_x=(B_n*Y_n);                                //Variabile ausiliaria per la moltiplicazione
                            x_n=aux_x[16:8];                      
                            ss_n=COMPUTATION;                               // Stato successivo COMPUTAZIONE
                         end
                  end
          
            COMPUTATION: ////////////////////////////////////////////////////////////////////////--COMPUTATION STATE
                begin 
                    if (n_i.s) 
                        begin 
                            ss_n=FINE;                // Se e` un numero negativo, esco, vado alla fine
                            error_out=1'b1;           // Segnalo l'errore
                        end        
                    else
                        begin
                            if (cnt<=5)
                                begin 
                                    aux_b=B*Y*Y;
                                    B_n=aux_b[24:16];        // prendo i 9 bit piu` significativi a partre da x.xxxx
                                    Y_n=valore-(B_n>>1);     // operazione su 9 bit;
                                            
                                    aux_x=x*Y_n;             // risultato in 18 bit
                                    x_n=aux_x[16:8];         // prendo i 9 piu` significativi 
                                            //+2 zeri
                                    aux_y=y*Y_n;             // risultato in 18 bit
                                    y_n=aux_y[16:8];         // prendo i 9 piu` significativi 
                                            //+ 2 zeri 
                                    cnt_n=cnt+1;
                                        if (cnt==5) 
                                            begin 
                                                valid_out_n = 1'b1;
                                                ss_n=FINE;  
                                                    casez(x_n)   // per usare il non care ? devi usare casez
                                                        9'b1????????: begin n_o_n.m = aux_x[15:9]; n_o_n.e = n_o.e;   end
                                                        9'b01???????: begin n_o_n.m = aux_x[14:8]; n_o_n.e = n_o.e-1; end
                                                        9'b001??????: begin n_o_n.m = aux_x[13:7]; n_o_n.e = n_o.e-2; end
                                                        9'b0001?????: begin n_o_n.m = aux_x[12:6]; n_o_n.e = n_o.e-3; end
                                                        9'b00001????: begin n_o_n.m = aux_x[11:5]; n_o_n.e = n_o.e-4; end
                                                        9'b000001???: begin n_o_n.m = aux_x[10:4]; n_o_n.e = n_o.e-5; end
                                                        9'b0000001??: begin n_o_n.m = aux_x[9:3];  n_o_n.e = n_o.e-6; end
                                                        9'b00000001?: begin n_o_n.m = aux_x[8:2];  n_o_n.e = n_o.e-7; end
                                                        9'b000000001: begin n_o_n.m = aux_x[7:1];  n_o_n.e = n_o.e-8; end
                                                        default: begin n_o_n.m=0; n_o_n.e=0; end
                                                    endcase 
                                            end
                                        end 
                                end
                         end
                
                FINE:   //////////////////////////////////////////////////////////////////////////////////-- FINAL STATE
                    begin 
                        ss_n=IDLE;
                        cnt_n=0;
                    end
        endcase
    end     

assign error_o=error_out;
assign valid_o=valid_out;
assign res_o = {n_o.s,n_o.e,n_o.m};

endmodule 
