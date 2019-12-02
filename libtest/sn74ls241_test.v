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

// 74ls241 variable width noninverting tristate drivers
`include "sn74ls241.v"

module sn74ls244_testbench;
parameter WIDTH = 4;

reg [WIDTH-1:0] a1, a2;
reg g1_, g2;
wire [WIDTH-1:0] y1, y2;

sn74ls241 #(.WIDTH(WIDTH)) dut(
	.a1		(a1),
	.y1		(y1),
	.g1_	(g1_),
	.a2		(a2),
	.y2		(y2),
	.g2		(g2)
);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] a1val, a2val;
	input g1val, g2val;
	input [WIDTH-1:0] expecty1, expecty2;
	begin
		a1 <= a1val;
		a2 <= a2val;
		g1_ <= g1val;
		g2 <= g2val;

		#1 $display("%5g: %4b %4b  %1b   %1b | %4b %4b | %0s",
					$time, a1,a2,  g1_,  g2,   y1, y2,   descr);
					
		`assert("y1", y1, expecty1);
		`assert("y2", y2, expecty2);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("sn74ls244.vcd");
	$dumpvars;
	
$display("-time: -a1- -a2- g1_ g2 | -y1- -y2- | descr");

//                        --a1---  --a2---  -g1_- -g2-  -expy1-  -expy2-
	tester("tristate"   , 4'bxxxx, 4'bxxxx, 1'b1, 1'b0, 4'bzzzz, 4'bzzzz);
	tester("load 0's"   , 4'b0000, 4'bxxxx, 1'b0, 1'b0, 4'b0000, 4'bzzzz);
	tester("load 0's"   , 4'bxxxx, 4'b0000, 1'b1, 1'b1, 4'bzzzz, 4'b0000);
	tester("load 1's"   , 4'b1111, 4'bxxxx, 1'b0, 1'b0, 4'b1111, 4'bzzzz);
	tester("load 1's"   , 4'bxxxx, 4'b1111, 1'b1, 1'b1, 4'bzzzz, 4'b1111);
	tester("load 10's"  , 4'b1010, 4'b0101, 1'b0, 1'b1, 4'b1010, 4'b0101);
	#10 $finish;
end
	
endmodule
