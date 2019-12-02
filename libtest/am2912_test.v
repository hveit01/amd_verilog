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

// test for am2912
// uses parameter WIDTH=4



`include "am2912.v"

module am2912_test;
parameter WIDTH=4;
reg [WIDTH-1:0] i;
reg e;

genvar n;

wire [WIDTH-1:0] b, z;
wire [WIDTH-1:0] bprobe;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -i-- -e | -b-- -bp- -z-- | description");

`define SHOW(i, e, b, bprobe, z, descr)\
    $display("%5d: %4b  %b | %4b %4b %4b | %0s",\
             $time,i,   e,   b,  bprobe,z, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [WIDTH-1:0] ival;
input eval;
input [WIDTH-1:0] expectb, expectp, expectz;
begin
    i <= ival;
    e <= eval;
    #1 `SHOW(i, e, b, bprobe, z, descr);
    `assert("B_", b, expectb);
    `assert("B_ (Recv input)", bprobe, expectp);
    `assert("Z", z, expectz);
end
endtask

am2912 dut(.i(i), .e_(e),
           .b_(b), .z(z)
          );

// Emulation of open collector. Note that the am2912.v will only drive bus down to 'b0.
// A 'b1 results in the bus be 'bZ.
// The receiver part will behave like an open TTL input, i.e. it will assume a 'b1 on the bus, unless it is 'b0.
// 
for (n=0; n<WIDTH; n=n+1) begin
  assign bprobe[n] = (b[n]==='b0) ? 'b0 : 'b1;
end
           
initial begin

    //Dump results of the simulation to am2912.vcd
    $dumpfile("am2912.vcd");
    $dumpvars;

//         ------descr------------------- --i--- -e- -ex_b- -ex_p- -ex_z-
`HEADER("BP is what the bus receiver reads from the bus (TTL compatible)");
    tester("Disabled",                    'bXXXX,'b1,'bZZZZ,'b1111,'b0000);
    tester("All 0",                       'b0000,'b0,'bZZZZ,'b1111,'b0000);
    tester("All 1",                       'b1111,'b0,'b0000,'b0000,'b1111);
    tester("Checker",                     'b0011,'b0,'bZZ00,'b1100,'b0011);
    tester("Alternate",                   'b1010,'b0,'b0Z0Z,'b0101,'b1010);
    
end
endmodule
