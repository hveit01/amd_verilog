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

// am25ls08 n DFF with enable and complem. outputs
`include "am25ls08.v"

module am25ls08_testbench;
parameter WIDTH = 4;

reg [WIDTH-1:0] d;
reg e_, clk;

wire [WIDTH-1:0] q, q_;
	
am25ls08 #(.WIDTH(WIDTH)) dut(
	.d		(d),
	.clk	(clk),
	.e_		(e_),
	.q		(q),
	.q_		(q_)
);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval;
	input eval;
	input [WIDTH-1:0] expectq;
	begin
		d <= dval;
		e_ <= eval;
		clk <= 1'b0;
		#1 $display("%5g: %4b %1b      | %4b %4b | %0s",
					$time,d,  e_,        q,  q_,   descr);
		clk <= 1'b1;
		#1 $display("%5g: %4b %1b   r  | %4b %4b |",
					$time,d,  e_,        q,  q_);
		clk <= 1'b0;
		#1 $display("%5g: %4b %1b   f  | %4b %4b |",
					$time,d,  e_,        q,  q_);
		$display("");
		
		`assert("q", q, expectq);
		`assert("q_", q_, ~expectq);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am25ls08.vcd");
	$dumpvars;
	
$display("-time: -d-- e_ clk | -q-- -q_- | descr");
//                        ---d---  -e-- -expect
	tester("load 1's"   , 4'b1111, 1'b0,4'b1111);
	tester("load 0's"   , 4'b0000, 1'b0,4'b0000);
	tester("hold"       , 4'bxxxx, 1'b1,4'b0000);
	tester("load 10's"  , 4'b1010, 1'b0,4'b1010);
	tester("load 01's"  , 4'b0101, 1'b0,4'b0101);
	#10 $finish;
end
	
endmodule
