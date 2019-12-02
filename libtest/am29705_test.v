// This code is part of the model collection of AM29xx Bitslice devices
// Copyright (C) 2019  Holger Veit (hveit01@web.de)
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 3 of the License, or (at
//    your option) any later version.
//
//    This program is distributed in the hope that it will be useful, but
//    WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//    General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, see <http://www.gnu.org/licenses/>.
//
//

// test for am29705

`include "am29705.v"

module am29705_test;

reg [3:0] a, b;
reg [3:0] d;
reg we1, we2, le, alo, oea, oeb;
wire [3:0] ya, yb;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -a-- -b-- -d-- we1 we2 le alo oea oeb | -ya- -yb- | description");

`define SHOW(a, b, d, we1, we2, le, alo, oea, oeb, ya, yb, descr)\
    $display("%5d: %4b %4b %4b  %b   %b   %b  %b   %b   %b  | %4b %4b | %0s",\
             $time,a,  b,  d,   we1, we2,le,  alo, oea, oeb,  ya, yb,   descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task setup;
input [80*8-1:0] descr;
input [3:0] aval, bval, dval;
input we1val, we2val, leval, aloval, oeaval, oebval;
input [3:0] expectya, expectyb;
begin
    a <= aval; b <= bval; d <= dval;
    we1 <= we1val; we2 <= we2val; le <= leval; alo <= aloval;
    oea <= oeaval; oeb <= oebval;

    #1 ;
//    `SHOW(a, b, d, we1, we2, le, alo, oea, oeb, ya, yb, descr);
    `assert("YA", ya, expectya);
    `assert("YB", yb, expectyb);
end
endtask

task tester;
input [80*8-1:0] descr;
input [3:0] aval, bval, dval;
input we1val, we2val, leval, aloval, oeaval, oebval;
input [3:0] expectya, expectyb;
begin
    a <= aval; b <= bval; d <= dval;
    we1 <= we1val; we2 <= we2val; le <= leval; alo <= aloval;
    oea <= oeaval; oeb <= oebval;

    #1 `SHOW(a, b, d, we1, we2, le, alo, oea, oeb, ya, yb, descr);
    `assert("YA", ya, expectya);
    `assert("YB", yb, expectyb);
end
endtask

am29705 dut(.a(a), .b(b), .d(d),
            .we1_(we1), .we2_(we2), .le_(le),
            .alo_(alo), .oea_(oea), .oeb_(oeb),
            .ya(ya), .yb(yb)
           );
           
initial begin

    //Dump results of the simulation to am29705.vcd
    $dumpfile("am29705.vcd");
    $dumpvars;

//         ------descr------------------- ---a-- ---b-- ---d-- we1 we2 le- alo oea oeb exp-ya exp-yb
`HEADER("");
     setup("Write RAM[0] = 15",            'bXXXX,'b0000,'b1111,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[1] = 14",            'bXXXX,'b0001,'b1110,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[2] = 13",            'bXXXX,'b0010,'b1101,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[3] = 12",            'bXXXX,'b0011,'b1100,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[4] = 11",            'bXXXX,'b0100,'b1011,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[5] = 10",            'bXXXX,'b0101,'b1010,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[6] = 9",             'bXXXX,'b0110,'b1001,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[7] = 8",             'bXXXX,'b0111,'b1000,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[8] = 7",             'bXXXX,'b1000,'b0111,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[9] = 6",             'bXXXX,'b1001,'b0110,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[10] = 5",            'bXXXX,'b1010,'b0101,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[11] = 4",            'bXXXX,'b1011,'b0100,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[12] = 3",            'bXXXX,'b1100,'b0011,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[13] = 2",            'bXXXX,'b1101,'b0010,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[14] = 1",            'bXXXX,'b1110,'b0001,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
     setup("Write RAM[15] = 0",            'bXXXX,'b1111,'b0000,'b0,'b0,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
    tester("Check OEA=OEB=1",              'bXXXX,'bXXXX,'bXXXX,'bX,'b1,'bX,'bX,'b1,'b1,'bZZZZ,'bZZZZ);
    tester("Read RAM[0] via A",            'b0000,'bXXXX,'bXXXX,'b1,'bX,'b1,'b1,'b0,'b1,'b1111,'bZZZZ);
    tester("Read RAM[1] via B",            'bXXXX,'b0001,'bXXXX,'b1,'bX,'b1,'bX,'b1,'b0,'bZZZZ,'b1110);
    tester("Read RAM[13,8] via A,B",       'b1101,'b1000,'bXXXX,'b1,'bX,'b1,'b1,'b0,'b0,'b0010,'b0111);
    tester("Latch RAM[13,8]",              'b1101,'b1000,'bXXXX,'b1,'bX,'b0,'b1,'b0,'b0,'b0010,'b0111);
    tester("Read RAM[2,3] while Latch",    'b0010,'b0011,'bXXXX,'b1,'bX,'b0,'b1,'b0,'b0,'b0010,'b0111);
    tester("Force YA=0 while Latch",       'bXXXX,'b0011,'bXXXX,'b1,'bX,'b0,'b0,'b0,'b0,'b0000,'b0111);
    tester("Write RAM[4] = 4 while Latch", 'bXXXX,'b0100,'b0100,'b0,'b0,'b0,'b1,'b0,'b0,'b0010,'b0111);
    tester("Read RAM[4] via B",            'bXXXX,'b0100,'bXXXX,'bX,'b1,'b1,'bX,'b1,'b0,'bZZZZ,'b0100);
    tester("Write RAM[4] = 4, Read RAM[6]",'b0110,'b0100,'b0100,'b0,'b0,'b1,'b1,'b0,'b0,'b1001,'b0100);
end
endmodule
