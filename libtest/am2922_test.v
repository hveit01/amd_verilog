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

// test for am2922

`include "am2922.v"

module am2922_test;

reg a,b,c;
reg pol;
reg [7:0] d;
reg me, oe, re, clr, clk;

wire y;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: ---d---- cba pol me re oe clr cp | y | description");

`define SHOW(d, c,b,a, pol, me, re, oe, clr, cp, y, descr)\
    $display("%5d: %8b %b%b%b  %b  %b  %b  %b   %b  %0s  | %b | %0s",\
             $time,d, c,b,a, pol, me, re, oe, clr, cp, y, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [7:0] dval;
input cval, bval, aval;
input polval, meval, reval, oeval, clrval;
input expecty;
begin
    d <= dval;
    c <= cval; b <= bval; a <= aval;
    pol <= polval; me <= meval; re <= reval; oe <= oeval; clr <= clrval;
    #1 `SHOW(d, c,b,a, pol, me, re, oe, clr, " ", y, descr);
    `assert("Y", y, expecty);
end
endtask

task clock;
input [80*8-1:0] descr;
input [7:0] dval;
input cval, bval, aval;
input polval, meval, reval, oeval, clrval;
input expecty;
begin
    d <= dval;
    c <= cval; b <= bval; a <= aval;
    pol <= polval; me <= meval; re <= reval; oe <= oeval; clr <= clrval;
    clk <= 'b0;
    #1 ; // `SHOW(d, c,b,a, pol, me, re, oe, clr, " ", y, descr);
    clk <= 'b1;
    #1 `SHOW(d, c,b,a, pol, me, re, oe, clr, "^", y, descr);
    clk <= 'b0;
    #1 ;
    `assert("Y", y, expecty);
end
endtask


am2922 dut(.d(d), .a(a), .b(b), .c(c),
           .me_(me), .re_(re), .pol(pol), .oe_(oe), .clr_(clr),
           .clk(clk), 
           .y(y)
          );
           
initial begin

    //Dump results of the simulation to am2922.vcd
    $dumpfile("am2922.vcd");
    $dumpvars;

//         ------descr-------------------  ----d----- -c- -b- -a- pol -me -re -oe clr expy
`HEADER("");
    tester("Test OE=1, Y=tristate",        'bXXXXXXXX,'bX,'bX,'bX,'bX,'bX,'bX,'b1,'bX,'bZ);
     clock("ME=1, toggle Y by POL=0",      'bXXXXXXXX,'bX,'bX,'bX,'b0,'b1,'b0,'b0,'bX,'b1);
     clock("ME=1, toggle Y by POL=1",      'bXXXXXXXX,'bX,'bX,'bX,'b1,'b1,'b0,'b0,'bX,'b0);
    tester("ME=1, toggle POL by CLR",      'bXXXXXXXX,'bX,'bX,'bX,'bX,'b1,'bX,'b0,'b0,'b1);
     clock("Select D0=0",                  'bXXXXXXX0,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D0=1",                  'bXXXXXXX1,'b0,'b0,'b0,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D1=0",                  'bXXXXXX0X,'b0,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D1=1",                  'bXXXXXX1X,'b0,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D2=0",                  'bXXXXX0XX,'b0,'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D2=1",                  'bXXXXX1XX,'b0,'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D3=0",                  'bXXXX0XXX,'b0,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D3=1",                  'bXXXX1XXX,'b0,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D4=0",                  'bXXX0XXXX,'b1,'b0,'b0,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D4=1",                  'bXXX1XXXX,'b1,'b0,'b0,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D5=0",                  'bXX0XXXXX,'b1,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D5=1",                  'bXX1XXXXX,'b1,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D6=0",                  'bX0XXXXXX,'b1,'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D6=1",                  'bX1XXXXXX,'b1,'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D7=0",                  'b0XXXXXXX,'b1,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0);
     clock("Select D7=1",                  'b1XXXXXXX,'b1,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b1);
     clock("Select D7=1, POL=1",           'b1XXXXXXX,'b1,'b1,'b1,'b1,'b0,'b0,'b0,'b1,'b0);
    tester("Select D0 by CLR",             'bXXXXXXX1,'bX,'bX,'bX,'bX,'b0,'bX,'b0,'b0,'b1);
     
end
endmodule
