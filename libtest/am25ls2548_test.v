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

// test for am25ls2548

`include "am25ls2548.v"

module am25ls2548_test;

reg a,b,c;
reg e1, e2, e3, e4;
reg rd, wr;

wire [7:0] y;
wire ack;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: cba e1 e2 e3 e3 rd wr  | ---y---- ack | description");

`define SHOW(c,b,a, e1, e2, e3, e4, rd,wr, y, ack, descr)\
    $display("%5d: %b%b%b  %b  %b  %b  %b  %b  %b  | %8b  %b  | %0s",\
             $time,c,b,a,  e1, e2, e3, e4, rd, wr,   y,   ack, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input cval, bval, aval;
input e1val, e2val, e3val, e4val, rdval, wrval;
input [7:0] expecty;
input expectack;
begin
    c <= cval; b <= bval; a <= aval;
    e1 <= e1val; e2 <= e2val; e3 <= e3val; e4 <= e4val; rd <= rdval; wr <= wrval;
    #1 `SHOW(c,b,a, e1, e2, e3, e4, rd, wr, y, ack, descr);
    `assert("Y", y, expecty);
    `assert("ACK_", ack, expectack);
end
endtask

am25ls2548 dut(.a(a), .b(b), .c(c),
               .e1_(e1), .e2_(e2), .e3(e3), .e4(e4), .rd_(rd), .wr_(wr),
               .y(y), .ack_(ack)
           );
           
initial begin

    //Dump results of the simulation to am25ls2548.vcd
    $dumpfile("am25ls2548.vcd");
    $dumpvars;

//         ------descr-------------------  -c- -b- -a- -e1 -e2 -e3 -e4 -rd -wr -expect_y-- eack
`HEADER("");
    tester("Disable by E1_",               'bX,'bX,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b1111_1111,'b1);
    tester("Disable by E2_",               'bX,'bX,'bX,'bX,'b1,'bX,'bX,'bX,'bX,'b1111_1111,'b1);
    tester("Disable by E3",                'bX,'bX,'bX,'bX,'bX,'b0,'bX,'bX,'bX,'b1111_1111,'b1);
    tester("Disable by E4",                'bX,'bX,'bX,'bX,'bX,'bX,'b0,'bX,'bX,'b1111_1111,'b1);
    tester("Select 0, no RD, WR",          'b0,'b0,'b0,'b0,'b0,'b1,'b1,'b1,'b1,'b1111_1110,'b1);
    tester("Select 0, RD",                 'b0,'b0,'b0,'b0,'b0,'b1,'b1,'b0,'bX,'b1111_1110,'b0);
    tester("Select 0, WR",                 'b0,'b0,'b0,'b0,'b0,'b1,'b1,'bX,'b0,'b1111_1110,'b0);
    tester("Select 1",                     'b0,'b0,'b1,'b0,'b0,'b1,'b1,'b1,'b1,'b1111_1101,'b1);
    tester("Select 2",                     'b0,'b1,'b0,'b0,'b0,'b1,'b1,'b1,'b1,'b1111_1011,'b1);
    tester("Select 3",                     'b0,'b1,'b1,'b0,'b0,'b1,'b1,'b1,'b1,'b1111_0111,'b1);
    tester("Select 4",                     'b1,'b0,'b0,'b0,'b0,'b1,'b1,'b1,'b1,'b1110_1111,'b1);
    tester("Select 5",                     'b1,'b0,'b1,'b0,'b0,'b1,'b1,'b1,'b1,'b1101_1111,'b1);
    tester("Select 6",                     'b1,'b1,'b0,'b0,'b0,'b1,'b1,'b1,'b1,'b1011_1111,'b1);
    tester("Select 7",                     'b1,'b1,'b1,'b0,'b0,'b1,'b1,'b1,'b1,'b0111_1111,'b1);
end
endmodule
