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

// am74ls138 1-of-4 decoder
`include "am74ls139.v"

module am74ls139_testbench;

reg a,b;
reg g1;

wire [3:0] y;
	
am74ls139 dut(
	.a		(a),
	.b		(b),
	.g_		(g1),
	.y		(y)
);

task tester;
	input [80*8-1:0] descr;
	input bval, aval, g1val;
	begin
		a <= aval;
		b <= bval;
		g1 <= g1val;
		#1 $display("%5g: %1b %1b  %1b  | %4b | %0s",
					$time,b,  a,   g1,   y,    descr);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am74ls139.vcd");
	$dumpvars;
	
$display("-time: b a  g1 |  y   | description");
//                         -b-- -a-- -g1-
	tester("disable g1" ,  1'bx,1'bx,1'b1);
	tester("y0 = low",     1'b0,1'b0,1'b0);
	tester("y1 = low",     1'b0,1'b1,1'b0);
	tester("y2 = low",     1'b1,1'b0,1'b0);
	tester("y3 = low",     1'b1,1'b1,1'b0);
	#10 $finish;
end
	
endmodule
