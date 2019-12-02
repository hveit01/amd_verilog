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

// am25ls153 4-line-to-1 dataselector / multiplexer
`include "am25ls153.v"

module am25ls153_testbench;

reg [1:0] sel;
reg g;
reg [3:0] c;

wire y;
	
am25ls153 dut(
	.sel	(sel),
	.g		(g),
	.c		(c),
	.y		(y)
);

task tester;
	input [80*8-1:0] descr;
	input [1:0] sval;
	input [3:0] cval;
	input gval;
	begin
		sel <= sval;
		c <= cval;
		g <= gval;
		#1 $display("%5g:  %2b    %4b   %1b  |  %1b  | %0s",
					$time, sel,   c,    g,      y,     descr);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am25ls153.vcd");
	$dumpvars;
	
$display("-time: -sel- --c--- -g- | -y- |");
//                                   --sel- ---c---  -g--
	tester("G disable"          , 2'bxx, 4'bxxxx, 1'b1);
	tester("SEL=0, C=L"         , 2'b00, 4'bxxx0, 1'b0);
	tester("SEL=0, C=H"         , 2'b00, 4'bxxx1, 1'b0);
	tester("SEL=1, C=L"         , 2'b01, 4'bxx0x, 1'b0);
	tester("SEL=1, C=H"         , 2'b01, 4'bxx1x, 1'b0);
	tester("SEL=2, C=L"         , 2'b10, 4'bx0xx, 1'b0);
	tester("SEL=2, C=H"         , 2'b10, 4'bx1xx, 1'b0);
	tester("SEL=3, C=L"         , 2'b11, 4'b0xxx, 1'b0);
	tester("SEL=3, C=H"         , 2'b11, 4'b1xxx, 1'b0);
	#10 $finish;
end
	
endmodule
