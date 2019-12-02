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

// am25s174 nDFF with clear
`include "am25s174.v"

module am25s174_testbench;
parameter WIDTH = 6;

reg [WIDTH-1:0] d;
reg clr_, clk;

wire [WIDTH-1:0] q, q_;
	
am25s174 #(.WIDTH(WIDTH)) dut(
	.d		(d),
	.clk	(clk),
	.clr_	(clr_),
	.q		(q),
	.q_		(q_)
);

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval;
	input clrval;
	input clkval;
	begin
		d <= dval;
		clr_ <= clrval;
		clk <= clkval;
		#1 $display("%5g: %6b  %1b   %1b  | %6b %6b | %0s",
					$time,d,   clr_, clk,   q,  q_,   descr);
		$display("");
	end
endtask

task clocker;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval;
	input clrval;
	begin
		d <= dval;
		clr_ <= clrval;
		clk <= 1'b0;
		#1 $display("%5g: %6b  %1b   %1b  | %6b %6b | %0s",
					$time,d,   clr_, clk,   q,  q_,   descr);
		clk <= 1'b1;
		#1 $display("%5g: %6b  %1b   r  | %6b %6b |",
					$time,d,   clr_,      q,  q_);
		clk <= 1'b0;
		#1 $display("%5g: %6b  %1b   f  | %6b %6b |",
					$time,d,   clr_,      q,  q_);
		$display("");
	end
endtask



initial begin
	//Dump results of the simulation
	$dumpfile("am25s174.vcd");
	$dumpvars;
	
$display("-time: --d--- clr clk | --q--- --q_-- |");
//                         ---d-----  -clr- -clk-
	tester("clear"       , 6'bxxxxxx, 1'b0, 1'bx);
	clocker("clear hold" , 6'b101010, 1'b0);

	clocker("load 1's"   , 6'b111111, 1'b1);
	clocker("load 0's"   , 6'b000000, 1'b1);
	clocker("load 10's"  , 6'b101010, 1'b1);
	clocker("load 01's"  , 6'b010101, 1'b1);
	#10 $finish;
end
	
endmodule
