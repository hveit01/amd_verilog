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

// am29803 16-way branch unit
`include "am29803.v"

module am29803_testbench;

reg [3:0] i;
reg [3:0] t;
reg oe1,oe2;

wire [3:0] orx;

am29803 dut(
	.i			(i),
	.t			(t),
	.oe1_		(oe1),
	.oe2_		(oe2),
	.orx		(orx)
);

reg [1:0] ok;

task tester;
	input [3:0] ival;
	input [3:0] tval;
	input oe1val,oe2val;
	input [3:0] expect_orx;
	begin
		i <= ival;
		t <= tval;
		oe1 <= oe1val;
		oe2 <= oe2val;
//		#1 $display("%5g: %4b %4b  %1b   %1b  | %4b",
//					$time,i,  t,   oe1,  oe2,   orx);
        #1 if (expect_orx !== orx) begin
			$display("  Error: for t=%b output ORX should be %b, but is %b", t, expect_orx, orx);
			ok = 0;
        end
	end
endtask

task checkok;
	input [80:0] descr;
	begin
		case (ok)
		0: $display("  failed");
		1: $display("  ok");
		default: ;
		endcase;
		ok = 1;
		$display("%5s", descr);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am29803.vcd");
	$dumpvars;
	
//$display("-time: -i-- -t-- oe1 oe2 | orx- | description");

//         --i---  ---t---  oe1_  oe2_  expect-
	ok = 2;
	checkok("Disable oe");
	tester(4'bxxxx, 4'bxxxx, 1'b1, 1'bx, 4'bzzzz);
	tester(4'bxxxx, 4'bxxxx, 1'bx, 1'b1, 4'bzzzz);
	checkok("No test");
	tester(4'b0000, 4'bxxxx, 1'b0, 1'b0, 4'b0000);
	checkok("Test t0");
	tester(4'b0001, 4'bxxx0, 1'b0, 1'b0, 4'b0000);
	tester(4'b0001, 4'bxxx1, 1'b0, 1'b0, 4'b0001);
	checkok("Test t1");
	tester(4'b0010, 4'bxx0x, 1'b0, 1'b0, 4'b0000);
	tester(4'b0010, 4'bxx1x, 1'b0, 1'b0, 4'b0001);
	checkok("Test t2");
	tester(4'b0100, 4'bx0xx, 1'b0, 1'b0, 4'b0000);
	tester(4'b0100, 4'bx1xx, 1'b0, 1'b0, 4'b0001);
	checkok("Test t3");
	tester(4'b1000, 4'b0xxx, 1'b0, 1'b0, 4'b0000);
	tester(4'b1000, 4'b1xxx, 1'b0, 1'b0, 4'b0001);
	checkok("Test t0&t1");
	tester(4'b0011, 4'bxx00, 1'b0, 1'b0, 4'b0000);
	tester(4'b0011, 4'bxx01, 1'b0, 1'b0, 4'b0001);
	tester(4'b0011, 4'bxx10, 1'b0, 1'b0, 4'b0010);
	tester(4'b0011, 4'bxx11, 1'b0, 1'b0, 4'b0011);
	checkok("Test t0&t2");
	tester(4'b0101, 4'bx0x0, 1'b0, 1'b0, 4'b0000);
	tester(4'b0101, 4'bx0x1, 1'b0, 1'b0, 4'b0001);
	tester(4'b0101, 4'bx1x0, 1'b0, 1'b0, 4'b0010);
	tester(4'b0101, 4'bx1x1, 1'b0, 1'b0, 4'b0011);
	checkok("Test t0&t3");
	tester(4'b1001, 4'b0xx0, 1'b0, 1'b0, 4'b0000);
	tester(4'b1001, 4'b0xx1, 1'b0, 1'b0, 4'b0001);
	tester(4'b1001, 4'b1xx0, 1'b0, 1'b0, 4'b0010);
	tester(4'b1001, 4'b1xx1, 1'b0, 1'b0, 4'b0011);
	checkok("Test t1&t2");
	tester(4'b0110, 4'bx00x, 1'b0, 1'b0, 4'b0000);
	tester(4'b0110, 4'bx01x, 1'b0, 1'b0, 4'b0001);
	tester(4'b0110, 4'bx10x, 1'b0, 1'b0, 4'b0010);
	tester(4'b0110, 4'bx11x, 1'b0, 1'b0, 4'b0011);
	checkok("Test t1&t3");
	tester(4'b1010, 4'b0x0x, 1'b0, 1'b0, 4'b0000);
	tester(4'b1010, 4'b0x1x, 1'b0, 1'b0, 4'b0001);
	tester(4'b1010, 4'b1x0x, 1'b0, 1'b0, 4'b0010);
	tester(4'b1010, 4'b1x1x, 1'b0, 1'b0, 4'b0011);
	checkok("Test t2&t3");
	tester(4'b1100, 4'b00xx, 1'b0, 1'b0, 4'b0000);
	tester(4'b1100, 4'b01xx, 1'b0, 1'b0, 4'b0001);
	tester(4'b1100, 4'b10xx, 1'b0, 1'b0, 4'b0010);
	tester(4'b1100, 4'b11xx, 1'b0, 1'b0, 4'b0011);
	checkok("Test t0&t1&t2");
	tester(4'b0111, 4'bx000, 1'b0, 1'b0, 4'b0000);
	tester(4'b0111, 4'bx001, 1'b0, 1'b0, 4'b0001);
	tester(4'b0111, 4'bx010, 1'b0, 1'b0, 4'b0010);
	tester(4'b0111, 4'bx011, 1'b0, 1'b0, 4'b0011);
	tester(4'b0111, 4'bx100, 1'b0, 1'b0, 4'b0100);
	tester(4'b0111, 4'bx101, 1'b0, 1'b0, 4'b0101);
	tester(4'b0111, 4'bx110, 1'b0, 1'b0, 4'b0110);
	tester(4'b0111, 4'bx111, 1'b0, 1'b0, 4'b0111);
	checkok("Test t0&t1&t3");
	tester(4'b1011, 4'b0x00, 1'b0, 1'b0, 4'b0000);
	tester(4'b1011, 4'b0x01, 1'b0, 1'b0, 4'b0001);
	tester(4'b1011, 4'b0x10, 1'b0, 1'b0, 4'b0010);
	tester(4'b1011, 4'b0x11, 1'b0, 1'b0, 4'b0011);
	tester(4'b1011, 4'b1x00, 1'b0, 1'b0, 4'b0100);
	tester(4'b1011, 4'b1x01, 1'b0, 1'b0, 4'b0101);
	tester(4'b1011, 4'b1x10, 1'b0, 1'b0, 4'b0110);
	tester(4'b1011, 4'b1x11, 1'b0, 1'b0, 4'b0111);
	checkok("Test t0&t2&t3");
	tester(4'b1101, 4'b00x0, 1'b0, 1'b0, 4'b0000);
	tester(4'b1101, 4'b00x1, 1'b0, 1'b0, 4'b0001);
	tester(4'b1101, 4'b01x0, 1'b0, 1'b0, 4'b0010);
	tester(4'b1101, 4'b01x1, 1'b0, 1'b0, 4'b0011);
	tester(4'b1101, 4'b10x0, 1'b0, 1'b0, 4'b0100);
	tester(4'b1101, 4'b10x1, 1'b0, 1'b0, 4'b0101);
	tester(4'b1101, 4'b11x0, 1'b0, 1'b0, 4'b0110);
	tester(4'b1101, 4'b11x1, 1'b0, 1'b0, 4'b0111);
	checkok("Test t1&t2&t3");
	tester(4'b1110, 4'b000x, 1'b0, 1'b0, 4'b0000);
	tester(4'b1110, 4'b001x, 1'b0, 1'b0, 4'b0001);
	tester(4'b1110, 4'b010x, 1'b0, 1'b0, 4'b0010);
	tester(4'b1110, 4'b011x, 1'b0, 1'b0, 4'b0011);
	tester(4'b1110, 4'b100x, 1'b0, 1'b0, 4'b0100);
	tester(4'b1110, 4'b101x, 1'b0, 1'b0, 4'b0101);
	tester(4'b1110, 4'b110x, 1'b0, 1'b0, 4'b0110);
	tester(4'b1110, 4'b111x, 1'b0, 1'b0, 4'b0111);
	checkok("Test t0&t1&t2&t3");
	tester(4'b1111, 4'b0000, 1'b0, 1'b0, 4'b0000);
	tester(4'b1111, 4'b0001, 1'b0, 1'b0, 4'b0001);
	tester(4'b1111, 4'b0010, 1'b0, 1'b0, 4'b0010);
	tester(4'b1111, 4'b0011, 1'b0, 1'b0, 4'b0011);
	tester(4'b1111, 4'b0100, 1'b0, 1'b0, 4'b0100);
	tester(4'b1111, 4'b0101, 1'b0, 1'b0, 4'b0101);
	tester(4'b1111, 4'b0110, 1'b0, 1'b0, 4'b0110);
	tester(4'b1111, 4'b0111, 1'b0, 1'b0, 4'b0111);
	tester(4'b1111, 4'b1000, 1'b0, 1'b0, 4'b1000);
	tester(4'b1111, 4'b1001, 1'b0, 1'b0, 4'b1001);
	tester(4'b1111, 4'b1010, 1'b0, 1'b0, 4'b1010);
	tester(4'b1111, 4'b1011, 1'b0, 1'b0, 4'b1011);
	tester(4'b1111, 4'b1100, 1'b0, 1'b0, 4'b1100);
	tester(4'b1111, 4'b1101, 1'b0, 1'b0, 4'b1101);
	tester(4'b1111, 4'b1110, 1'b0, 1'b0, 4'b1110);
	tester(4'b1111, 4'b1111, 1'b0, 1'b0, 4'b1111);
	checkok("");
	#10 $finish;
end
	
endmodule
