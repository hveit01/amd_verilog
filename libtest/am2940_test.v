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

// am2940 testbench

`include "am2940.v"

module am2940_test;
reg [2:0] i;
reg cp;
reg aci, wci;
reg oea;
reg [7:0] din;

wire [7:0] a;
wire aco, wco, done;
wire [7:0] d;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -i- ---din-- aci wci oea cp | ---a---- --dout-- aco wco don | description");

`define SHOW(i, din, aci, wci, oea, cp, a, d, aco, wco, done, descr)\
    $display("%5d: %3b %8b  %b   %b   %b   %0s | %8b %8b  %b   %b   %b  | %0s",\
             $time,i,  din, aci, wci, oea, cp,   a,  d,   aco, wco, done, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [2:0] ival;
input [7:0] dinval;
input acival, wcival, oeaval;
input [7:0] expecta, expectd;
input expectaco, expectwco, expectdone;
begin
    i <= ival;
    din <= dinval;
	aci <= acival; wci <= wcival; oea <= oeaval;
    cp <= 'b0;
    #1 //`SHOW(i, din, aci, wci, oea, " ", a, d, aco, wco, done, "");
    cp <= 'b1;
    #1 `SHOW(i, din, aci, wci, oea, "^", a, d, aco, wco, done, descr);
    cp <= 'b0;
    #1 //`SHOW(i, din, aci, wci, oea, " ", a, d, aco, wco, done, "");
    `assert("A", a, expecta);
    `assert("D", d, expectd);
    `assert("ACO", aco, expectaco);
    `assert("WCO", wco, expectwco);
    `assert("DONE", done, expectdone);
end
endtask

am2940 dut(.i(i), .a(a), .d(d), 
           .aci_(aci), .wci_(wci), .oea_(oea),
           .cp(cp),
           .aco_(aco), .wco_(wco), .done(done)
          );
		  
assign d = din;

initial begin

    //Dump results of the simulation to am2940.vcd
    $dumpfile("am2940.vcd");
    $dumpvars;

//         ------descr------------------- --i-- ----din--- aci wci oea -expecta-- -expectd-- aco wco don
`HEADER("Tristate");
    tester("Tristate A",                  'bXXX,'bXXXXXXXX,'bX,'bX,'b1,'bZZZZZZZZ,'bXXXXXXXX,'bX,'bX,'bX);
`HEADER("R/W Control, Addr, Count");
    tester("Write CR",                    'b000,'bXXXXX000,'bX,'bX,'b0,'bXXXXXXXX,'bXXXXX000,'bX,'bX,'bX);
    tester("Read CR",                     'b001,'bZZZZZZZZ,'bX,'bX,'b0,'bXXXXXXXX,'b11111000,'bX,'bX,'bX);
    tester("Load AR",                     'b101,'b10101010,'b1,'bX,'b0,'b10101010,'b10101010,'b1,'bX,'bX);
    tester("Read AR",                     'b011,'bZZZZZZZZ,'b1,'bX,'b1,'bZZZZZZZZ,'b10101010,'b1,'bX,'bX);
    tester("Load WC",                     'b110,'b00110011,'b1,'b1,'b0,'b10101010,'b00110011,'b1,'b1,'b0);
    tester("Read WC",                     'b010,'bZZZZZZZZ,'b1,'b1,'b0,'b10101010,'b00110011,'b1,'b1,'b0);
`HEADER("Mode 0, Incr");
    tester("Write CR",                    'b000,'bXXXXX000,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX000,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WC",                     'b110,'b00000011,'b1,'b1,'b0,'b00001000,'b00000011,'b1,'b1,'b0);
    tester("Hold  WC=3",                  'b111,'bXXXXXXXX,'b1,'b1,'b0,'b00001000,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001010,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001011,'bXXXXXXXX,'b1,'b0,'b0);
    tester("Count WC=-1",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001100,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Reinitialize",                'b100,'bXXXXXXXX,'b1,'b1,'b0,'b00001000,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001010,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001011,'bXXXXXXXX,'b1,'b0,'b0);
`HEADER("Mode 0, Incr, Check ACO");
    tester("Load AR",                     'b101,'b11111110,'b1,'b1,'b1,'bZZZZZZZZ,'b11111110,'b1,'b1,'b1);
    tester("Load WC",                     'b110,'b00000011,'b1,'b1,'b0,'b11111110,'b00000011,'b1,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b11111111,'bXXXXXXXX,'b0,'b1,'b0);
    tester("Count WC=1, DONE",            'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000000,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000001,'bXXXXXXXX,'b1,'b0,'b0);
`HEADER("Mode 0, Decr");
    tester("Write CR",                    'b000,'bXXXXX100,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX100,'b1,'b1,'b1);
    tester("Load AR",                     'b101,'b00000010,'b1,'b1,'b0,'b00000010,'b00000010,'b1,'b1,'b1);
    tester("Load WC",                     'b110,'b00000011,'b1,'b1,'b0,'b00000010,'b00000011,'b1,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000000,'bXXXXXXXX,'b0,'b1,'b1);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b11111111,'bXXXXXXXX,'b1,'b0,'b0);
`HEADER("Mode 1, Incr");
    tester("Write CR",                    'b000,'bXXXXX001,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX001,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WCR, WC=0",              'b110,'b00000011,'b1,'b1,'b0,'b00001000,'b00000011,'b1,'b1,'b0);
    tester("Count WC=1",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001010,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=3, DONE",            'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001011,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Hold  WC=3",                  'b111,'bXXXXXXXX,'b1,'b1,'b0,'b00001011,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=4",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001100,'bXXXXXXXX,'b1,'b1,'b0);
`HEADER("Mode 1, Decr");
    tester("Write CR",                    'b000,'bXXXXX101,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX101,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WC",                     'b110,'b00000011,'b1,'b1,'b0,'b00001000,'b00000011,'b1,'b1,'b0);
    tester("Count WC=1",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000111,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=2 DONE",             'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000110,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count WC=3",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000101,'bXXXXXXXX,'b1,'b1,'b0);
`HEADER("Mode 2, Incr");
    tester("Write CR",                    'b000,'bXXXXX010,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX010,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b110,'b00001010,'b1,'b1,'b0,'b00001000,'b00001010,'b1,'b1,'b0);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count AC=WC",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001010,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001011,'bXXXXXXXX,'b1,'b1,'b0);
`HEADER("Mode 2, Decr");
    tester("Write CR",                    'b000,'bXXXXX110,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX110,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b110,'b00000101,'b1,'b1,'b0,'b00001000,'b00000101,'b1,'b1,'b0);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000111,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000110,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count AC=WC",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000101,'bXXXXXXXX,'b1,'b1,'b1);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000100,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count",                       'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000011,'bXXXXXXXX,'b1,'b1,'b0);
`HEADER("Mode 3, Incr");
    tester("Write CR",                    'b000,'bXXXXX011,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX011,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b110,'b11111100,'b1,'b1,'b0,'b00001000,'b11111100,'b1,'b1,'b0);
    tester("Count WC=-3",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-2",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001010,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-1",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001011,'bXXXXXXXX,'b1,'b0,'b0);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001100,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=1",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00001101,'bXXXXXXXX,'b1,'b1,'b0);
`HEADER("Mode 3, Decr");
    tester("Write CR",                    'b000,'bXXXXX111,'b1,'b1,'b1,'bZZZZZZZZ,'bXXXXX111,'b1,'b1,'b0);
    tester("Load AR",                     'b101,'b00001000,'b1,'b1,'b0,'b00001000,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b110,'b11111001,'b1,'b1,'b0,'b00001000,'b11111001,'b1,'b1,'b0);
    tester("Count WC=-6",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000111,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-5",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000110,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-4",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000101,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-3",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000100,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-2",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000011,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=-1",                 'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000010,'bXXXXXXXX,'b1,'b0,'b0);
    tester("Count WC=0",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000001,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Count WC=1",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b00000000,'bXXXXXXXX,'b0,'b1,'b0);
    tester("Count WC=2",                  'b111,'bXXXXXXXX,'b0,'b0,'b0,'b11111111,'bXXXXXXXX,'b1,'b1,'b0);
    tester("Read WC",                     'b010,'bZZZZZZZZ,'b1,'b1,'b0,'b11111111,'b00000010,'b1,'b1,'b0);
end

endmodule