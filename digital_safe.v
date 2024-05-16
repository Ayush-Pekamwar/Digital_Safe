`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engin
// 
// Create Date: 15.04.2023 21:29:33
// Design Name: 
// Module Name: digital_safe
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

module virtual_button(pulseclk,button,pulse);

input pulseclk;
input button;
reg prev_button_state,button_state;
output reg pulse;

always @(posedge pulseclk) 
begin
    prev_button_state <= button_state;
    button_state <= button;
    
    if (button_state && !prev_button_state) 
    begin
        pulse <= 1;
    end 
    else 
    begin
        pulse <= 0;
    end
end
endmodule

module BCD({A,B,C,D},bcd);
    input A,B,C,D;
    output [6:0]bcd;
    wire A1,B1,C1,D1;
    not(A1,A);
    not(B1,B);
    not(C1,C);
    not(D1,D);
    assign bcd[0]=~(C|A|(B1&D1)|(B&D));
    assign bcd[1]=~(A|B1|(C&D)|(C1&D1));
    assign bcd[2]=~(A|B|C1|D);
    assign bcd[3]=~((B1&D1)|(C&D1)|(B1&C)|(B&C1&D));
    assign bcd[4]=~((C&D1)|(B1&D1));
    assign bcd[5]=~(A|(B&C1)|(C1&D1)|(B&D1));
    assign bcd[6]=~(A|(B&C1)|(C&D1)|(B1&C));
endmodule


module digital_safe( virtual_numpad , virtual_back , virtual_enter , set_new_pass , virtual_reset , virtual_logout , sysclk , custom_clk , loggedin_led, ssd, loggedout_led , present_state , seto , locked_led,locked_led1 ,locked_led2,locked_led3,locked_led4, enable,  custom_state_display );

    input [9:0]virtual_numpad;
    input virtual_back , virtual_enter , set_new_pass , virtual_reset , virtual_logout;
    wire virtual_set;
    assign virtual_set=~set_new_pass;
    wire [9:0]numpad;
    wire back , enter , set , reset , lgout;
    output seto;
    assign seto = set;
    input sysclk;
    output reg loggedin_led = 1'b0;
    output reg loggedout_led = 1'b1;
    output reg locked_led = 1'b0;
    output reg locked_led1 = 1'b0;
    output reg locked_led2 = 1'b0;
    output reg locked_led3 = 1'b0;
    output reg locked_led4 = 1'b0;
//    output reg[6:0] tpseg1;
    output reg[6:0] custom_state_display= 7'b0000110;
//    output reg[6:0] tpseg1= 7'b1111111; 
//    output reg[6:0] tpseg2 = 7'b1111111; 

    output reg [3:0]enable=4'b1111;
    
    reg [3:0]pass1=4'b0000;
    reg [3:0]pass2=4'b0000;
    reg [3:0]pass3=4'b0000;
    reg [3:0]pass4=4'b0000;

    reg [3:0]entered_pass1=4'b0000;
    reg [3:0]entered_pass2=4'b0000;
    reg [3:0]entered_pass3=4'b0000;
    reg [3:0]entered_pass4=4'b0000;

    output reg custom_clk = 1'b1;

    parameter[3:0] init_state = 4'b0000 , logout = 4'b0001 , login = 4'b0010 , locked = 4'b0011;
    parameter[3:0] num1 = 4'b0100 , num2 = 4'b0101 , num3 = 4'b0110 , num4 = 4'b0111; 
    parameter[3:0] entered_num1 = 4'b1000 , entered_num2 = 4'b1001 , entered_num3 = 4'b1010 , entered_num4 = 4'b1011; 
    reg[25:0] count = 0;
    reg [1:0]incorrect_attempts = 2'b00;
    reg [31:0]locked_counter = 0; 
    
    reg[3:0]pass=4'b0000;
    output reg [6:0]ssd = 7'b0000000;
    wire [6:0]ssd1;
    wire [6:0]ssd2;
    wire [6:0]ssd3;
    wire [6:0]ssd4;

    wire [6:0]entered_ssd1;
    wire [6:0]entered_ssd2;
    wire [6:0]entered_ssd3;
    wire [6:0]entered_ssd4;

    BCD sd1(pass1,ssd1);
    BCD sd2(pass2,ssd2);
    BCD sd3(pass3,ssd3);
    BCD sd4(pass4,ssd4);
    
    BCD entered_sd1(entered_pass1,entered_ssd1);
    BCD entered_sd2(entered_pass2,entered_ssd2);
    BCD entered_sd3(entered_pass3,entered_ssd3);
    BCD entered_sd4(entered_pass4,entered_ssd4); 
    
    virtual_button v1(sysclk,virtual_numpad[0],numpad[0]);
    virtual_button v2(sysclk,virtual_numpad[1],numpad[1]);
    virtual_button v3(sysclk,virtual_numpad[2],numpad[2]);
    virtual_button v4(sysclk,virtual_numpad[3],numpad[3]);
    virtual_button v5(sysclk,virtual_numpad[4],numpad[4]);
    virtual_button v6(sysclk,virtual_numpad[5],numpad[5]);
    virtual_button v7(sysclk,virtual_numpad[6],numpad[6]);
    virtual_button v8(sysclk,virtual_numpad[7],numpad[7]);
    virtual_button v9(sysclk,virtual_numpad[8],numpad[8]);
    virtual_button v10(sysclk,virtual_numpad[9],numpad[9]);
    virtual_button v11(sysclk,virtual_enter,enter);
    virtual_button v12(sysclk,virtual_back,back);
    virtual_button v13(sysclk,virtual_logout,lgout);
    virtual_button v14(sysclk,virtual_set,set);
    virtual_button v15(sysclk,virtual_reset,reset);
    
    always@(posedge sysclk)
    begin
         if(count==26'b00000000111011100110101100 )
         begin
             custom_clk=~custom_clk;
             count=0;
         end
         else
         begin
             count=count+1;
         end
    end
    
    output reg [3:0]present_state = init_state;
    
    always @( posedge custom_clk )
    begin
        case(present_state)
//            init_state:
//            begin
//                enable<=4'b1111;
//            end
            init_state, num1, num2, num3, num4:
            begin
                case(enable)
                4'b1111:
                begin
                    enable<=4'b0111;
                    ssd<=ssd1;
                end
                4'b0111:
                begin
                    
                    enable<=4'b1011;
                    ssd<=ssd2;
                end
                4'b1011:
                begin
                    
                    enable<=4'b1101;
                    ssd<=ssd3;
                end
                4'b1101:
                begin
                    
                    enable<=4'b1110;
                    ssd<=ssd4;
                end
                4'b1110:
                begin
                    
                    enable<=4'b0111;
                    ssd <= ssd1;
                end
                endcase
            end
            
            entered_num1, entered_num2, entered_num3, entered_num4:
            begin
                case(enable)
                4'b1111:
                begin
                    enable<=4'b0111;
                    ssd<=entered_ssd1;
                end
                4'b0111:
                begin
                    
                    enable<=4'b1011;
                    ssd<=entered_ssd2;
                end
                4'b1011:
                begin
                    
                    enable<=4'b1101;
                    ssd<=entered_ssd3;
                end
                4'b1101:
                begin
                    
                    enable<=4'b1110;
                    ssd<=entered_ssd4;
                end
                4'b1110:
                begin
                    
                    enable<=4'b0111;
                    ssd <= entered_ssd1;
                end
                endcase
            end
            login, logout, locked:
            begin
                enable<=4'b1111;
            end
            
        endcase
    end
    
    always @( posedge sysclk )
    begin
        
        case(present_state)
        
        init_state:
        begin

        //Number entries    
        loggedin_led <= 1'b0;
        loggedout_led <= 1'b1;
        if (numpad[0]==1)
            begin
            present_state <=num1;
            pass1<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=num1;
            pass1<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=num1;
            pass1<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=num1;
            pass1<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=num1;
            pass1<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=num1;
            pass1<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=num1;
            pass1<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=num1;
            pass1<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=num1;
            pass1<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=num1;
            pass1<=4'b1001;
            end
             
        end
        
        num1:
        begin
   
        pass<=pass1;
//        if(back==1)
//            begin
//            present_state<=init_state;
//            pass1<=4'b0000;
//            end
        
        //Num1 Number entries    
         if (numpad[0]==1)
            begin
            present_state <=num2;
            pass2<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=num2;
            pass2<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=num2;
            pass2<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=num2;
            pass2<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=num2;
            pass2<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=num2;
            pass2<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=num2;
            pass2<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=num2;
            pass2<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=num2;
            pass2<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=num2;
            pass2<=4'b1001;
            end

        else if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end
        
        end
        
        num2:
        begin
     
        pass<=pass2;

//        if(back==1)
//            begin
//            present_state<=num1;
//            pass2=4'b0000;
//            end
        
        //Num2 Number entries    
        if (numpad[0]==1)
            begin
            present_state <=num3;
            pass3<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=num3;
            pass3<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=num3;
            pass3<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=num3;
            pass3<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=num3;
            pass3<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=num3;
            pass3<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=num3;
            pass3<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=num3;
            pass3<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=num3;
            pass3<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=num3;
            pass3<=4'b1001;
            end

        else if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end
        
        num3:
        begin
        
        pass<=pass3;

//        if(back==1)
//            begin
//            present_state<=num2;
//            pass3<=4'b0000;
//            end
        
        //Num3 Number entries    
        if (numpad[0]==1)
            begin
            present_state <=num4;
            pass4<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=num4;
            pass4<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=num4;
            pass4<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=num4;
            pass4<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=num4;
            pass4<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=num4;
            pass4<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=num4;
            pass4<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=num4;
            pass4<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=num4;
            pass4<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=num4;
            pass4<=4'b1001;
            end

        else if( reset == 1 )
            begin
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end
        
        num4:
        begin
        
        pass<=pass4;

//        if( back == 1 )
//            begin
//            present_state <= num3;
//            pass4 <= 4'b0000;
//            end

         if( enter == 1 )
            begin
            present_state <= login;
            end

        else if( reset == 1 )
            begin
            present_state <= init_state;
            pass1 <= 4'b0000;
            pass2 <= 4'b0000;
            pass3 <= 4'b0000;
            pass4 <= 4'b0000;
            end

        end

///////////////////////////////////////////////////////////////////////////////////////////////////

        logout:
        begin
        
        entered_pass1<=4'b0000;
        entered_pass2<=4'b0000;
        entered_pass3<=4'b0000;
        entered_pass4<=4'b0000;
        
        loggedin_led <= 1'b0;
        loggedout_led <= 1'b1;
        
        if(incorrect_attempts == 2'b11)
            begin
            present_state<=locked;
            end

        //Number entries    
        else if (numpad[0]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=entered_num1;
            entered_pass1<=4'b1001;
            end
        custom_state_display <= 7'b1000000;
        end

        entered_num1:
        begin
        
        pass<=entered_pass1;

//        if(back==1)
//            begin
//            present_state<=logout;
//            entered_pass1<=4'b0000;
//            end
        
        //Num1 Number entries    
        if (numpad[0]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=entered_num2;
            entered_pass2<=4'b1001;
            end

        else if( reset == 1 )
            begin
            present_state <= logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end
        
        end
        
        entered_num2:
        begin
        
        pass<=entered_pass2;

//        if(back==1)
//            begin
//            present_state<=entered_num1;
//            entered_pass2<=4'b0000;
//            end
        
        //Num2 Number entries    
         if (numpad[0]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=entered_num3;
            entered_pass3<=4'b1001;
            end

        else if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        entered_num3:
        begin
        
        pass<=entered_pass3;

//        if(back==1)
//            begin
//            present_state<=entered_num2;
//            entered_pass3<=4'b0000;
//            end
        
        //Num3 Number entries    
         if (numpad[0]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0000;
            end
            
        else if (numpad[1]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0001;
            end
            
        else if (numpad[2]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0010;
            end
            
        else if (numpad[3]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0011;
            end
        
        else if (numpad[4]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0100;
            end
            
        else if (numpad[5]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0101;
            end
            
        else if (numpad[6]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0110;
            end
        
        else if (numpad[7]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b0111;
            end
            
        else if (numpad[8]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b1000;
            end
            
        else if (numpad[9]==1)
            begin
            present_state <=entered_num4;
            entered_pass4<=4'b1001;
            end

        else if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        entered_num4:
        begin
        
        pass<=entered_pass4;

//        if( back == 1 )
//            begin
//            present_state <= entered_num3;
//            entered_pass4 <= 4'b0000;
//            end

         if( enter == 1 )
            begin
            if( pass1==entered_pass1 && pass2==entered_pass2 && pass3==entered_pass3 && pass4==entered_pass4  )
                begin
                present_state<=login;
                entered_pass1 <= 4'b0000;
                entered_pass2 <= 4'b0000;
                entered_pass3 <= 4'b0000;
                entered_pass4 <= 4'b0000;
                incorrect_attempts<=2'b00;
                end
            else
                begin
                present_state<=logout;
                incorrect_attempts <= incorrect_attempts+1;
                end

            end

        else if( reset == 1 )
            begin
            present_state<=logout;
            entered_pass1 <= 4'b0000;
            entered_pass2 <= 4'b0000;
            entered_pass3 <= 4'b0000;
            entered_pass4 <= 4'b0000;
            end

        end
        
        login:
        begin

        loggedout_led <= 1'b0;
        loggedin_led <= 1'b1;
        pass<=4'b1111;
        

        if( lgout == 1 )
            begin
            present_state <= logout;
            loggedin_led <= 1'b0;
            end

        else if( set == 1 )
            begin
            present_state <= init_state;
            end
        custom_state_display <= 7'b1101101;
        end
        
        locked:
        begin
        locked_led <= 1'b1;
        locked_led1 <= 1'b1;
        locked_led2 <= 1'b1;
        locked_led3 <= 1'b1;
        locked_led4 <= 1'b1;
        loggedout_led <= 1'b0;
        incorrect_attempts <= 2'b00;
//        tpseg1 <= 7'b1110001;
        custom_state_display <= 7'b1110001;
        end
        
        endcase
    end
    

endmodule