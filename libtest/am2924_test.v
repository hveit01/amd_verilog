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

// am2924 1-of-8 decoder, same as 74ls138
`include "am2924.v"

module am2924_testbench;

reg a,b,c;
reg g1, g2a, g2b;

wire [7:0] y;
	
am2924 dut(
	.a		(a),
	.b		(b),
	.c		(c),
	.g1		(g1),
	.g2a_	(g2a),
	.g2b_	(g2b),
	.y		(y)
);

task tester;
	input [80*8-1:0] descr;
	input cval, bval, aval, g1val, g2aval, g2bval;
	begin
		a <= aval;
		b <= bval;
		c <= cval;
		g1 <= g1val;
		g2a <= g2aval;
		g2b <= g2bval;
		#1 $display("%5g: %1b %1b %1b  %1b  %1b   %1b   | %8b | %0s",
					$time,c,  b,  a,   g1,  g2a,  g2b,    y,    descr);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2924.vcd");
	$dumpvars;
	
$display("-time: c b a  g1 g2a g2b |    y     | description");
//                         -c-- -b-- -a-- -g1- -g2a -g2b
	tester("disable g1" ,  1'bx,1'bx,1'bx,1'b0,1'bx,1'bx);
	tester("disable g2a" , 1'bx,1'bx,1'bx,1'bx,1'b1,1'bx);
	tester("disable g2b" , 1'bx,1'bx,1'bx,1'bx,1'bx,1'b1);
	tester("y0 = low",     1'b0,1'b0,1'b0,1'b1,1'b0,1'b0);
	tester("y1 = low",     1'b0,1'b0,1'b1,1'b1,1'b0,1'b0);
	tester("y2 = low",     1'b0,1'b1,1'b0,1'b1,1'b0,1'b0);
	tester("y3 = low",     1'b0,1'b1,1'b1,1'b1,1'b0,1'b0);
	tester("y4 = low",     1'b1,1'b0,1'b0,1'b1,1'b0,1'b0);
	tester("y5 = low",     1'b1,1'b0,1'b1,1'b1,1'b0,1'b0);
	tester("y6 = low",     1'b1,1'b1,1'b0,1'b1,1'b0,1'b0);
	tester("y7 = low",     1'b1,1'b1,1'b1,1'b1,1'b0,1'b0);
	#10 $finish;
end
	
endmodule
