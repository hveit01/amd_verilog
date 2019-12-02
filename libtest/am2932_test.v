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

// am2932 testbench

`include "am2932.v"

module am2932_test;
reg [3:0] i;
reg [3:0] d;
reg re, cn, ci, oe, ien, cc;
reg cp;

wire [3:0] y;
wire empty, full, g, p, cn4, ci4;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -i-- -d-- oe cn ci cp | -y-- cn4 ci4 ful | description");

`define SHOW(i, d, oe, cn, ci, cp, y, cn4, ci4, full, descr)\
    $display("%5d: %4b %4b  %b  %b  %b  %0s | %4b  %b   %b   %b  | %0s",\
             $time,i,  d,   oe, cn, ci, cp,   y,   cn4, ci4, full, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [3:0] ival;
input [3:0] dval;
input oeval, cnval, cival;
input [3:0] expecty;
input expectcn4, expectci4, expectful;
input [4:0] expectsp;
input [3:0] expectpc, expectr;
begin
    i <= ival;
    d <= dval;
    oe <= oeval; cn <= cnval; ci <= cival;
    cp <= 'b0;
    #1 `SHOW(i, d, oe, cn, ci, " ", y, cn4, ci4, full, "");
        //$display("rmux=%4b rce=%b rsel=%b addout=%5b", dut.rmux, dut.rce, dut.rsel, dut.addout);
    `assert("Y", y, expecty);
    cp <= 'b1;
    #1 `SHOW(i, d, oe, cn, ci, "^", y, cn4, ci4, full, descr);
    `assert("CN4", cn4, expectcn4);
    `assert("CI4", ci4, expectci4);
    `assert("PC", dut.pc, expectpc);
    `assert("R", dut.r, expectr);
    cp <= 'b0;
    #1 `SHOW(i, d, oe, cn, ci, " ", y, cn4, ci4, full, "");
    `assert("FULL_", full, expectful);
    `assert("SP", dut.sp, expectsp);
end
endtask

am2932 dut(.i(i),
           .d(d),
           .oe_(oe), .cn(cn), .ci(ci),
           .cp(cp),
           .y(y), .cn4(cn4), .ci4(ci4),
           .full_(full)
          );

initial begin

    //Dump results of the simulation to am2930.vcd
    $dumpfile("am2930.vcd");
    $dumpvars;

//         ------descr------------------- --i--- ---d-- -oe -cn -ci ---y-- cn4 ci4 ful --sp--- --pc-- --r---
`HEADER("Fetch instructions");
    tester("Tristate OE",                 'bXXXX,'bXXXX,'b1,'bX,'bX,'bZZZZ,'bX,'bX,'bX,'bXXXXX,'bXXXX,'bXXXX);
    tester("Tristate PSUS",               'b0001,'bXXXX,'bX,'bX,'bX,'bZZZZ,'bX,'bX,'bX,'bXXXXX,'bXXXX,'bXXXX);
    tester("PRST: Reset",                 'b0000,'bXXXX,'b0,'bX,'b0,'b0000,'b0,'b0,'b1,'b00000,'b0000,'bXXXX);
    tester("PLDR: Load R",                'b1111,'b1010,'b0,'b0,'b1,'b0000,'b0,'b0,'b1,'b00000,'b0001,'b1010);
    tester("FPC: Fetch PC",               'b0100,'bXXXX,'b0,'bX,'b1,'b0001,'b0,'b0,'b1,'b00000,'b0010,'b1010);
    tester("FR: Fetch R",                 'b1000,'bXXXX,'b0,'bX,'b1,'b1010,'b0,'b0,'b1,'b00000,'b0011,'b1010);
    tester("FPR: Fetch PC+R+Cn",          'b1001,'bXXXX,'b0,'b0,'b1,'b1101,'b0,'b0,'b1,'b00000,'b0100,'b1010);
    tester("FPLR: Fetch PC -> R",         'b1010,'bXXXX,'b0,'b0,'b1,'b0100,'b0,'b0,'b1,'b00000,'b0101,'b0100);

`HEADER("Load/Push/Pop");
    tester("PLDR: Load R",                'b1111,'b0101,'b0,'b0,'b1,'b0101,'b0,'b0,'b1,'b00000,'b0110,'b0101);
    tester("PSHP: Push PC",               'b0110,'b0101,'b0,'b0,'b1,'b0110,'b0,'b0,'b1,'b00001,'b0111,'b0101);
    tester("PSHD: Push D",                'b0010,'b0000,'b0,'b0,'b1,'b0111,'b0,'b0,'b1,'b00010,'b1000,'b0101);
    tester("POPS: Pop S",                 'b0011,'bXXXX,'b0,'b0,'b1,'b0000,'b0,'b0,'b1,'b00001,'b1001,'b0101);

`HEADER("Jump instructions");
    tester("JMPR: Jump R",                'b1011,'bXXXX,'b0,'b0,'b0,'b0101,'b0,'b0,'b1,'b00001,'b0101,'b0101);
    tester("JMPD: Jump D",                'b0101,'b1110,'b0,'b0,'b1,'b1110,'b0,'b0,'b1,'b00001,'b1111,'b0101);
    tester("JPPR: Jump PC+R+Cn",          'b1100,'bXXXX,'b0,'b0,'b0,'b0100,'b0,'b0,'b1,'b00001,'b0100,'b0101);

`HEADER("JSB instructions");
    tester("JSBR: JSB R",                 'b1101,'bXXXX,'b0,'b0,'b1,'b0101,'b0,'b0,'b1,'b00010,'b0110,'b0101);
    tester("JSPR: JSB PC+R+Cn",           'b1110,'bXXXX,'b0,'b0,'b0,'b1011,'b1,'b0,'b1,'b00011,'b1011,'b0101);
    
`HEADER("RTS instructions");
    tester("RTS: Return S",               'b0111,'bXXXX,'b0,'b0,'b1,'b0110,'b0,'b0,'b1,'b00010,'b0111,'b0101);
`HEADER("Misc instructions");
    tester("PSUS: Suspend",               'b0001,'bXXXX,'b0,'b0,'b1,'bZZZZ,'b0,'b0,'b1,'b00010,'b0111,'b0101);
`HEADER("Fill stack");
    tester("SP=2, PSHD until full",       'b0010,'b0100,'b0,'b0,'b1,'b0111,'b0,'b0,'b1,'b00011,'b1000,'b0101);
    tester("SP=3",                        'b0010,'b0101,'b0,'b0,'b1,'b1000,'b0,'b0,'b1,'b00100,'b1001,'b0101);
    tester("SP=4",                        'b0010,'b0101,'b0,'b0,'b1,'b1001,'b0,'b0,'b1,'b00101,'b1010,'b0101);
    tester("SP=5",                        'b0010,'b0110,'b0,'b0,'b1,'b1010,'b0,'b0,'b1,'b00110,'b1011,'b0101);
    tester("SP=6",                        'b0010,'b0111,'b0,'b0,'b1,'b1011,'b0,'b0,'b1,'b00111,'b1100,'b0101);
    tester("SP=7",                        'b0010,'b1000,'b0,'b0,'b1,'b1100,'b0,'b0,'b1,'b01000,'b1101,'b0101);
    tester("SP=8",                        'b0010,'b1001,'b0,'b0,'b1,'b1101,'b0,'b0,'b1,'b01001,'b1110,'b0101);
    tester("SP=9",                        'b0010,'b1010,'b0,'b0,'b1,'b1110,'b0,'b1,'b1,'b01010,'b1111,'b0101);
    tester("SP=10",                       'b0010,'b1011,'b0,'b0,'b1,'b1111,'b0,'b0,'b1,'b01011,'b0000,'b0101);
    tester("SP=11",                       'b0010,'b1100,'b0,'b0,'b1,'b0000,'b0,'b0,'b1,'b01100,'b0001,'b0101);
    tester("SP=12",                       'b0010,'b1101,'b0,'b0,'b1,'b0001,'b0,'b0,'b1,'b01101,'b0010,'b0101);
    tester("SP=13",                       'b0010,'b1110,'b0,'b0,'b1,'b0010,'b0,'b0,'b1,'b01110,'b0011,'b0101);
    tester("SP=14",                       'b0010,'b1111,'b0,'b0,'b1,'b0011,'b0,'b0,'b1,'b01111,'b0100,'b0101);
    tester("SP=15",                       'b0010,'b0000,'b0,'b0,'b1,'b0100,'b0,'b0,'b1,'b10000,'b0101,'b0101);
    tester("SP=16",                       'b0010,'b0001,'b0,'b0,'b1,'b0101,'b0,'b0,'b0,'b10001,'b0110,'b0101);
    tester("SP=17, is now full",          'b0010,'b0010,'b0,'b0,'b1,'b0110,'b0,'b0,'b0,'b10001,'b0111,'b0101);
    tester("SP=17 remains",               'b0010,'b0011,'b0,'b0,'b1,'b0111,'b0,'b0,'b0,'b10001,'b1000,'b0101);
    tester("POPS: Pop S",                 'b0011,'bXXXX,'b0,'b0,'b1,'b0001,'b0,'b0,'b1,'b10000,'b1001,'b0101);
    tester("POPS: Pop S",                 'b0011,'bXXXX,'b0,'b0,'b1,'b0000,'b0,'b0,'b1,'b01111,'b1010,'b0101);
    tester("POPS: Pop S",                 'b0011,'bXXXX,'b0,'b0,'b1,'b1111,'b0,'b0,'b1,'b01110,'b1011,'b0101);
end
endmodule
