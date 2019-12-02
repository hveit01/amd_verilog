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

// am2913 testbench

`include "am2913.v"

module am2913_test;
reg [7:0] i;
reg ei;
reg g1, g2, g3, g4, g5;

wire [2:0] a;
wire eo;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: ---i---- ei g1 g2 g3 g4 g5 | -a- eo | description");

`define SHOW(i, ei, g1, g2, g3, g4, g5, a, eo, descr)\
    $display("%5d: %8b  %b  %b  %b  %b  %b  %b | %3b  %b | %0s",\
             $time,i,   ei, g1, g2, g3, g4, g5,  a,   eo,  descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [7:0] ival;
input eival, g1val, g2val, g3val, g4val, g5val;
input [2:0] expecta;
input expecteo;
begin
    i <= ival;
    ei <= eival;
    g1 <= g1val; g2 <= g2val; g3 <= g3val; g4 <= g4val; g5 <= g5val;
    #1 `SHOW(i, ei, g1, g2 ,g3, g4, g5, a, eo, descr);
    `assert("A", a, expecta);
    `assert("EO_", eo, expecteo);
end
endtask

am2913 dut(.i_(i), .ei_(ei),
           .g1(g1), .g2(g2), .g3_(g3), .g4_(g4), .g5_(g5),
           .a(a), .eo_(eo)
          );

initial begin

    //Dump results of the simulation to am2913.vcd
    $dumpfile("am2913.vcd");
    $dumpvars;

//         ------descr------------------- ----i----- -ei -g1 -g2 -g3 -g4 -g5 exp_a exp_eo
`HEADER("");
    tester("Tristate G1",                 'bXXXXXXXX,'bX,'b0,'bX,'bX,'bX,'bX,'bZZZ,'bX);
    tester("Tristate G2",                 'bXXXXXXXX,'b1,'bX,'b0,'bX,'bX,'bX,'bZZZ,'b1);
    tester("Tristate G3_",                'bXXXXXXXX,'b1,'bX,'bX,'b1,'bX,'bX,'bZZZ,'b1);
    tester("Tristate G4_",                'bXXXXXXXX,'b1,'bX,'bX,'bX,'b1,'bX,'bZZZ,'b1);
    tester("Tristate G5_",                'bXXXXXXXX,'b1,'bX,'bX,'bX,'bX,'b1,'bZZZ,'b1);
    tester("EI=1",                        'bXXXXXXXX,'b1,'b1,'b1,'b0,'b0,'b0,'b000,'b1);
    tester("EI=0, I = all 1",             'b11111111,'b0,'b1,'b1,'b0,'b0,'b0,'b000,'b0);
    tester("EI=0, I7=0",                  'b0XXXXXXX,'b0,'b1,'b1,'b0,'b0,'b0,'b111,'b1);
    tester("EI=0, I6=0",                  'b10XXXXXX,'b0,'b1,'b1,'b0,'b0,'b0,'b110,'b1);
    tester("EI=0, I5=0",                  'b110XXXXX,'b0,'b1,'b1,'b0,'b0,'b0,'b101,'b1);
    tester("EI=0, I4=0",                  'b1110XXXX,'b0,'b1,'b1,'b0,'b0,'b0,'b100,'b1);
    tester("EI=0, I3=0",                  'b11110XXX,'b0,'b1,'b1,'b0,'b0,'b0,'b011,'b1);
    tester("EI=0, I2=0",                  'b111110XX,'b0,'b1,'b1,'b0,'b0,'b0,'b010,'b1);
    tester("EI=0, I1=0",                  'b1111110X,'b0,'b1,'b1,'b0,'b0,'b0,'b001,'b1);
    tester("EI=0, I0=0",                  'b11111110,'b0,'b1,'b1,'b0,'b0,'b0,'b000,'b1);
end
endmodule
