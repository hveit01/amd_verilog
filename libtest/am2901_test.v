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

// am2901 testbench 4 bit size
`include "am2901.v"

module am2901_testbench;

reg [3:0] a, b;
reg [8:0] i;
reg [3:0] din;
reg oe_;
reg cn;
reg cp;

wire [3:0] y;
wire ovr;
wire f0;
wire f0_up;
wire f3;
wire cn4;
wire g_, p_;

reg  q0o,q3o,ram0o,ram3o;
wire q0i,q3i,ram0i,ram3i;
wire q0, q3, ram0, ram3;

am2901 dut(
		.a		(a),
		.b		(b),
		.i		(i),
		.din	(din),
		.oe_	(oe_),
		.cn		(cn),
		.cp		(cp),

		.q0	    (q0),
		.q3 	(q3), 
		.ram0	(ram0), 
		.ram3	(ram3),

		.y		(y), 
		.ovr	(ovr), 
		.f0		(f0), 
		.f3		(f3), 
		.cn4	(cn4),
		.g_		(g_),
		.p_		(p_)
);

assign q0i = q0;
assign q3i = q3;
assign ram0i = ram0;
assign ram3i = ram3;
assign q0 = q0o;
assign q3 = q3o;
assign ram0 = ram0o;
assign ram3 = ram3o;

assign f0_up = (f0 === 1'bz) ? 1'b1 : 1'b0;

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval, bval;
	input [8:0] ival;
	input [3:0] dval;
	input oe_val;
	input cnval;
	input q0v, q3v, ram0v, ram3v;
	input [3:0] expecty;
	begin
		a <= aval;
		b <= bval;
		i <= ival;
		din <= dval;
		oe_ <= oe_val;
		cn <= cnval;
		q0o <= q0v;
		q3o <= q3v;
		ram0o <= ram0v;
		ram3o <= ram3v;
		cp <= 0;

//		#1 $display("%5g: %4b %4b %9b %4b  %1b  %1b  %1b  %1b  %1b  %1b  0  | %4b %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  | %0s",
//		            $time, a, b,  i,  din, oe_, cn,  ram0v,ram3v,q0v,q3v,     y,  ovr, f0_up,f3, cn4, g_,  p_,  ram0,ram3,q0,  q3,    descr);
		#1 cp <= 1;
		#1 $display("%5g: %4b %4b %9b %4b  %1b  %1b  %1b  %1b  %1b  %1b  r  | %4b %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  | %0s",
		            $time, a, b,  i,  din, oe_, cn,  ram0v,ram3v,q0v,q3v,     y,  ovr, f0_up,f3, cn4, g_,  p_,  ram0,ram3,q0,  q3,    descr);
		cp <= 0;
		#1 $display("%5g: %4b %4b %9b %4b  %1b  %1b  %1b  %1b  %1b  %1b  f  | %4b %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  %1b  |",
		            $time, a, b,  i,  din, oe_, cn,  ram0v,ram3v,q0v,q3v,     y,  ovr, f0_up,f3, cn4, g_,  p_,  ram0,ram3,q0,  q3);
//		$display ("adda=%b addb=%b addc=%b addf=%b aluf=%b", dut.adda, dut.addb, dut.addc, dut.addf, dut.aluf);
//		$display ("after a=%b b=%b q=%b", dut.ram[a], dut.ram[b], dut.qreg);
		if (expecty != y) begin
			$display("Error: y should be %4b, but is %4b", expecty, y);
		end
		$display("");
	end
endtask

initial begin

	//Dump results of the simulation to am2901.vcd
	$dumpfile("am2901.vcd");
	$dumpvars;

//                                          ---a--- ---b--- -----i------ --din--  -oe-  -cin- -q0-  -q3-  -r0-  -r3-  expecty
      $display("  Test D path");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("OE disable",                  4'bxxxx,4'bxxxx,9'b001011111,4'bxxxx, 1'b1, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'bzzzz);
	  tester("DIN->Y",                      4'bxxxx,4'bxxxx,9'b001011111,4'b0101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);

	  $display("  Initialize RAM (data == addr)");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("DIN->RAM(0)",                 4'bxxxx,4'b0000,9'b011011111,4'b0000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("DIN->RAM(1)",                 4'bxxxx,4'b0001,9'b011011111,4'b0001, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0001);
	  tester("DIN->RAM(2)",                 4'bxxxx,4'b0010,9'b011011111,4'b0010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0010);
	  tester("DIN->RAM(3)",                 4'bxxxx,4'b0011,9'b011011111,4'b0011, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0011);
	  tester("DIN->RAM(4)",                 4'bxxxx,4'b0100,9'b011011111,4'b0100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0100);
	  tester("DIN->RAM(5)",                 4'bxxxx,4'b0101,9'b011011111,4'b0101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("DIN->RAM(6)",                 4'bxxxx,4'b0110,9'b011011111,4'b0110, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("DIN->RAM(7)",                 4'bxxxx,4'b0111,9'b011011111,4'b0111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("DIN->RAM(8)",                 4'bxxxx,4'b1000,9'b011011111,4'b1000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("DIN->RAM(9)",                 4'bxxxx,4'b1001,9'b011011111,4'b1001, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("DIN->RAM(10)",                4'bxxxx,4'b1010,9'b011011111,4'b1010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("DIN->RAM(11)",                4'bxxxx,4'b1011,9'b011011111,4'b1011, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("DIN->RAM(12)",                4'bxxxx,4'b1100,9'b011011111,4'b1100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1100);
	  tester("DIN->RAM(13)",                4'bxxxx,4'b1101,9'b011011111,4'b1101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);
	  tester("DIN->RAM(14)",                4'bxxxx,4'b1110,9'b011011111,4'b1110, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("DIN->RAM(15)",                4'bxxxx,4'b1111,9'b011011111,4'b1111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  
  	  $display("  Check Overflow and Carry");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("CY, no OVF: 1101+0101+1",     4'b1101,4'b0101,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0011);
	  tester("CY, no OVF: 1110+1111+1",     4'b1110,4'b1111,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("No CY, no OVF: 0010+0010+1",  4'b0010,4'b0010,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("No CY, OVF: 0110+0010+1",     4'b0110,4'b0010,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("No CY, OVF: 0111+0000+1",     4'b0111,4'b0000,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("CY, OVF: 1001+1011+1",        4'b1001,4'b1011,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);

	  $display("  Test Q loading");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("DIN->Q",                      4'bxxxx,4'bxxxx,9'b000011111,4'b1110, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("Q->Y",                        4'bxxxx,4'bxxxx,9'b001011010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  
	  $display("  Test ALU function Matrix (Figure 5 of data sheet), Q==1110");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=100 A+Q",                   4'b0000,4'bxxxx,9'b001000000,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=100 A+Q+1",                 4'b0000,4'bxxxx,9'b001000000,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("I=101 A+B",                   4'b0001,4'b0101,9'b001000001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("I=101 A+B+1",                 4'b0001,4'b0101,9'b001000001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=102 Q",                     4'bxxxx,4'bxxxx,9'b001000010,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=102 Q+1",                   4'bxxxx,4'bxxxx,9'b001000010,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("I=103 B",                     4'bxxxx,4'b0110,9'b001000011,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("I=103 B+1",                   4'bxxxx,4'b0110,9'b001000011,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=104 A",                     4'b0010,4'bxxxx,9'b001000100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0010);
	  tester("I=104 A+1",                   4'b0010,4'bxxxx,9'b001000100,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0011);
	  tester("I=105 D+A",                   4'b0011,4'bxxxx,9'b001000101,4'b0111, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=105 D+A+1",                 4'b0011,4'bxxxx,9'b001000101,4'b0111, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("I=106 D+Q",                   4'bxxxx,4'bxxxx,9'b001000110,4'b1001, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=106 D+Q+1",                 4'bxxxx,4'bxxxx,9'b001000110,4'b1001, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("I=107 D",                     4'bxxxx,4'bxxxx,9'b001000111,4'b1010, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=107 D+1",                   4'bxxxx,4'bxxxx,9'b001000111,4'b1010, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=110 Q-A-1",                 4'b0100,4'bxxxx,9'b001001000,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=110 Q-A",                   4'b0100,4'bxxxx,9'b001001000,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=111 B-A-1",                 4'b0101,4'b0111,9'b001001001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0001);
	  tester("I=111 B-A",                   4'b0101,4'b0111,9'b001001001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0010);
	  tester("I=112 Q-1",                   4'bxxxx,4'bxxxx,9'b001001010,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);
	  tester("I=112 Q",                     4'bxxxx,4'bxxxx,9'b001001010,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=113 B-1",                   4'bxxxx,4'b1000,9'b001001011,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=113 B",                     4'bxxxx,4'b1000,9'b001001011,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("I=114 A-1",                   4'b0110,4'bxxxx,9'b001001100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=114 A",                     4'b0110,4'bxxxx,9'b001001100,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("I=115 A-D-1",                 4'b0111,4'bxxxx,9'b001001101,4'b0111, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("I=115 A-D",                   4'b0111,4'bxxxx,9'b001001101,4'b0111, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=116 Q-D-1",                 4'bxxxx,4'bxxxx,9'b001001110,4'b1001, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0100);
	  tester("I=116 Q-D",                   4'bxxxx,4'bxxxx,9'b001001110,4'b1001, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=117 -D-1",                  4'bxxxx,4'bxxxx,9'b001001111,4'b1010, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=117 -D",                    4'bxxxx,4'bxxxx,9'b001001111,4'b1010, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=120 A-Q-1",                 4'b0100,4'bxxxx,9'b001010000,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=120 A-Q",                   4'b0100,4'bxxxx,9'b001010000,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("I=121 A-B-1",                 4'b0101,4'b0111,9'b001010001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);
	  tester("I=121 A-B",                   4'b0101,4'b0111,9'b001010001,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=122 -Q-1",                  4'bxxxx,4'bxxxx,9'b001010010,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0001);
	  tester("I=122 -Q",                    4'bxxxx,4'bxxxx,9'b001010010,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0010);
	  tester("I=123 -B-1",                  4'bxxxx,4'b1000,9'b001010011,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=123 -B",                    4'bxxxx,4'b1000,9'b001010011,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("I=124 -A-1",                  4'b0110,4'bxxxx,9'b001010100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=124 -A",                    4'b0110,4'bxxxx,9'b001010100,4'bxxxx, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=125 D-A-1",                 4'b0111,4'bxxxx,9'b001010101,4'b0111, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("I=125 D-A",                   4'b0111,4'bxxxx,9'b001010101,4'b0111, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=126 D-Q-1",                 4'bxxxx,4'bxxxx,9'b001010110,4'b1001, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=126 D-Q",                   4'bxxxx,4'bxxxx,9'b001010110,4'b1001, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("I=127 D-1",                   4'bxxxx,4'bxxxx,9'b001010111,4'b1010, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=127 D",                     4'bxxxx,4'bxxxx,9'b001010111,4'b1010, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=130 A|Q",                   4'b1000,4'bxxxx,9'b001011000,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=131 A|B",                   4'b1001,4'b1001,9'b001011001,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=132 Q",                     4'bxxxx,4'bxxxx,9'b001011010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=133 B",                     4'bxxxx,4'b1010,9'b001011011,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=134 A",                     4'b1010,4'bxxxx,9'b001011100,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=135 D|A",                   4'b1011,4'bxxxx,9'b001011101,4'b1011, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("I=136 D|Q",                   4'bxxxx,4'bxxxx,9'b001011110,4'b1100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=137 D",                     4'bxxxx,4'bxxxx,9'b001011111,4'b1101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=140 A&Q",                   4'b1100,4'bxxxx,9'b001100000,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1100);
	  tester("I=141 A&B",                   4'b1101,4'b1011,9'b001100001,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=142 0",                     4'bxxxx,4'bxxxx,9'b001100010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=143 0",                     4'bxxxx,4'bxxxx,9'b001100011,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=144 0",                     4'bxxxx,4'bxxxx,9'b001100100,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=145 D&A",                   4'b1110,4'bxxxx,9'b001100101,4'b1110, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=146 D&Q",                   4'bxxxx,4'bxxxx,9'b001100110,4'b1111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=147 0",                     4'bxxxx,4'bxxxx,9'b001100111,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=150 ~A&Q",                  4'b1111,4'bxxxx,9'b001101000,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=151 ~A&B",                  4'b0000,4'b1100,9'b001101001,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1100);
	  tester("I=152 Q",                     4'bxxxx,4'bxxxx,9'b001101010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=153 B",                     4'bxxxx,4'b1101,9'b001101011,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);
	  tester("I=154 A",                     4'b0001,4'bxxxx,9'b001101100,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0001);
	  tester("I=155 ~D&A",                  4'b0010,4'bxxxx,9'b001101101,4'b0000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0010);
	  tester("I=156 ~D&Q",                  4'bxxxx,4'bxxxx,9'b001101110,4'b0001, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=157 0",                     4'bxxxx,4'bxxxx,9'b001101111,4'b0010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=160 A^Q",                   4'b0011,4'bxxxx,9'b001110000,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1101);
	  tester("I=161 A^B",                   4'b0100,4'b1110,9'b001110001,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("I=162 Q",                     4'bxxxx,4'bxxxx,9'b001110010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=163 B",                     4'bxxxx,4'b1111,9'b001110011,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("I=164 A",                     4'b0101,4'bxxxx,9'b001110100,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=165 D^A",                   4'b0110,4'bxxxx,9'b001110101,4'b0011, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0101);
	  tester("I=166 D^Q",                   4'bxxxx,4'bxxxx,9'b001110110,4'b0101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("I=167 D",                     4'bxxxx,4'bxxxx,9'b001110111,4'b0110, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);

$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("I=170 A~^Q",                  4'b0111,4'bxxxx,9'b001111000,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  tester("I=171 A~^B",                  4'b1000,4'b0000,9'b001111001,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0111);
	  tester("I=172 ~Q",                    4'bxxxx,4'bxxxx,9'b001111010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0001);
	  tester("I=173 ~B",                    4'bxxxx,4'b0001,9'b001111011,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1110);
	  tester("I=174 ~A",                    4'b0111,4'bxxxx,9'b001111100,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1000);
	  tester("I=175 D~^A",                  4'b1000,4'bxxxx,9'b001111101,4'b0111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0000);
	  tester("I=176 D~^Q",                  4'bxxxx,4'bxxxx,9'b001111110,4'b1000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1001);
	  tester("I=177 ~D",                    4'bxxxx,4'bxxxx,9'b001111111,4'b1001, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b0110);
	  
	  $display("  Check destination ctrl (Figure 4 of data sheet)");
$display("-----: -a-- -b-- ----i---- -d-- ~oe ci r0 r3 q0 q3 cp | -y-- ov f0 f3 c4 ~g ~p r0 r3 q0 q3 | description");
	  tester("QREG: A+B->Q",                4'b1001,4'b0010,9'b000000001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("NOP: Q->Y",                   4'bxxxx,4'bxxxx,9'b001011010,4'bxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1011);
	  tester("RAMA: A+B->B, A->Y",          4'b1010,4'b0011,9'b010000001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1010);
	  tester("RAMF: A+B->B,Y",              4'b1011,4'b0100,9'b011000001,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 4'b1111);
	  tester("RAMQD: A/2->B, A->Y, Q/2->Q", 4'b1100,4'b0101,9'b100000100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'b0, 1'bz, 1'b0, 4'b1100);
	  tester("RAMD: A/2->B, A->Y",          4'b1101,4'b0110,9'b101000100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'b1, 4'b1101);
	  tester("RAMQU: 2A->B, A->Y, 2Q->Q",   4'b1110,4'b0111,9'b110000100,4'bxxxx, 1'b0, 1'b0, 1'b1, 1'bz, 1'b0, 1'bz, 4'b1110);
	  tester("RAMU: 2A->B, A->Y",           4'b1111,4'b1000,9'b111000100,4'bxxxx, 1'b0, 1'b0, 1'bz, 1'bz, 1'b1, 1'bz, 4'b1111);

	  #10 $finish;
end

endmodule
