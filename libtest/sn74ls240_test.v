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

// 74ls240 variable width inverting tristate drivers
`include "sn74ls240.v"

module sn74ls240_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] a;
reg g_;
wire [WIDTH-1:0] y;

sn74ls240 #(.WIDTH(WIDTH)) dut(
	.a		(a),
	.y		(y),
	.g_		(g_)
);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] aval;
	input gval;
	input [WIDTH-1:0] expecty;
	begin
		a <= aval;
		g_ <= gval;
		#1 $display("%5g: %8b %1b  | %8b | %0s",
					$time, a, g_,   y,     descr);
					
		`assert("y", y, expecty);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("sn74ls240.vcd");
	$dumpvars;
	
$display("-time: ---a---- g_ | ---y---- | descr");

//                        -----a-----  -g_-  --expecty--
	tester("load 1's"   , 8'b11111111, 1'b0, 8'b00000000);
	tester("load 0's"   , 8'b00000000, 1'b0, 8'b11111111);
	tester("load 10's"  , 8'b10101010, 1'b0, 8'b01010101);
	tester("tristate"   , 8'bxxxxxxxx, 1'b1, 8'bzzzzzzzz);
	#10 $finish;
end
	
endmodule
