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

// test for am25ls2536

`include "am25ls2536.v"

module am25ls2536_test;

reg a,b,c;
reg pol;
reg oe, ce, clr, clk, g1, g2;

wire [7:0] y;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: cba pol ce g1 g2 oe clr cp | ---y---- | description");

`define SHOW(c,b,a, pol, ce, g1, g2, oe, clr, cp, y, descr)\
    $display("%5d: %b%b%b  %b   %b  %b  %b  %b  %b   %0s | %8b | %0s",\
             $time,c,b,a, pol,  ce, g1, g2, oe, clr, cp,   y,    descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input cval, bval, aval;
input polval, ceval, g1val, g2val, oeval, clrval;
input [7:0] expecty;
begin
    c <= cval; b <= bval; a <= aval;
    pol <= polval; ce <= ceval; g1 <= g1val; g2 <= g2val; oe <= oeval; clr <= clrval;
    #1 `SHOW(c,b,a, pol, ce, g1, g2, oe, clr, " ", y, descr);
    `assert("Y", y, expecty);
end
endtask

task clock;
input [80*8-1:0] descr;
input cval, bval, aval;
input polval, ceval, g1val, g2val, oeval, clrval;
input [7:0] expecty;
begin
    c <= cval; b <= bval; a <= aval;
    pol <= polval; ce <= ceval; g1 <= g1val; g2 <= g2val; oe <= oeval; clr <= clrval;
    
    clk <= 'b0;
    #1 ; // SHOW(c,b,a, pol, ce, g1, g2, oe, clr, " ", y, descr);
    clk <= 'b1;
    #1 `SHOW(c,b,a, pol, ce, g1, g2, oe, clr, "^", y, descr);
    clk <= 'b0;
    #1 ;
    `assert("Y", y, expecty);
end
endtask

am25ls2536 dut(.a(a), .b(b), .c(c),
               .ce_(ce), .g1_(g1), .g2(g2), .pol(pol), .oe_(oe), .clr_(clr),
               .clk(clk), 
               .y(y)
           );
           
initial begin

    //Dump results of the simulation to am25ls2536.vcd
    $dumpfile("am25ls2536.vcd");
    $dumpvars;

//         ------descr-------------------  -c- -b- -a- pol ce- -g1 -g2 -oe clr -expect_y--
`HEADER("");
    tester("Test OE=1, Y=tristate",        'bX,'bX,'bX,'bX,'bX,'bX,'bX,'b1,'bX,'bZZZZ_ZZZZ);
     clock("Disable by G1_, POL=0",        'bX,'bX,'bX,'b0,'b0,'b1,'bX,'b0,'b1,'b1111_1111);
     clock("Disable by G2, POL=0",         'bX,'bX,'bX,'b0,'b0,'bX,'b0,'b0,'b1,'b1111_1111);
     clock("Disabled, toggle Y by POL=1",  'bX,'bX,'bX,'b1,'b0,'b1,'b1,'b0,'b1,'b0000_0000);
    tester("Disabled, toggle POL by CLR",  'bX,'bX,'bX,'bX,'bX,'b0,'b0,'b0,'b0,'b1111_1111);
     clock("Select 0",                     'b0,'b0,'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1111_1110);
     clock("Select 1",                     'b0,'b0,'b1,'b0,'b0,'b0,'b1,'b0,'b1,'b1111_1101);
     clock("Select 2",                     'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1111_1011);
     clock("Select 3",                     'b0,'b1,'b1,'b0,'b0,'b0,'b1,'b0,'b1,'b1111_0111);
     clock("Select 4",                     'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1110_1111);
     clock("Select 5",                     'b1,'b0,'b1,'b0,'b0,'b0,'b1,'b0,'b1,'b1101_1111);
     clock("Select 6",                     'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1011_1111);
     clock("Select 7",                     'b1,'b1,'b1,'b0,'b0,'b0,'b1,'b0,'b1,'b0111_1111);
     clock("Select 7, POL=1",              'b1,'b1,'b1,'b1,'b0,'b0,'b1,'b0,'b1,'b1000_0000);
     clock("Disable Clock, Sel 7",         'bX,'bX,'bX,'bX,'b1,'b0,'b1,'b0,'b1,'b1000_0000);
    tester("Select 0 by CLR",              'bX,'bX,'bX,'bX,'bX,'b0,'b1,'b0,'b0,'b1111_1110);
     
end
endmodule
