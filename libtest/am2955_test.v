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

// am2955 nDFF with inverting tristate outputs
`include "am2955.v"

module am2955_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] d;
reg oe, cp;

wire [WIDTH-1:0] y;
	
am2955 #(.WIDTH(WIDTH)) dut(
	.d		(d),
	.cp		(cp),
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
	input oeval;
	input [WIDTH-1:0] expecty;
	
	begin
		d <= dval;
		oe <= oeval;
		cp <= 1'b0;
		#1 // $display("%5g: %8b %1b      | %8b |", $time, d, oe, y);
		cp <= 1'b1;
		#1 $display("%5g: %8b %1b   ^  | %8b | %0s", $time, d, oe, y, descr);
		cp <= 1'b0;
		#1 // $display("%5g: %8b %1b      | %8b |", $time, d, oe, y);
		
		`ASSERT("Y", y, expecty);		
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2955.vcd");
	$dumpvars;
	
$display("-time: ---d---- e_ clk | ---q---- | descr");
//                      -----d---- -oe -expecty--
	tester("Tristate",  'bXXXXXXXX,'b1,'bZZZZZZZZ);
	tester("load 1's",  'b11111111,'b1,'bZZZZZZZZ);
	tester("OE=0",      'b11111111,'b0,'b00000000);
	tester("load 10's", 'b10101010,'b0,'b01010101);
	tester("load 01's", 'b01010101,'b0,'b10101010);
	#10 $finish;
end
	
endmodule
