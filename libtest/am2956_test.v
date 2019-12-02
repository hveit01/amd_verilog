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

// am2956 n-Latch with noninverting tristate outputs
`include "am2956.v"

module am2956_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] d;
reg oe, g;

wire [WIDTH-1:0] y;
	
am2956 #(.WIDTH(WIDTH)) dut(
	.d		(d),
	.g		(g),
	.oe_	(oe),
	.y		(y)
);

`define ASSERT(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, value, signal); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval;
	input gval, oeval;
	input [WIDTH-1:0] expecty;
	
	begin
		d <= dval;
		g <= gval; oe <= oeval;
		#1 $display("%5g: %8b  %1b %1b | %8b | %0s", $time, d, g, oe, y, descr);
		
		`ASSERT("Y", y, expecty);		
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2956.vcd");
	$dumpvars;
	
$display("-time: ---d---- oe g | ---q---- | descr");
//                          -----d---- -g- -oe -expecty--
	tester("Tristate",      'bXXXXXXXX,'bX,'b1,'bZZZZZZZZ);
	tester("Transparent",   'b11111111,'b1,'b0,'b11111111);
	tester("Transparent",   'b10101010,'b1,'b0,'b10101010);
	tester("Latch",         'b01010101,'b0,'b0,'b01010101);
	tester("Hold",          'b11001100,'b0,'b0,'b01010101);
	#10 $finish;
end
	
endmodule
