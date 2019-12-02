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

// test for am25ls191
// using WIDTH=4

`include "am25ls191.v"

module am25ls191_test;
parameter WIDTH=4;
reg [WIDTH-1:0] in;
reg load, ent, clk, ud;

wire [WIDTH-1:0] q;
wire mxmn, rco;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -in- load ent ud clk | -q-- mxmn rco | description");

`define SHOW(in, load, ent, ud, clk, q, mxmn, rco, descr)\
    $display("%5d: %4b  %b    %b   %b  %0s  | %4b  %b    %b  | %0s",\
             $time,in,  load, ent, ud, clk,  q,   mxmn, rco,  descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task setup;
input [80*8-1:0] descr;
input [WIDTH-1:0] inval;
input loadval, entval, udval;
input [WIDTH-1:0] expectq;
input expectmx, expectrco;
begin
    in <= inval;
    load <= loadval; ent <= entval; ud <= udval;
    clk <= 'b0;
    #1 clk <= 'b1;
    #1 clk <= 'b0;
//    #1 `SHOW(in, load, ent, ud, "^", q, mxmn, rco, descr);
    `assert("Q", q, expectq);
    `assert("MXMN", mxmn, expectmx);
    `assert("RCO", rco, expectrco);
end
endtask

task tester;
input [80*8-1:0] descr;
input [WIDTH-1:0] inval;
input loadval, entval, udval;
input [WIDTH-1:0] expectq;
input expectmx, expectrco;
begin
    in <= inval;
    load <= loadval; ent <= entval; ud <= udval;
    #1 clk <= 'b0;
    #1 `SHOW(in, load, ent, ud, " ", q, mxmn, rco, "");
    clk <= 'b1;
    #1 `SHOW(in, load, ent, ud, "^", q, mxmn, rco, descr);
    clk <= 'b0;
    #1 ; // `SHOW(in, load, ent, ud, " ", q, mxmn, rco, "");
    `assert("Q", q, expectq);
    `assert("MXMN", mxmn, expectmx);
    `assert("RCO", rco, expectrco);
end
endtask


am25ls191 #(.WIDTH(WIDTH)) dut(
            .in(in), .load_(load), .ent_(ent), .ud(ud),
            .clk(clk),
            .q(q), .mxmn(mxmn), .rco_(rco)
           );
           
initial begin

    //Dump results of the simulation to am25ls191.vcd
    $dumpfile("am25ls191.vcd");
    $dumpvars;

//         ------descr-------------------  --in-- load ent ud- exp_q_ emx erco
`HEADER("");
    tester("Load to 13",                   'b1101,'b0, 'b0,'b0,'b1101,'b0,'b1);
    tester("Count up (14)",                'bXXXX,'b1, 'b0,'b0,'b1110,'b0,'b1);
    tester("Count up (15)",                'bXXXX,'b1, 'b0,'b0,'b1111,'b1,'b0);
    tester("Count up (0)",                 'bXXXX,'b1, 'b0,'b0,'b0000,'b0,'b1);
    tester("Count up (1)",                 'bXXXX,'b1, 'b0,'b0,'b0001,'b0,'b1);
    tester("Count up (2)",                 'bXXXX,'b1, 'b0,'b0,'b0010,'b0,'b1);
    tester("Inhibit",                      'bXXXX,'b1, 'b1,'b0,'b0010,'b0,'b1);
    tester("Inhibit",                      'bXXXX,'b1, 'b1,'b0,'b0010,'b0,'b1);
    tester("Count down (1)",               'bXXXX,'b1, 'b0,'b1,'b0001,'b0,'b1);
    tester("Count down (0)",               'bXXXX,'b1, 'b0,'b1,'b0000,'b1,'b0);
    tester("Count down (15)",              'bXXXX,'b1, 'b0,'b1,'b1111,'b0,'b1);
    tester("Count down (14)",              'bXXXX,'b1, 'b0,'b1,'b1110,'b0,'b1);
    tester("Count down (13)",              'bXXXX,'b1, 'b0,'b1,'b1101,'b0,'b1);
end
endmodule
