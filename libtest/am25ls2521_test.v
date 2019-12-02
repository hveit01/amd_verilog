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

// test for am25ls2521
// using parameter WIDTH=8

`include "am25ls2521.v"

module am25ls2521_test;
parameter WIDTH=8;
reg [WIDTH-1:0] a, b;
reg ein;

wire eout;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: ---a---- ---b---- ein | eout | description");

`define SHOW(a, b, ein, eout, descr)\
    $display("%5d: %8b %8b  %b  |  %b  | %0s",\
             $time, a, b, ein, eout, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [WIDTH-1:0] aval, bval;
input einval;
input expecteout;
begin
    a <= aval; b <= bval;
    ein <= einval;
    #1 `SHOW(a, b, ein, eout, descr);
    `assert("EOUT", eout, expecteout);
end
endtask

am25ls2521 #(.WIDTH(WIDTH)) dut(.a(a), .b(b), 
               .ein_(ein),
               .eout_(eout)
           );
           
initial begin

    //Dump results of the simulation to am25ls2521.vcd
    $dumpfile("am25ls2521.vcd");
    $dumpvars;

//         ------descr-------------------  ----a----- ----b----- ein expo
`HEADER("");
    tester("Test EIN=1",                   'bXXXXXXXX,'bXXXXXXXX,'b1,'b1);
    tester("Test EQUAL all 0",             'b00000000,'b00000000,'b0,'b0);
    tester("Test EQUAL all 1",             'b11111111,'b11111111,'b0,'b0);
    tester("Test EQUAL checker",           'b11001100,'b11001100,'b0,'b0);
    tester("Test EQUAL alternate",         'b01010101,'b01010101,'b0,'b0);
    tester("Test NOT EQUAL Bit0",          'bXXXXXXX0,'bXXXXXXX1,'b0,'b1);
    tester("Test NOT EQUAL Bit1",          'bXXXXXX0X,'bXXXXXX1X,'b0,'b1);
    tester("Test NOT EQUAL Bit2",          'bXXXXX0XX,'bXXXXX1XX,'b0,'b1);
    tester("Test NOT EQUAL Bit3",          'bXXXX0XXX,'bXXXX1XXX,'b0,'b1);
    tester("Test NOT EQUAL Bit4",          'bXXX1XXXX,'bXXX0XXXX,'b0,'b1);
    tester("Test NOT EQUAL Bit5",          'bXX1XXXXX,'bXX0XXXXX,'b0,'b1);
    tester("Test NOT EQUAL Bit6",          'bX1XXXXXX,'bX0XXXXXX,'b0,'b1);
    tester("Test NOT EQUAL Bit7",          'b1XXXXXXX,'b0XXXXXXX,'b0,'b1);
     
end
endmodule
