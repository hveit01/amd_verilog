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

// am2907/8 bus transceiver with parity
`include "am2907.v"

module am2907_testbench;
parameter WIDTH=4;
reg [3:0] a;
reg drcp, be_, sel;
reg rle_, oe_;

reg [3:0] busin_;
wire [3:0] r;
wire odd;
wand [3:0] bus_;

am2907 #(.WIDTH(WIDTH))
	dut(
		.a		(a),
		.be_	(be_),
		.bus_	(bus_),
		.rle_	(rle_),
		.odd	(odd),
		.r		(r),
		.oe_	(oe_),
		.drcp	(drcp)
	);

assign bus_ = (be_==1'b1) ? busin_ : 4'bzzzz;

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

`define showvals(cp)\
		$display("%5g: %4b  %1b    %1s   %1b    %1b  | %4b | %4b %1b | %0s",\
		         $time,a,   be_,   cp,   rle_,  oe_,   bus_, r,  odd,  descr);

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval;
	input beval;
	input [3:0] busval;
	input rleval, oeval;
	
	input [3:0] expectdreg;
	input [3:0] expectrlatch;
	input expectodd;

	begin
		a <= aval;
		be_ <= beval;
		rle_ <= rleval;
		oe_ <= oeval;
		busin_ <= busval;
		#1 drcp <= 1'b0;
		`showvals("x");
		`assert ("internal driver reg", expectdreg, dut.dreg);
		`assert ("internal receiver latch", expectrlatch, dut.rlatch);
		`assert ("parity", expectodd, odd);
	end
endtask

task clocker;
	input [80*8-1:0] descr;
	input [3:0] aval;
	input beval;
	input [3:0] busval;
	input rleval, oeval;

	input [3:0] expectdreg;
	input [3:0] expectrlatch;
	input expectodd;

	begin
		a <= aval;
		be_ <= beval;
		busin_ <= busval;
		rle_ <= rleval;
		oe_ <= oeval;
		
		#1 drcp <= 1'b0;
//		showvals(" ");
		#1 drcp <= 1'b1;
		`showvals("^");
		#1 drcp <= 1'b0;
//		`showvals(" ");
		`assert ("internal driver reg", expectdreg, dut.dreg);
		`assert ("internal receiver latch", expectrlatch, dut.rlatch);
		`assert ("parity", expectodd, odd);
	end
endtask
	
initial
begin
	//Dump results of the simulation to ff.cvd
	$dumpfile("am2907.vcd");
	$dumpvars;

    $display("-time: -a-- be_ -cp rle_ oe- | bus_ odd | -r-- |");

	//                           ---a---  -be_- --bus-- rle_ -oe_  --dreg-  -rlatch -odd
	tester ("driver disable",    4'bxxxx, 1'b1, 4'bzzzz,1'bx,1'bx, 4'bxxxx, 4'bxxxx,1'bx);
	tester ("receiver disable",  4'bxxxx, 1'bx, 4'bxxxx,1'bx,1'b1, 4'bxxxx, 4'bxxxx,1'bx);
	tester ("receive bus",       4'bxxxx, 1'b1, 4'b1100,1'b0,1'b0, 4'bxxxx, 4'b0011,1'b0);
	tester ("",                  4'bxxxx, 1'b1, 4'b0111,1'b0,1'b0, 4'bxxxx, 4'b1000,1'b1);
	tester ("latch data",        4'bxxxx, 1'b1, 4'bxxxx,1'b1,1'bx, 4'bxxxx, 4'b1000,1'b1);
	tester ("latched data to r" ,4'bxxxx, 1'bx, 4'bxxxx,1'b1,1'b0, 4'bxxxx, 4'b1000,1'bx);
//                                                                              
	clocker("load a",            4'b0000, 1'bx, 4'bxxxx,1'bx,1'bx, 4'b0000, 4'bxxxx,1'bx);
	clocker("",                  4'b1010, 1'bx, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx,1'bx);
	tester ("drive bus",         4'bxxxx, 1'b0, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx,1'bx);
	tester ("",                  4'bxxxx, 1'b0, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx,1'bx);
	tester ("drive, parity a",   4'b1110, 1'b0, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx,1'b1);
	#10 $finish;
end

endmodule
