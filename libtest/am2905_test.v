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

// am2905 bus transceiver
`include "am2905.v"

module am2905_testbench;
parameter WIDTH=4;
reg [3:0] a, b;
reg drcp, be_, sel;
reg rle_, oe_;

reg [3:0] busin_;
wire [3:0] r;
wand [3:0] bus_;

am2905 #(.WIDTH(WIDTH))
	dut(
		.a		(a),
		.b		(b),
		.be_	(be_),
		.sel	(sel),
		.bus_	(bus_),
		.rle_	(rle_),
		.oe_	(oe_),
		.r		(r),
		.drcp	(drcp)
	);

assign bus_ = (be_==1'b1) ? busin_ : 4'bzzzz;

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

`define showvals\
		$display("%5g: %4b %4b  %1b  %1b    x   %1b    %1b  | %4b | %4b | %0s",\
		         $time,a,  b,   sel, be_,       rle_,  oe_,   bus_, r,   descr);

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval, bval;
	input selval, beval;
	input [3:0] busval;
	input rleval, oeval;
	
	input [3:0] expectdreg;
	input [3:0] expectrlatch;

	begin
		a <= aval;
		b <= bval;
		be_ <= beval;
		sel <= selval;
		rle_ <= rleval;
		oe_ <= oeval;
		busin_ <= busval;
		#1 drcp <= 1'b0;
		`showvals;
		`assert ("internal driver reg", expectdreg, dut.dreg);
		`assert ("internal receiver latch", expectrlatch, dut.rlatch);
	end
endtask

task clocker;
	input [80*8-1:0] descr;
	input [3:0] aval, bval;
	input selval, beval;
	input [3:0] busval;
	input rleval, oeval;

	input [3:0] expectdreg;
	input [3:0] expectrlatch;

	begin
		a <= aval;
		b <= bval;
		be_ <= beval;
		sel <= selval;
		busin_ <= busval;
		rle_ <= rleval;
		oe_ <= oeval;
		
		#1 drcp <= 1'b0;
//		showvals;
		#1 drcp <= 1'b1;
		`showvals;
		#1 drcp <= 1'b0;
//		`showvals;
		`assert ("internal driver reg", expectdreg, dut.dreg);
		`assert ("internal receiver latch", expectrlatch, dut.rlatch);
	end
endtask
	
initial
begin
	//Dump results of the simulation to ff.cvd
	$dumpfile("am2905.vcd");
	$dumpvars;

    $display("-time: -a-- -b-- sel be_ -cp rle_ oe- | bus_ | -r-- |");

	//                           ---a---  ---b--- -sel -be_- --bus-- rle_ -oe_  --dreg-  -rlatch
	tester ("driver disable",    4'bxxxx, 4'bxxxx,1'bx,1'b1, 4'bzzzz,1'bx,1'bx, 4'bxxxx, 4'bxxxx);
	tester ("receiver disable",  4'bxxxx, 4'bxxxx,1'bx,1'bx, 4'bxxxx,1'bx,1'b1, 4'bxxxx, 4'bxxxx);
	tester ("receive bus",       4'bxxxx, 4'bxxxx,1'bx,1'b1, 4'b1100,1'b0,1'b0, 4'bxxxx, 4'b0011);
	tester ("",                  4'bxxxx, 4'bxxxx,1'bx,1'b1, 4'b0011,1'b0,1'b0, 4'bxxxx, 4'b1100);
	tester ("latch data",        4'bxxxx, 4'bxxxx,1'bx,1'b1, 4'bxxxx,1'b1,1'bx, 4'bxxxx, 4'b1100);
	tester ("latched data to r" ,4'bxxxx, 4'bxxxx,1'bx,1'bx, 4'bxxxx,1'b1,1'b0, 4'bxxxx, 4'b1100);
//                                                                              
	clocker("load a",            4'b0000, 4'bxxxx,1'b0,1'bx, 4'bxxxx,1'bx,1'bx, 4'b0000, 4'bxxxx);
	clocker("",                  4'b1111, 4'bxxxx,1'b0,1'bx, 4'bxxxx,1'bx,1'bx, 4'b1111, 4'bxxxx);
	clocker("load b",            4'bxxxx, 4'b0101,1'b1,1'bx, 4'bxxxx,1'bx,1'bx, 4'b0101, 4'bxxxx);
	clocker("",                  4'bxxxx, 4'b1010,1'b1,1'bx, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx);
	tester ("drive bus",         4'bxxxx, 4'bxxxx,1'bx,1'b0, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx);
	tester ("",                  4'bxxxx, 4'bxxxx,1'bx,1'b0, 4'bxxxx,1'bx,1'bx, 4'b1010, 4'bxxxx);
	#10 $finish;
end

endmodule
