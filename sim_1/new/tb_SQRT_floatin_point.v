`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: POLITECNICO DI MILANO
// Engineer(s): 
// (1) KOTSABA MYKHAYLO  <mykhaylo.kotsaba@mail.polimi.it>
// (2) MELACARNE ENRICO  <enrico.melacarne@mail.polimi.it>
// 
// Create Date: 03/31/2020 07:14:49 PM
// Design Name: 
// Module Name: tb_SQRT_floatin_point
// Project Name: SQRT_Floating_Point
// Target Devices: 
// Tool Versions: 
// Description: 
// We evaluate all the possible values in the mantissa for the INVSQRT and SQRT, the exponent is a random value
// The error value is saved at every iteration in the note.txt file 
// 
// Dependencies: 
// 
// Revision:
// Revision 1.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_SQRT_floatin_point(  );

    reg                     clk;
    reg                     rst;
    reg                     DoSqrt_i, DoInvSqrt_i;
    reg                     s_i;
    reg             [7:0]   m_i;
    reg   signed    [7:0]   e_i;
    wire                    s_o;
    wire            [7:0]   m_o;
    wire  signed    [7:0]   e_o;
    wire                    valid_o;
   
    real                    num_i,num_o,error;         // auxiliar parameters to see the mantissa input and output value in decimals and also the value of the error
    real                    error_e;                   // error exponent parameter, just to simplify the sintax in some cases
    integer fd;                                        // *FILE pointer to open in write mode a txt file in which we are going to save the data.
   
    always #5 clk=~clk;
    
    initial 
    begin
        fd = $fopen ("./note.txt", "w");   // Open the .txt file to save data
        if (fd)  $display("File was opened successfully \r\n");
        else     $display("File was NOT opened successfully \r\n",);
        m_i=64;
        clk<=0;
        DoInvSqrt_i=0;
        DoSqrt_i=0;
        rst=1;
        repeat(1) @(posedge clk);
        rst<=0;
    
        while(m_i<255)/////////////////////////////////////////////////////////////////////////////////////////////////////////////TESTING SQRT
        begin
            e_i=$random;
            s_i=1'b1;
            DoSqrt_i=1;
            repeat(1) @(posedge clk);
            DoSqrt_i=0;
            
            while ( !valid_o) begin repeat(1) @(posedge clk); end  // Wait untill the valid_o is '1'
            if(valid_o)
            begin
                num_i   = 1*m_i[7]+0.5*m_i[6]+0.25*m_i[5]+0.125*m_i[4]+0.0625*m_i[3]+0.03125*m_i[2]+0.014625*m_i[1]+0.0078125*m_i[0];  // Convert number in Decimals
                num_o   = 1*m_o[7]+0.5*m_o[6]+0.25*m_o[5]+0.125*m_o[4]+0.0625*m_o[3]+0.03125*m_o[2]+0.015625*m_o[1]+0.0078125*m_o[0];  // Convert number in Decimals
                error_e = -e_i+e_o+e_o;
                error   = num_i-((num_o*num_o)*2**error_e);
                $display("SQRT_TEST [%d] : Input = [%f] 2^[%d]|| Output = [%f] 2^[%d] || errore %f  ",m_i-64, num_i,e_i, num_o,e_o, error);  // Display the values of the test
                $fwrite(fd,"1 %f \n",error); // Saves the test data
            end
            m_i=m_i+1;
        end
        
        m_i=64;
        
        while(m_i<255)/////////////////////////////////////////////////////////////////////////////////////////////////////////////TESTING INV_SQRT
        begin
            e_i=$random;
            DoInvSqrt_i=1;
            repeat(1) @(posedge clk);
            DoInvSqrt_i=0;
            while ( !valid_o) begin repeat(1) @(posedge clk); end  // Wait untill the valid_o is '1'
            if(valid_o)
            begin
                num_i   = 1*m_i[7]+0.5*m_i[6]+0.25*m_i[5]+0.125*m_i[4]+0.0625*m_i[3]+0.03125*m_i[2]+0.014625*m_i[1]+0.0078125*m_i[0];
                num_o   = 1*m_o[7]+0.5*m_o[6]+0.25*m_o[5]+0.125*m_o[4]+0.0625*m_o[3]+0.03125*m_o[2]+0.015625*m_o[1]+0.0078125*m_o[0];
                error_e = -e_i-e_o-e_o;
                error   = num_i-(1/(num_o*num_o))*2**error_e;
                $display("INV_SQRT_TEST [%d] : Input = [%f] 2^[%d]|| Output = [%f] 2^[%d] || errore %f  ",m_i-64, num_i,e_i, num_o,e_o, error);
                $fwrite(fd,"2 %f \n",error);
            end
            m_i=m_i+1;
        
        end
        $fclose(fd);  //Close the .txt file
    end
    
    SQRT_Floating_Point SQRT_Floating_Point_0( .clk(clk), .rst(rst), .DoSqrt_i(DoSqrt_i), .DoInvSqrt_i(DoInvSqrt_i), .valid_o(valid_o), .s_i(s_i), .m_i(m_i), .e_i(e_i), .s_o(s_o), .m_o(m_o), .e_o(e_o)); 
endmodule
