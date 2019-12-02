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

// am25ls377 nDFF with enable
`include "am25ls377.v"

module am25ls377_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] d;
reg e_, clk;

wire [WIDTH-1:0] q;
	
am25ls377 #(.WIDTH(WIDTH)) dut(
	.d		(d),
	.clk	(clk),
	.e_		(e_),
	.q		(q)
);

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval;
	input eval;
	begin
		d <= dval;
		e_ <= eval;
		clk <= 1'b0;
		#1 $display("%5g: %8b %1b      | %6b | %0s",
					$time,d,  e_,        q,    descr);
		clk <= 1'b1;
		#1 $display("%5g: %8b %1b   r  | %6b |",
					$time,d,  e_,        q);
		clk <= 1'b0;
		#1 $display("%5g: %8b %1b   f  | %6b |",
					$time,d,  e_,        q);
		$display("");
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am25ls377.vcd");
	$dumpvars;
	
$display("-time: ---d---- e_ clk | ---q---- | descr");
//                         -----d-----  -e--
	tester("load 1's"   , 8'b11111111, 1'b0);
	tester("load 0's"   , 8'b00000000, 1'b0);
	tester("hold"       , 8'bxxxxxxxx, 1'b1);
	tester("load 10's"  , 8'b10101010, 1'b0);
	tester("load 01's"  , 8'b01010101, 1'b0);
	#10 $finish;
end
	
endmodule
