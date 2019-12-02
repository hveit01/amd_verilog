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

// am29761 256*n bit ROM
`include "am29761.v"

module am29761_testbench;
parameter WIDTH = 4; // bit width
parameter SIZE = 8; // number of address lines

reg [SIZE-1:0] a;
reg cs1_, cs2_;

wire [WIDTH-1:0] q;
	
am29761 dut(
	.a		(a),
	.q		(q),
	.cs1_	(cs1_),
	.cs2_	(cs2_)
);

task tester;
	input [80*8-1:0] descr;
	input [SIZE-1:0] aval;
	input cs1val, cs2val;
	input [WIDTH-1:0] expectq;
	begin
		a <= aval;
		cs1_ <= cs1val;
		cs2_ <= cs2val;
		#1 $display("%5g: %b  %1b   %1b  | %b | %0s",
					$time,a,  cs1_, cs2_, q,  descr);
		if (expectq != q) begin
			$display("Error: q should be %b, but is %b", expectq, q);
		end
					
	end
endtask

initial begin
	// initialize memory
	$readmemh("am29761_test.hex", dut.u0.rom);
	
	//Dump results of the simulation
	$dumpfile("am29761.vcd");
	$dumpvars;
	
$display("  When enabled, ROM returns complement of address (hardcoded in am29761_test.hex)");
$display("-time: ---a---- cs1 cs2 | ---q---- | descr");
//                          -----d-----  -cs1- -cs2- --expected-
	tester("disable cs1"  , 8'bxxxxxxxx, 1'b1, 1'bx, 8'bzzzzzzzz);
	tester("disable cs2"  , 8'bxxxxxxxx, 1'bx, 1'b1, 8'bzzzzzzzz);
	tester("read 0"       , 8'b00000000, 1'b0, 1'b0, 8'b11111111);
	tester("read 1"       , 8'b00000001, 1'b0, 1'b0, 8'b11111110);
	tester("disable cs1"  , 8'bxxxxxxxx, 1'b1, 1'bx, 8'bzzzzzzzz);
	tester("read x55"     , 8'b01010101, 1'b0, 1'b0, 8'b10101010);
	tester("read x80"     , 8'b10000000, 1'b0, 1'b0, 8'b01111111);
	tester("read xce"     , 8'b11001110, 1'b0, 1'b0, 8'b00110001);
	tester("disable cs2"  , 8'bxxxxxxxx, 1'bx, 1'b1, 8'bzzzzzzzz);
	tester("read xff"     , 8'b11111111, 1'b0, 1'b0, 8'b00000000);
	#10 $finish;
end
	
endmodule
