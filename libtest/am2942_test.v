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

`include "am2942.v"

module am2942_test;
reg [3:0] i;
reg ien;
reg cp;
reg aci, wci;
reg oed;
reg [7:0] din;

wire aco, wco, done;
wire [7:0] d;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -i-- ien ---din-- aci wci oed cp | --dout-- aco wco don | description");

`define SHOW(i, ien, din, aci, wci, oed, cp, d, aco, wco, done, descr)\
    $display("%5d: %4b %3b %8b  %b   %b   %b   %0s | %8b  %b   %b   %b  | %0s",\
             $time,i,  ien,din, aci, wci, oed, cp,   d,   aco, wco, done, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [3:0] ival;
input ienval;
input [7:0] dinval;
input acival, wcival, oedval;
input [7:0] expectd;
input expectaco, expectwco, expectdone;
begin
    i <= ival;
	ien <= ienval;
    din <= dinval;
	aci <= acival; wci <= wcival; oed <= oedval;
    cp <= 'b0;
    #1 //`SHOW(i, ien, din, aci, wci, oed, " ", d, aco, wco, done, "");
    cp <= 'b1;
    #1 `SHOW(i, ien, din, aci, wci, oed, "^", d, aco, wco, done, descr);
    cp <= 'b0;
    #1 //`SHOW(i, ien, din, aci, wci, oed, " ", d, aco, wco, done, "");
    `assert("D", d, expectd);
    `assert("ACO", aco, expectaco);
    `assert("WCO", wco, expectwco);
    `assert("DONE", done, expectdone);
end
endtask

am2942 dut(.i(i), .ien_(ien), .d(d), 
           .aci_(aci), .wci_(wci), .oed_(oed),
           .cp(cp),
           .aco_(aco), .wco_(wco), .done(done)
          );
		  
assign d = din;

initial begin

    //Dump results of the simulation to am2942.vcd
    $dumpfile("am2942.vcd");
    $dumpvars;

//         ------descr------------------- --i--- ien ----din--- aci wci oed -expectd-- aco wco don
`HEADER("Tristate");
    tester("Tristate D",                  'bXXXX,'bX,'bZZZZZZZZ,'bX,'bX,'b1,'bZZZZZZZZ,'bX,'bX,'bX);
`HEADER("DMA R/W Control, Addr, Count");
    tester("Write CR",                    'b0000,'b0,'bXXXXX000,'bX,'bX,'b1,'bXXXXX000,'bX,'bX,'bX);
    tester("Read CR",                     'b0001,'b0,'bZZZZZZZZ,'bX,'bX,'b0,'b11111000,'bX,'bX,'bX);
    tester("Load AR",                     'b0101,'b0,'b10101010,'b1,'bX,'b1,'b10101010,'b1,'bX,'bX);
    tester("Read AR",                     'b0011,'b0,'bZZZZZZZZ,'b1,'bX,'b0,'b10101010,'b1,'bX,'bX);
    tester("Load WC",                     'b0110,'b0,'b00110011,'b1,'b1,'b1,'b00110011,'b1,'b1,'b0);
    tester("Read WC",                     'b0010,'b0,'bZZZZZZZZ,'b1,'b1,'b0,'b00110011,'b1,'b1,'b0);
`HEADER("DMA Mode 0, Incr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX000,'b1,'b1,'b1,'bXXXXX000,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WC",                     'b0110,'b0,'b00000011,'b1,'b1,'b1,'b00000011,'b1,'b1,'b0);
    tester("Hold  WC=3",                  'b0111,'b0,'bZZZZZZZZ,'b1,'b1,'b0,'b00001000,'b1,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001010,'b1,'b1,'b1);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001011,'b1,'b0,'b0);
    tester("Count WC=-1",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001100,'b1,'b1,'b0);
    tester("Reinitialize",                'b0100,'b0,'bZZZZZZZZ,'b1,'b1,'b0,'b00001000,'b1,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001010,'b1,'b1,'b1);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001011,'b1,'b0,'b0);
`HEADER("DMA Mode 0, Incr, Check ACO");
    tester("Load AR",                     'b0101,'b0,'b11111110,'b1,'b1,'b1,'b11111110,'b1,'b1,'b1);
    tester("Load WC",                     'b0110,'b0,'b00000011,'b1,'b1,'b1,'b00000011,'b1,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b11111111,'b0,'b1,'b0);
    tester("Count WC=1, DONE",            'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000000,'b1,'b1,'b1);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000001,'b1,'b0,'b0);
`HEADER("DMA Mode 0, Decr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX100,'b1,'b1,'b1,'bXXXXX100,'b1,'b1,'b1);
    tester("Load AR",                     'b0101,'b0,'b00000010,'b1,'b1,'b1,'b00000010,'b1,'b1,'b1);
    tester("Load WC",                     'b0110,'b0,'b00000011,'b1,'b1,'b1,'b00000011,'b1,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000001,'b1,'b1,'b0);
    tester("Count WC=1, DONE",            'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000000,'b0,'b1,'b1);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b11111111,'b1,'b0,'b0);
`HEADER("DMA Mode 1, Incr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX001,'b1,'b1,'b1,'bXXXXX001,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WCR, WC=0",              'b0110,'b0,'b00000011,'b1,'b1,'b1,'b00000011,'b1,'b1,'b0);
    tester("Count WC=1",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001010,'b1,'b1,'b1);
    tester("Count WC=3, DONE",            'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001011,'b1,'b1,'b0);
    tester("Hold  WC=3",                  'b0111,'b0,'bZZZZZZZZ,'b1,'b1,'b0,'b00001011,'b1,'b1,'b1);
    tester("Count WC=4",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001100,'b1,'b1,'b0);
`HEADER("DMA Mode 1, Decr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX101,'b1,'b1,'b1,'bXXXXX101,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WC",                     'b0110,'b0,'b00000011,'b1,'b1,'b1,'b00000011,'b1,'b1,'b0);
    tester("Count WC=1",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000111,'b1,'b1,'b0);
    tester("Count WC=2 DONE",             'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000110,'b1,'b1,'b1);
    tester("Count WC=3",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000101,'b1,'b1,'b0);
`HEADER("DMA Mode 2, Incr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX010,'b1,'b1,'b1,'bXXXXX010,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b0110,'b0,'b00001010,'b1,'b1,'b1,'b00001010,'b1,'b1,'b0);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
    tester("Count AC=WC",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001010,'b1,'b1,'b1);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001011,'b1,'b1,'b0);
`HEADER("DMA Mode 2, Decr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX110,'b1,'b1,'b1,'bXXXXX110,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b0110,'b0,'b00000101,'b1,'b1,'b1,'b00000101,'b1,'b1,'b0);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000111,'b1,'b1,'b0);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000110,'b1,'b1,'b0);
    tester("Count AC=WC",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000101,'b1,'b1,'b1);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000100,'b1,'b1,'b0);
    tester("Count",                       'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000011,'b1,'b1,'b0);
`HEADER("DMA Mode 3, Incr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX011,'b1,'b1,'b1,'bXXXXX011,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b0110,'b0,'b11111100,'b1,'b1,'b1,'b11111100,'b1,'b1,'b0);
    tester("Count WC=-3",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
    tester("Count WC=-2",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001010,'b1,'b1,'b0);
    tester("Count WC=-1",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001011,'b1,'b0,'b0);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001100,'b1,'b1,'b0);
    tester("Count WC=1",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001101,'b1,'b1,'b0);
`HEADER("DMA Mode 3, Decr");
    tester("Write CR",                    'b0000,'b0,'bXXXXX111,'b1,'b1,'b1,'bXXXXX111,'b1,'b1,'b0);
    tester("Load AR",                     'b0101,'b0,'b00001000,'b1,'b1,'b1,'b00001000,'b1,'b1,'b0);
    tester("Load WCR",                    'b0110,'b0,'b11111001,'b1,'b1,'b1,'b11111001,'b1,'b1,'b0);
    tester("Count WC=-6",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000111,'b1,'b1,'b0);
    tester("Count WC=-5",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000110,'b1,'b1,'b0);
    tester("Count WC=-4",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000101,'b1,'b1,'b0);
    tester("Count WC=-3",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000100,'b1,'b1,'b0);
    tester("Count WC=-2",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000011,'b1,'b1,'b0);
    tester("Count WC=-1",                 'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000010,'b1,'b0,'b0);
    tester("Count WC=0",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000001,'b1,'b1,'b0);
    tester("Count WC=1",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00000000,'b0,'b1,'b0);
    tester("Count WC=2",                  'b0111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b11111111,'b1,'b1,'b0);
    tester("Read WC",                     'b0010,'b0,'bZZZZZZZZ,'b1,'b1,'b0,'b00000010,'b1,'b1,'b0);
`HEADER("Read while IEN=1");
	tester("Read AC",                     'b0XXX,'b1,'bZZZZZZZZ,'b1,'b1,'b0,'b11111111,'b1,'b1,'b0);
	tester("Read WC",                     'b1XXX,'b1,'bZZZZZZZZ,'b1,'b1,'b0,'b00000010,'b1,'b1,'b0);
`HEADER("Timer functions");
	tester("Write TC while Count",        'b1000,'b0,'bXXXXX000,'b0,'b0,'b1,'bXXXXX000,'b1,'b1,'b0);
	tester("Read AC while Count",         'b0XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b11111111,'b0,'b1,'b0);
	tester("Read WC while Count",         'b1XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b00000001,'b1,'b1,'b1);
	tester("Reload AC while Count",       'b1001,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001000,'b1,'b0,'b0);
	tester("Read AC while Count",         'b1011,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
	tester("Read WC while Count",         'b1010,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b11111110,'b1,'b1,'b0);
	tester("Reload AC,WC while Count",    'b1100,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00001000,'b1,'b1,'b0);
	tester("Read AC while Count",         'b0XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b00001001,'b1,'b1,'b0);
	tester("Read WC while Count",         'b1XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b11110111,'b1,'b1,'b0);
	tester("Load AR while Count",         'b1101,'b0,'b10000000,'b0,'b0,'b1,'b10000000,'b1,'b1,'b0);
	tester("Read AC while Count",         'b0XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b10000001,'b1,'b1,'b0);
	tester("Load WC while Count",         'b1110,'b0,'b00100000,'b0,'b0,'b1,'b00100000,'b1,'b1,'b0);
	tester("Read AC while Count",         'b0XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b10000011,'b1,'b1,'b0);
	tester("Read WC while Count",         'b1XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b00011110,'b1,'b1,'b0);
	tester("Reload WC while Count",       'b1111,'b0,'bZZZZZZZZ,'b0,'b0,'b0,'b00100000,'b1,'b1,'b0);
	tester("Read AC while Count",         'b0XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b10000110,'b1,'b1,'b0);
	tester("Read WC while Count",         'b1XXX,'b1,'bZZZZZZZZ,'b0,'b0,'b0,'b00011110,'b1,'b1,'b0);
end

endmodule