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

// am27s27 512*8 bit ROM with pipeline register
// demonstrates external initialization of ROM in initial block

`include "am27s27.v"

module am27s27_testbench;
parameter WIDTH = 8; // bit width

reg [8:0] a;
reg e1_, e2_;
reg clk;

wire [WIDTH-1:0] q;
	
am27s27 #(.WIDTH(WIDTH)) dut(
	.a		(a),
	.q		(q),
	.e1_	(e1_), 
	.e2_	(e2_),
	.clk	(clk)
);

task clocker;
	input [80*8-1:0] descr;
	input [8:0] aval;
	input e1val, e2val;
	input [WIDTH-1:0] expectq;
	begin
		a <= aval;
		e1_ <= e1val;
		e2_ <= e2val;
		#1 clk = 0;
//		$display("%5g: %b  %1b  %1b     | %b | %0s",
//				 $time,a,  e1_, e2_,      q,   descr);
		#1 clk = 1;
//		$display("%5g: %b  %1b  %1b  r  | %b | %0s",
//				 $time,a,  e1_, e2_,      q,   descr);
		#1 clk = 0;
		$display("%5g: %b  %1b  %1b  ^  | %b | %0s",
				 $time,a,  e1_, e2_,      q,   descr);
		if (expectq !== q) begin
			$display("Error: q should be %b, but is %b", expectq, q);
		end
//		$display();		
	end
endtask

task tester;
	input [80*8-1:0] descr;
	input [8:0] aval;
	input e1val, e2val;
	input [WIDTH-1:0] expectq;
	begin
		a <= aval;
		e1_ <= e1val;
		e2_ <= e2val;
		#1 $display("%5g: %b  %1b  %1b  0  | %b | %0s",
					$time,a,  e1_, e2_,      q,   descr);
		if (expectq !== q) begin
			$display("Error: q should be %b, but is %b", expectq, q);
		end
	end
endtask

initial begin
	// initialize memory
    // alternatively, you can also use parameter INITH to initialize ROM
	$readmemh("am27s27_test.hex", dut.u0.rom);
	
	//Dump results of the simulation
	$dumpfile("am27s27.vcd");
	$dumpvars;
	
$display("  When enabled, ROM returns complement of a[7:0] (hardcoded in am27s27_test.hex)");
$display("-time: ----a---- e1 e2 clk | ---q---- | description");
//                            -----d------ -e1- -e2- -expected-
	tester ("disable e1"   ,  9'bxxxxxxxxx,1'b1,1'bx,8'bzzzzzzzz);
	clocker("disable e2"   ,  9'bxxxxxxxxx,1'bx,1'b1,8'bzzzzzzzz);
	clocker("read 3, enable", 9'b000000011,1'b0,1'b0,8'b11111100);
	clocker("read 0, disable",9'b000000000,1'b1,1'b0,8'bzzzzzzzz);
	tester ("pipeline enable",9'bxxxxxxxxx,1'b0,1'bx,8'b11111111);
	clocker("read 1"       ,  9'b000000001,1'b0,1'b0,8'b11111110);
	clocker("read x55"     ,  9'b001010101,1'b0,1'b0,8'b10101010);
	clocker("read x80"     ,  9'b010000000,1'b0,1'b0,8'b01111111);
	clocker("read xce"     ,  9'b011001110,1'b0,1'b0,8'b00110001);
	clocker("read xff"     ,  9'b011111111,1'b0,1'b0,8'b00000000);
	clocker("read x180"    ,  9'b110000000,1'b0,1'b0,8'b01111111);
	clocker("read x1ee"    ,  9'b111101110,1'b0,1'b0,8'b00010001);
	tester ("disable",        9'bxxxxxxxxx,1'b1,1'bx,8'bzzzzzzzz);
	tester ("pipeline enable",9'bxxxxxxxxx,1'b0,1'bx,8'b00010001);
	#10 $finish;
end
	
endmodule
