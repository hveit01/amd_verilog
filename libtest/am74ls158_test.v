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

// am74ls158 N inverting 2-to-1 multiplexer
`include "am74ls158.v"

module am74ls158_testbench;
parameter WIDTH = 4;

reg [WIDTH-1:0] a,b;
reg g;
reg s;

wire [WIDTH-1:0] y;
	
am74ls158 #(.WIDTH(WIDTH)) dut(
	.a		(a),
	.b		(b),
	.g_		(g),
	.s		(s),
	.y		(y)
);

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] aval, bval;
	input gval, sval;
	input [WIDTH-1:0] expecty;
	begin
		a <= aval;
		b <= bval;
		g <= gval;
		s <= sval;
		#1 $display("%5g: %b %b  %1b %1b | %4b | %0s",
					$time,b, a,  g,  s,    y,    descr);
		if (expecty != y) begin
			$display("Error: y should be %4b, but is %4b", expecty, y);
		end
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am74ls157.vcd");
	$dumpvars;
	
$display("-time: -a-- -b--  g s | -y-- | description");
//                         ---a--- ---b--- -g_- -s-- -expect-
	tester("disable" ,     4'bxxxx,4'bxxxx,1'b1,1'bx,4'b1111);
	tester("select A",     4'b0000,4'bxxxx,1'b0,1'b0,4'b1111);
	tester("",             4'b1111,4'bxxxx,1'b0,1'b0,4'b0000);
	tester("select B",     4'bxxxx,4'b0000,1'b0,1'b1,4'b1111);
	tester("",             4'bxxxx,4'b1111,1'b0,1'b1,4'b0000);
	#10 $finish;
end
	
endmodule
