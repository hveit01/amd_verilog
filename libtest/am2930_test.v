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

// am2930 testbench

`include "am2930.v"

module am2930_test;
reg [4:0] i;
reg [3:0] d;
reg re, cn, ci, oe, ien, cc;
reg cp;

wire [3:0] y;
wire empty, full, g, p, cn4, ci4;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: --i-- ien cc -d-- re oe cn ci cp | -y-- cn4 -g -p ci4 emp ful | description");

`define SHOW(i, ien, cc, d, re, oe, cn, ci, cp, y, cn4, g, p, ci4, empty, full, descr)\
    $display("%5d: %4b  %b   %b %4b  %b  %b  %b  %b  %0s | %4b  %b   %b  %b  %b   %b   %b  | %0s",\
             $time,i,   ien, cc,d,   re, oe, cn, ci, cp,   y,   cn4, g,  p,  ci4,empty,full, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [7:0] ival;
input ienval, ccval;
input [3:0] dval;
input reval, oeval, cnval, cival;
input [3:0] expecty;
input expectcn4, expectg, expectp, expectci4, expectemp, expectful;
input [4:0] expectsp;
input [3:0] expectpc, expectr;
begin
    i <= ival;
    ien <= ienval; cc <= ccval;
    d <= dval;
    re <= reval; oe <= oeval; cn <= cnval; ci <= cival;
    cp <= 'b0;
    #1 `SHOW(i, ien, cc, d, re, oe, cn, ci, " ", y, cn4, g, p, ci4, empty, full, "");
        //$display("rmux=%4b rce=%b rsel=%b addout=%5b", dut.rmux, dut.rce, dut.rsel, dut.addout);
    `assert("Y", y, expecty);
    `assert("CN4", cn4, expectcn4);
    `assert("G_", g, expectg);
    `assert("P_", p, expectp);
    cp <= 'b1;
    #1 `SHOW(i, ien, cc, d, re, oe, cn, ci, "^", y, cn4, g, p, ci4, empty, full, descr);
    `assert("CI4", ci4, expectci4);
    `assert("PC", dut.pc, expectpc);
    `assert("R", dut.r, expectr);
    cp <= 'b0;
    #1 `SHOW(i, ien, cc, d, re, oe, cn, ci, " ", y, cn4, g, p, ci4, empty, full, "");
    `assert("EMPTY_", empty, expectemp);
    `assert("FULL_", full, expectful);
    `assert("SP", dut.sp, expectsp);
end
endtask

am2930 dut(.i(i), .ien_(ien), .cc_(cc), 
           .d(d),
           .re_(re), .oe_(oe), .cn(cn), .ci(ci),
           .cp(cp),
           .y(y), .cn4(cn4), .g_(g), .p_(p), .ci4(ci4),
           .empty_(empty), .full_(full)
          );

initial begin

    //Dump results of the simulation to am2930.vcd
    $dumpfile("am2930.vcd");
    $dumpvars;

//         ------descr------------------- ---i--- ien -cc ---d-- -re -oe -cn -ci ---y-- cn4 -g- -p- ci4 emp ful --sp--- --pc-- --r---
`HEADER("Fetch instructions");
    tester("Tristate OE",                 'bXXXXX,'bX,'bX,'bXXXX,'bX,'b1,'bX,'bX,'bZZZZ,'bX,'bX,'bX,'bX,'bX,'bX,'bXXXXX,'bXXXX,'bXXXX);
    tester("Tristate PSUS",               'b11111,'b0,'bX,'bXXXX,'bX,'bX,'bX,'bX,'bZZZZ,'bX,'bX,'bX,'bX,'bX,'bX,'bXXXXX,'bXXXX,'bXXXX);
    tester("PRST: Reset",                 'b00000,'b0,'bX,'bXXXX,'b1,'b0,'bX,'b0,'b0000,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0000,'bXXXX);
    tester("Instr Disable, IEN=1",        'bXXXXX,'b1,'bX,'bXXXX,'bX,'b0,'bX,'b0,'b0000,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0000,'bXXXX);
    tester("PRST: Load R, RE=0",          'b00000,'b0,'bX,'b1010,'b0,'b0,'bX,'b0,'b0000,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0000,'b1010);
    tester("FPC: Fetch PC",               'b00001,'b0,'bX,'bXXXX,'b1,'b0,'bX,'b1,'b0000,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0001,'b1010);
    tester("FR: Fetch R",                 'b00010,'b0,'bX,'bXXXX,'b1,'b0,'bX,'b1,'b1010,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0010,'b1010);
    tester("FD: Fetch D",                 'b00011,'b0,'bX,'b1101,'b1,'b0,'bX,'b1,'b1101,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0011,'b1010);
    tester("FRD: Fetch R+D+Cn",           'b00100,'b0,'bX,'b0010,'b1,'b0,'b0,'b1,'b1100,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0100,'b1010);
    tester("FPD: Fetch PC+D+Cn",          'b00101,'b0,'bX,'b0001,'b1,'b0,'b0,'b1,'b0101,'b0,'b1,'b1,'b0,'b0,'b1,'b00000,'b0101,'b1010);
    tester("FPR: Fetch PC+R+Cn",          'b00110,'b0,'bX,'bXXXX,'b1,'b0,'b0,'b1,'b1111,'b0,'b1,'b0,'b0,'b0,'b1,'b00000,'b0110,'b1010);
    tester("PSHD: Push D",                'b01100,'b0,'bX,'b0011,'b1,'b0,'b0,'b1,'b0110,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0111,'b1010);
    tester("FSD: Fetch S+D+Cn",           'b00111,'b0,'bX,'b0010,'b1,'b0,'b0,'b1,'b0101,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1000,'b1010);
    tester("FPLR: Fetch PC -> R",         'b01000,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b1000,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1001,'b1000);
    tester("FRDR: Fetch R+D -> R",        'b01001,'b0,'bX,'b0010,'bX,'b0,'b0,'b1,'b1010,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1010,'b1010);

`HEADER("Load/Push/Pop");
    tester("PLDR: Load R",                'b01010,'b0,'bX,'b0101,'bX,'b0,'b0,'b1,'b1010,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1011,'b0101);
    tester("PSHP: Push PC",               'b01011,'b0,'bX,'b0101,'bX,'b0,'b0,'b1,'b1011,'b0,'b1,'b1,'b0,'b1,'b1,'b00010,'b1100,'b0101);
    tester("PSHD: Push D",                'b01100,'b0,'bX,'b0000,'bX,'b0,'b0,'b1,'b1100,'b0,'b1,'b1,'b0,'b1,'b1,'b00011,'b1101,'b0101);
    tester("POPS: Pop S",                 'b01101,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b00010,'b1110,'b0101);
    tester("POPP: Pop PC",                'b01110,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b1110,'b0,'b1,'b1,'b1,'b1,'b1,'b00001,'b1111,'b0101);
    tester("FSD: Fetch S",                'b00111,'b0,'bX,'b0000,'b1,'b0,'b0,'b1,'b0011,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0000,'b0101);
    tester("PHLD: Hold",                  'b01111,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0000,'b0101);

`HEADER("Jump instructions");
    tester("JMPR: Jump R, CC=1",          'b10000,'b0,'b1,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0001,'b0101);
    tester("JMPR: Jump R, CC=0",          'b10000,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0101,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0110,'b0101);
    tester("JMPD: Jump D",                'b10001,'b0,'b0,'b1110,'bX,'b0,'b0,'b1,'b1110,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1111,'b0101);
    tester("JMPZ: Jump 0",                'b10010,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0001,'b0101);
    tester("JPRD: Jump R+D+Cn",           'b10011,'b0,'b0,'b0001,'bX,'b0,'b0,'b1,'b0110,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b0111,'b0101);
    tester("JPPD: Jump PC+D+Cn",          'b10100,'b0,'b0,'b0010,'bX,'b0,'b0,'b1,'b1001,'b0,'b1,'b1,'b0,'b1,'b1,'b00001,'b1010,'b0101);
    tester("JPPR: Jump PC+R+Cn",          'b10101,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b1111,'b0,'b1,'b0,'b0,'b1,'b1,'b00001,'b0000,'b0101);

`HEADER("JSB instructions");
    tester("JSBR: JSB R",                'b10110,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0101,'b0,'b1,'b1,'b0,'b1,'b1,'b00010,'b0110,'b0101);
    tester("JSBD: JSB D",                'b10111,'b0,'b0,'b0100,'bX,'b0,'b0,'b1,'b0100,'b0,'b1,'b1,'b0,'b1,'b1,'b00011,'b0101,'b0101);
    tester("JSBZ: JSB 0",                'b11000,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b00100,'b0001,'b0101);
    tester("JSRD: JSB R+D+Cn",           'b11001,'b0,'b0,'b1100,'bX,'b0,'b0,'b1,'b0001,'b1,'b0,'b1,'b0,'b1,'b1,'b00101,'b0010,'b0101);
    tester("JSPD: JSB PC+D+Cn",          'b11010,'b0,'b0,'b0001,'bX,'b0,'b0,'b1,'b0011,'b0,'b1,'b1,'b0,'b1,'b1,'b00110,'b0100,'b0101);
    tester("JSPR: JSB PC+R+Cn",          'b11011,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b1001,'b0,'b1,'b1,'b1,'b1,'b1,'b00111,'b1010,'b0101);
    
`HEADER("RTS instructions");
    tester("RTS: Return S",              'b11100,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0100,'b0,'b1,'b1,'b0,'b1,'b1,'b00110,'b0101,'b0101);
    tester("RTSD: Return S+D+Cn",        'b11101,'b0,'b0,'b0001,'bX,'b0,'b0,'b1,'b0011,'b0,'b1,'b1,'b0,'b1,'b1,'b00101,'b0100,'b0101);

`HEADER("Misc instructions");
    tester("CHLD: Hold",                 'b11110,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'b0100,'b0,'b1,'b1,'b0,'b1,'b1,'b00101,'b0100,'b0101);
    tester("PSUS: Suspend",              'b11111,'b0,'b0,'bXXXX,'bX,'b0,'b0,'b1,'bZZZZ,'b0,'b1,'b1,'b0,'b1,'b1,'b00101,'b0100,'b0101);
`HEADER("Fill stack");
    tester("SP=5, PSHD until full",      'b01100,'b0,'b0,'b0110,'bX,'b0,'b0,'b1,'b0100,'b0,'b1,'b1,'b0,'b1,'b1,'b00110,'b0101,'b0101);
    tester("SP=6",                       'b01100,'b0,'b0,'b0111,'bX,'b0,'b0,'b1,'b0101,'b0,'b1,'b1,'b0,'b1,'b1,'b00111,'b0110,'b0101);
    tester("SP=7",                       'b01100,'b0,'b0,'b1000,'bX,'b0,'b0,'b1,'b0110,'b0,'b1,'b1,'b0,'b1,'b1,'b01000,'b0111,'b0101);
    tester("SP=8",                       'b01100,'b0,'b0,'b1001,'bX,'b0,'b0,'b1,'b0111,'b0,'b1,'b1,'b0,'b1,'b1,'b01001,'b1000,'b0101);
    tester("SP=9",                       'b01100,'b0,'b0,'b1010,'bX,'b0,'b0,'b1,'b1000,'b0,'b1,'b1,'b0,'b1,'b1,'b01010,'b1001,'b0101);
    tester("SP=10",                      'b01100,'b0,'b0,'b1011,'bX,'b0,'b0,'b1,'b1001,'b0,'b1,'b1,'b0,'b1,'b1,'b01011,'b1010,'b0101);
    tester("SP=11",                      'b01100,'b0,'b0,'b1100,'bX,'b0,'b0,'b1,'b1010,'b0,'b1,'b1,'b0,'b1,'b1,'b01100,'b1011,'b0101);
    tester("SP=12",                      'b01100,'b0,'b0,'b1101,'bX,'b0,'b0,'b1,'b1011,'b0,'b1,'b1,'b0,'b1,'b1,'b01101,'b1100,'b0101);
    tester("SP=13",                      'b01100,'b0,'b0,'b1110,'bX,'b0,'b0,'b1,'b1100,'b0,'b1,'b1,'b0,'b1,'b1,'b01110,'b1101,'b0101);
    tester("SP=14",                      'b01100,'b0,'b0,'b1111,'bX,'b0,'b0,'b1,'b1101,'b0,'b1,'b1,'b0,'b1,'b1,'b01111,'b1110,'b0101);
    tester("SP=15",                      'b01100,'b0,'b0,'b0000,'bX,'b0,'b0,'b1,'b1110,'b0,'b1,'b1,'b1,'b1,'b1,'b10000,'b1111,'b0101);
    tester("SP=16",                      'b01100,'b0,'b0,'b0001,'bX,'b0,'b0,'b1,'b1111,'b0,'b1,'b0,'b0,'b1,'b0,'b10001,'b0000,'b0101);
    tester("SP=17, is now full",         'b01100,'b0,'b0,'b0010,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b0,'b10001,'b0001,'b0101);
    tester("SP=17 remains",              'b01100,'b0,'b0,'b0011,'bX,'b0,'b0,'b1,'b0001,'b0,'b1,'b1,'b0,'b1,'b0,'b10001,'b0010,'b0101);
    tester("POPP: Pop PC",               'b01110,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b0010,'b0,'b1,'b1,'b0,'b1,'b1,'b10000,'b0011,'b0101);
    tester("POPP: Pop S",                'b01101,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b0000,'b0,'b1,'b1,'b0,'b1,'b1,'b01111,'b0100,'b0101);
    tester("POPP: Pop S",                'b01101,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b1111,'b0,'b1,'b0,'b0,'b1,'b1,'b01110,'b0101,'b0101);
    tester("POPP: Pop S",                'b01101,'b0,'bX,'bXXXX,'bX,'b0,'b0,'b1,'b1110,'b0,'b1,'b1,'b0,'b1,'b1,'b01101,'b0110,'b0101);
end
endmodule
