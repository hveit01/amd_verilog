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

// am74ls251 8-to-1 multiplexer with tri-state
`include "am74ls251.v"

module am74ls251_testbench;

reg [7:0] d;
reg a,b,c, s_;

wire y, w_;
	
am74ls251 dut(
	.d		(d),
	.a		(a),
	.b		(b),
	.c		(c),
	.s_		(s_),
	.y		(y),
	.w_		(w_)
);

task tester;
	input [80*8-1:0] descr;
	input [7:0] dval;
	input cval, bval, aval, sval;
	begin
		d <= dval;
		a <= aval;
		b <= bval;
		c <= cval;
		s_ <= sval;
		#1 $display("%5g: %8b %1b %1b %1b %1b  | %1b %1b  | %0s",
					$time,d,  a,  b,  c,  s_,    y,  w_,   descr);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am74ls251.vcd");
	$dumpvars;
	
$display("-time: ---d---- c b a s_ | y w_ | description");
//                         ---d----- --c-- --b-- --a-- -s_-
	tester("tristate" , 8'bxxxxxxxx, 1'bx, 1'bx, 1'bx, 1'b1);
	tester("d0 = low" , 8'bxxxxxxx0, 1'b0, 1'b0, 1'b0, 1'b0);
	tester("d0 = high", 8'bxxxxxxx1, 1'b0, 1'b0, 1'b0, 1'b0);
	tester("d1 = low" , 8'bxxxxxx0x, 1'b0, 1'b0, 1'b1, 1'b0);
	tester("d1 = high", 8'bxxxxxx1x, 1'b0, 1'b0, 1'b1, 1'b0);
	tester("d2 = low" , 8'bxxxxx0xx, 1'b0, 1'b1, 1'b0, 1'b0);
	tester("d2 = high", 8'bxxxxx1xx, 1'b0, 1'b1, 1'b0, 1'b0);
	tester("d3 = low" , 8'bxxxx0xxx, 1'b0, 1'b1, 1'b1, 1'b0);
	tester("d3 = high", 8'bxxxx1xxx, 1'b0, 1'b1, 1'b1, 1'b0);
	tester("d4 = low" , 8'bxxx0xxxx, 1'b1, 1'b0, 1'b0, 1'b0);
	tester("d4 = high", 8'bxxx1xxxx, 1'b1, 1'b0, 1'b0, 1'b0);
	tester("d5 = low" , 8'bxx0xxxxx, 1'b1, 1'b0, 1'b1, 1'b0);
	tester("d5 = high", 8'bxx1xxxxx, 1'b1, 1'b0, 1'b1, 1'b0);
	tester("d6 = low" , 8'bx0xxxxxx, 1'b1, 1'b1, 1'b0, 1'b0);
	tester("d6 = high", 8'bx1xxxxxx, 1'b1, 1'b1, 1'b0, 1'b0);
	tester("d7 = low" , 8'b0xxxxxxx, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("d7 = high", 8'b1xxxxxxx, 1'b1, 1'b1, 1'b1, 1'b0);
	#10 $finish;
end
	
endmodule
