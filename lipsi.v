`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 14:46:44
// Design Name: 
// Module Name: lipsi
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
//Clock Divider
module Clock_Divider(
    input clk,
    output reg clk_new,input reset
    );
    reg [25:0] count=1;
    //initial clk_new=1'b 0;
    always @(posedge clk or posedge reset)
    begin
    if(reset==1)
    begin
    count<=0;
    clk_new<=1'b 0;
    end
    else
    begin
    count<=count+1;
    if(count==50000000)
    begin
    clk_new<=~clk_new;
    count<=0;
    end
    end
    end
endmodule

//Clock Divider - 1k
module Clock_Divider_1(
    input clk,
    output reg clk_new,input reset
    );
    reg [25:0] count=1;
    //initial clk_new=1'b 0;
    always @(posedge clk or posedge reset)
    begin
    if(reset==1)
    begin
    count<=0;
    clk_new<=1'b 0;
    end
    else
    begin
    count<=count+1;
    if(count==50000)
    begin
    clk_new<=~clk_new;
    count<=0;
    end
    end
    end
endmodule

// Arithmetic Logic Unit
//module ALU(input [2:0]instr,input [7:0] accreg,input [7:0] data,output reg[7:0] res);
//localparam ADD=3'b000,SUB=3'b001,AND=3'b010,OR=3'b011,XOR=3'b100,LOAD=3'b111;
//always@(*)
//begin
//case(instr)
//ADD:res<=accreg+data;
//SUB:res<=accreg-data; // TO-DO Concatenate with carry
//AND:res<=accreg&data;
//OR:res<=accreg|data;
//XOR:res<=accreg^data;
//LOAD:res<=data; //TO-DO Add with Carry
//default:res<=data;
//endcase
//end
//endmodule

//Datapath
module Datapath(input clk,input reset,output reg [7:0]accreg,output reg [7:0]pc,output reg sana);
parameter ADD=3'b000,SUB=3'b001,AND=3'b100,OR=3'b101,XOR=3'b110,LOAD=3'b111,ADC=3'b010,SBB=3'b011;
parameter FETCH=4'b0000,STOREIND2=4'b0001,STOREIND1=4'b0010,LOADIND1=4'b0011,ALUOP=4'b0100,BRANCH2=4'b1101,DATA2=4'b1110,DATA3=4'b1111;
parameter BRLNK=4'b1100,STORE=4'b0101,BRANCH=4'b0110,ALUSHIFT=4'b0111,IO=4'b1000,EXIT=4'b1001,DATA=4'b1010,LOADIND2=4'b1011;
reg [7:0]mem[511:0];
wire [7:0] harsha;
initial
begin

// Sum of 15 Natural Numbers
mem[0]=8'b11000111;
mem[1]=8'b00001111;
mem[2]=8'b10000001;
mem[3]=8'b10000010;
mem[4]=8'b11000001;
mem[5]=8'b00000001;
mem[6]=8'b10000001;
mem[7]=8'b00000010;
mem[8]=8'b10000010;
mem[9]=8'b01110001;
mem[10]=8'b11010011;
mem[11]=8'b00000100;
mem[12]=8'b01110010;
mem[13]=8'b11111111;

/*
// Triangle Numbers
mem[9'b100000101]=8'b00000101;
mem[0]=8'b01110101;
mem[1]=8'b10000001;
mem[2]=8'b10000010;
mem[3]=8'b11000001;
mem[4]=8'b00000001;
mem[5]=8'b10000001;
mem[6]=8'b00000010;
mem[7]=8'b10000010;
mem[8]=8'b01110001;
mem[9]=8'b11010011;
mem[10]=8'b00000011;
mem[11]=8'b01110010;
mem[12]=8'b01110101;
mem[13]=8'b11000001;
mem[14]=8'b00000001;
mem[15]=8'b10000101;
mem[16]=8'b11010011;
mem[17]=8'b00000000;
mem[18]=8'b11111111;
*/
/*
// 2-Powers
mem[256]=8'b00000000;
mem[257]=8'b00000001;
mem[0]=8'b01110000;
mem[1]=8'b01110001;
mem[2]=8'b10000010;
mem[3]=8'b00000010;
mem[4]=8'b11010011;
mem[5]=8'b00000010;
mem[6]=8'b11111111;
*/
//$readmemb("mem_file",mem);
end
assign harsha=mem[2];
reg [7:0]temp1,temp2,temp4,out;
reg enaaccreg,updatepc;
//assign temp1=mem[257];
//assign temp2=mem[258];
//assign temp4=mem[428];
reg [7:0] instr;
reg [7:0]data;
reg [3:0] state;
reg [2:0] funcreg;
//reg enaaccreg;
reg enapcreg;
reg enaioreg;
//reg updatepc;
reg [8:0] rdaddr;
reg [8:0] wraddr;
reg wrena;
reg dataen;
//reg [7:0] out;
//reg [7:0] pc;
reg [7:0] temp3;
reg [7:0] temp5;
//reg [7:0] temppc;
reg [7:0] temp6;
reg carry_out;
/*
initial 
begin
state<=FETCH;
enaaccreg=1'b0;
enapcreg=1'b0;
enaioreg=1'b0;
//updatepc=1'b1;
pc=8'b00000000;
wrena=1'b0;
sana=1'b0;
dataen=1'b1;
end
*/
always@(*)
begin
instr<=mem[{1'b0,pc}];
end

always@(posedge clk or posedge reset)
begin
if(reset==1'b1)
begin
pc<=8'b00000000;
accreg<=8'b00000000;
state<=FETCH;
enaaccreg<=1'b0;
enapcreg<=1'b0;
enaioreg<=1'b0;
sana<=1'b0;
dataen<=1'b1;
wrena<=1'b0;
updatepc<=1'b0;
carry_out=1'b0;
// Our's
/*
// mem[256]=8'b00000101;
mem[9'b100000000]=8'b00000111;
mem[9'b100001111]=8'b10101111;
mem[9'b110101111]=8'b00001111;
mem[9'b100000011]=8'b10101100;
mem[9'b100000110]=8'b01000101;
mem[9'b100000101]=8'b00010010;
//mem[9'b000000000]=8'b01110000;
mem[9'b000000000]=8'b01110000;
mem[9'b000000001]=8'b10000001;
mem[9'b000000010]=8'b10010010;
mem[9'b000001000]=8'b10101111;
mem[9'b000001001]=8'b10110011;
mem[9'b000001010]=8'b11011100;
mem[9'b000001011]=8'b00001111;
mem[9'b000001111]=8'b11010011;
mem[9'b000010000]=8'b00010100;
mem[9'b000010100]=8'b11000001;
mem[9'b000010101]=8'b00001111;
mem[9'b000010110]=8'b11010110;
mem[9'b000010111]=8'b00011110;
mem[9'b000011110]=8'b00000110;
mem[9'b000011111]=8'b11101100;
mem[9'b000100000]=8'b11101101;
mem[9'b000100001]=8'b11101110;
mem[9'b000100010]=8'b11101111;
mem[9'b000100011]=8'b11110101;
mem[9'b000100100]=8'b11111111;
//mem[9'b000010000]=8'b00001111;
//mem[9'b000010001]=8'b11111111;
*/

//Anna's

end
else 
begin
if(enaaccreg==1'b0)
accreg<=accreg;
//pc<=temppc;
$display("State: %b",state);
case(state)
FETCH:
begin
//updatepc<=1'b1;
//enaaccreg<=1'b0;
$display("updatepc: %b",updatepc);
$display("pc: %b",pc);
if(instr[7]==1'b0)
begin
state<=ALUOP;
funcreg<=instr[6:4];
pc<=pc;
enaaccreg<=1'b1;
if(dataen)
data<=mem[{5'b10000,instr[3:0]}];
end
if(instr[7:4]==4'b1000)
begin
 //enaaccreg<=1'b1;
 mem[{5'b10000,instr[3:0]}]<=accreg;
 pc<=pc;
 state<=STORE;
end
if(instr[7:4]==4'b1001)
begin
   // mem[{5'b10000,instr[3:0]}]<=pc;
    temp6<=pc;
    pc<=accreg;
   // pc<=pc;
state<=BRLNK;
end
if(instr[7:4]==4'b1010)
begin
    enaaccreg<=1'b1;
   // accreg<=mem[{1'b1,mem[{5'b10000,instr[3:0]}]}];
    temp3<=mem[{5'b10000,instr[3:0]}];
    pc<=pc;
    state<=LOADIND1;
end
if(instr[7:4]==4'b1011)
begin
    enaaccreg<=1;
   pc<=pc;
    mem[{1'b1,mem[{5'b10000,instr[3:0]}]}]<=accreg;
    state<=STOREIND1;
end
if(instr[7:4]==4'b1100)
begin
    enaaccreg<=1'b1;
    funcreg<=instr[2:0];
    state<=DATA2;
    pc<=pc;
end
if(instr[7:4]==4'b1101)
begin
pc<=pc;
funcreg<=instr[2:0];
state<=BRANCH2;
end
if(instr[7:4]==4'b1110)
begin
    enaaccreg<=1'b1;
    pc<=pc;
    funcreg<=instr[2:0];
    state<=ALUSHIFT;
end
if(instr[7:4]==4'b1111)
begin
enaaccreg<=1'b1;
pc<=pc;
temp5<=mem[{5'b10000,instr[3:0]}];
state<=IO;
end
if(instr[7:0]==8'b11111111)
begin
state<=EXIT;
end
end
ALUOP:
begin
   // ALU a0(funcreg,accreg,data,accreg);    // Changed
    case(funcreg)
ADD:{carry_out,accreg}<=accreg+data;
SUB:{carry_out,accreg}<=accreg-data; 
AND:accreg<=accreg&data;
OR:accreg<=accreg|data;
XOR:accreg<=accreg^data;
LOAD:accreg<=data; 
ADC:{carry_out,accreg}<=accreg+data+carry_out;
SBB:{carry_out,accreg}<=accreg-data-carry_out;
default:accreg<=data;
endcase
    state<=FETCH;
    enaaccreg<=1'b0;
    pc<=(pc+1);
end
STORE:
begin
    pc<=(pc+1);
    state<=FETCH;
end
LOADIND1:
begin
state<=LOADIND2;
accreg<=mem[{1'b1,temp3}];
//enaaccreg<=1'b0;
pc<=pc;
end
LOADIND2:
begin
    pc<=(pc+1);
    enaaccreg<=1'b0;
    state<=FETCH;
end
STOREIND1:
begin
state<=STOREIND2;
pc<=pc;
end
STOREIND2:
begin
     pc<=(pc+1);
    enaaccreg<=1'b0;
    state<=FETCH;
end
DATA2:
begin
 pc<=(pc+1);
//enaaccreg<=1'b1;
state<=DATA;
end
DATA3:
begin
 pc<=(pc+1);
state<=FETCH;
end
DATA:
begin
   // ALU(funcreg,accreg,mem[{1'b0,pc}],accreg);  //Changed
    case(funcreg)
ADD:{carry_out,accreg}<=accreg+mem[{1'b0,pc}];
SUB:{carry_out,accreg}<=accreg-mem[{1'b0,pc}]; 
AND:accreg<=accreg&mem[{1'b0,pc}];
OR:accreg<=accreg|mem[{1'b0,pc}];
XOR:accreg<=accreg^mem[{1'b0,pc}];
LOAD:accreg<=mem[{1'b0,pc}]; 
ADC:{carry_out,accreg}<=accreg+mem[{1'b0,pc}]+carry_out;
SBB:{carry_out,accreg}<=accreg-mem[{1'b0,pc}]-carry_out;
default:accreg<=mem[{1'b0,pc}];
endcase
    enaaccreg<=1'b0;
    pc<=pc;  
    state<=DATA3;
end
BRLNK:
begin
mem[{5'b10000,instr[3:0]}]<=temp6;
 // pc<=accreg;
state<=FETCH;
 pc<=(pc+1);
end
IO:
begin
    out<=accreg;
    accreg<=temp5;
     pc<=(pc+1);
    enaaccreg<=1'b0;
    state<=FETCH; 
end
EXIT:
begin
   
    pc<=pc;
    state<=EXIT;
    enaaccreg<=1'b0;
    sana<=1'b1;
end 
ALUSHIFT:
begin
     pc<=(pc+1);
    case(funcreg)
    3'b000,3'b100:accreg<=(accreg<<1);
    3'b001,3'b101:accreg<=(accreg>>1);
    3'b010,3'b110:accreg<={accreg[6:0],accreg[7]};
    3'b011,3'b111:accreg<={accreg[0],accreg[7:1]};
    default:accreg<=accreg;
    endcase
    enaaccreg<=1'b0;
    state<=FETCH;
end
BRANCH2:
begin
 pc<=(pc+1);
state<=BRANCH;
end
BRANCH:
begin
 pc<=(pc+1);
case(funcreg)
3'b000,3'b100:pc<=instr[7:0];
3'b010,3'b110:
begin
if(accreg==8'b00000000)
pc<=instr[7:0];
end
3'b011,3'b111:
begin
if(accreg!=8'b00000000)
pc<=instr[7:0];
end
default:pc<=pc;
endcase
state<=FETCH;
end
endcase
end
end

//always@(updatepc)
//begin
//if(updatepc==1'b1)
//temppc<=(temppc+1);
//else 
//temppc<=temppc;
//end

//always@(posedge clk)
//begin

//end

//always@(posedge reset)
//begin

//end
endmodule



//module lipsi();
//endmodule
//LIPSI Top

module lipsi(input clk,input reset,output reg [6:0]seg,output reg [3:0] an,output sana);
reg [3:0] digit;
reg count;
initial begin
count<=1'b0;
end
wire [7:0]pc,accreg;
//wire sana;
//wire t1,t2;
wire t2;
Clock_Divider c1(clk,t1,reset);
Clock_Divider_1 c2(clk,t2,reset);
Datapath D1(t1,reset,accreg,pc,sana);
always@(posedge t2)
begin
if(count==1'b0)
begin
an=4'b1110;
digit=accreg[3:0];
count=~count;
end
else 
begin
an=4'b1101;
digit=accreg[7:4];
count=~count;
end
end

always@(*)
begin
case(digit)
4'b0000: seg=7'b1000000;
4'b0001: seg=7'b1111001;
4'b0010: seg=7'b0100100;
4'b0011: seg=7'b0110000;
4'b0100: seg=7'b0011001;
4'b0101: seg=7'b0010010;
4'b0110: seg=7'b0000010;
4'b0111: seg=7'b1111000;
4'b1000: seg=7'b0000000;
4'b1001: seg=7'b0010000;
4'b1010: seg=7'b0001000;
4'b1011: seg=7'b0000011;
4'b1100: seg=7'b1000110;
4'b1101: seg=7'b0100001;
4'b1110: seg=7'b0000110;
4'b1111: seg=7'b0001110;
endcase
end


endmodule

