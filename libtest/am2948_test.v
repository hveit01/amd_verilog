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

// am2948 variable width inverting tristate bus transceivers
`include "am2948.v"

module am2948_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] ain, bin;
reg tr, rc;

wire [WIDTH-1:0] a, b;

am2948 #(.WIDTH(WIDTH)) dut(
	.a		(a),
	.b		(b),
	.rc_	(rc),
	.tr_	(tr)
);

assign a = ain;
assign b = bin;

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, value, signal); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] aval, bval;
	input trval, rcval;
	input [WIDTH-1:0] expecta, expectb;
	begin
		ain <= aval; bin <= bval;
		rc <= rcval; tr <= trval;
		#1 $display("%5g: %8b %8b  %b  %b | %8b %8b | %0s",
					$time,ain,bin, tr, rc,  a,  b,    descr);
					
		`assert("a", a, expecta);
		`assert("b", b, expectb);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2948.vcd");
	$dumpvars;
	
	$display("-time: ---a---- ---b---- tr rc | ---a---- ---b---- | descr");

//                          ----a----- ----b----- -tr -rc --expecta- --expectb-
	tester("Tristate"   ,   'bZZZZZZZZ,'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'bZZZZZZZZ);
	tester("A -> B"     ,   'b00110011,'bZZZZZZZZ,'b0,'b1,'b00110011,'b11001100);
	tester("B -> A"     ,   'bZZZZZZZZ,'b01010101,'b1,'b0,'b10101010,'b01010101);
//	tester("Don't do this", 'b11111111,'b00000000,'b0,'b0,'b10101010,'b01010101);
	#10 $finish;
end
	
endmodule
