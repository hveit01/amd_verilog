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

// am2959 variable width noninverting tristate drivers
`include "am2959.v"

module am2959_testbench;
parameter WIDTH = 4;

reg [WIDTH-1:0] a;
reg g_;
wire [WIDTH-1:0] y;

am2959 #(.WIDTH(WIDTH)) dut(
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
		#1 $display("%5g: %4b %1b | %4b | %0s",
					$time, a, g_,   y,    descr);
					
		`assert("y", y, expecty);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2959.vcd");
	$dumpvars;
	
$display("-time: -a-- g | -y-- | descr");

//                        --a--- -g_ --expy-
	tester("tristate"   , 'bxxxx,'b1,'bzzzz);
	tester("load 1's"   , 'b1111,'b0,'b1111);
	tester("load 0's"   , 'b0000,'b0,'b0000);
	tester("load 10's"  , 'b1010,'b0,'b1010);
	#10 $finish;
end
	
endmodule
