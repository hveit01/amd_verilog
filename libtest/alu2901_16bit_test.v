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

// am2901/am2902 testbench 16 bit size
`include "am2901.v"
`include "am2902.v"

module alu2901_16bit_testbench;

genvar k;

// test inputs
reg [3:0] a, b;
reg [8:0] i;
reg [15:0] din;
reg oe_;
reg cn;
reg cp;
reg q0i, q15i;
reg ram0i, ram15i;
wire q0, q15;
wire ram0, ram15;


// test outputs
wire [15:0] y;
wire f0;
wire f15;
wire cn15;
wire ovr;

// internal connections
wire [3:0] gi, pi;
wire [3:0] cni, cni4;
wire [4:0] q;
wire [4:0] ram;
wire [3:0] ovi;
wire [3:0] f0i;
wire [3:0] f3i;

// instantiate carry lookahead generator
am2902 cgen(
	.cn(cni[0]),
	.g_(gi), 
	.p_(pi),
	.cnx(cni[1]), .cny(cni[2]), .cnz(cni[3])
//	, .go_(), .po_()
);

// connect carry in and carry out
assign cni[0] = cn;
assign cn15 = cni4[3];

// connect RAM0/3
assign ram[0] = ram0i;
assign ram15 = ram[4];
assign ram[4] = ram15i;
assign ram0 = ram[0];

// connect Q0/Q3
assign q[0] = q0i;
assign q15 = q[4];
assign q[4] = q15i;
assign q0 = q[0];

// connect SIGN(f15) and ZERO(f0) flags
// note: am2901 does not implement F0 as open collector, so we join all of them through an AND
assign f15 = f3i[3];
assign f0 = &f0i;  // f0=1 if slice output is 0000

// connect overflow, upper slice
assign ovr = ovi[3];

// generate an wire 4 slices
for(k=0; k<4; k=k+1) begin : slice
	am2901 alu(
		.a(a), .b(b), .i(i),
		.din(din[k*4+3:k*4]),
		.oe_(oe_), .cn(cni[k]), .cp(cp),
		.q0(q[k]), .q3(q[k+1]),
		.ram0(ram[k]), .ram3(ram[k+1]),
		.y(y[k*4+3:k*4]),
		.ovr(ovi[k]), .f0(f0i[k]), .f3(f3i[k]), .cn4(cni4[k]),
		.g_(gi[k]), .p_(pi[k])
	);
end

initial begin
	$dumpfile("alu2901_16bit.vcd");
	$dumpvars;
end

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval, bval;
	input [8:0] ival;
	input [15:0] dval;
	input oe_val;
	input cnval;
	input q0val, q3val, ram0val,ram15val;
	input [15:0] expecty;
	begin
		a <= aval;
		b <= bval;
		i <= ival;
		din <= dval;
		oe_ <= oe_val;
		cn <= cnval;
		q0i <= q0val;
		q15i <= q3val;
		ram0i <= ram0val;
		ram15i <= ram15val;
		cp <= 0;

		#1 cp <= 1;
		#1 cp <= 0;
		$display("%5g: %4b %4b %9b %16b  %1b  %1b  %1b  %1b   %1b  %1b   | %16b %1b  %1b  %1b   %1b   | %0s",
		         $time, a, b,  i,  din,  oe_, cn,  q0,  q15,  ram0,ram15,  y,   ovr, f0,  f15,  cn15,   descr);
		if (expecty != y) begin
			$display("Error: y should be %4b, but is %4b", expecty, y);
		end
	end
endtask

task init;
	input [3:0] aval, bval;
	input [8:0] ival;
	input [15:0] dval;
	input oe_val;
	input cnval;
	input q0val, q3val, ram0val,ram15val;
	input [15:0] expecty;
	begin
		a <= aval;
		b <= bval;
		i <= ival;
		din <= dval;
		oe_ <= oe_val;
		cn <= cnval;
		q0i <= q0val;
		q15i <= q3val;
		ram0i <= ram0val;
		ram15i <= ram15val;
		cp <= 0;

		#1 cp <= 1;
		#1 cp <= 0;
		if (expecty != y) begin
			$display("Error: y should be %4b, but is %4b", expecty, y);
		end
	end
endtask

initial begin
//                                          ---a--- ---b--- -----i------ --din--------------  -oe-  -cin- -q0-  -q3-  -r0-  -r3-
	  $display();
      $display("  Test DIN");
$display("-----: -a-- -b-- ----i---- -d-------------- ~oe ci q0 q15 r0 r15 | -y-------------- ov f0 f15 c15 | --test description--");
	  tester("OE disable",                  4'bxxxx,4'bxxxx,9'b001011111,16'bxxxxxxxxxxxxxxxx, 1'b1, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'bzzzzzzzzzzzzzzzz);
	  tester("Y = DIN",                     4'bxxxx,4'bxxxx,9'b001011111,16'b0000111101011010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000111101011010);
	  
	  $display();
  	  $display("  Check addition");
$display("-----: -a-- -b-- ----i---- -d-------------- ~oe ci q0 q15 r0 r15 | -y-------------- ov f0 f15 c15 | --test description--");
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0001000100010001, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001000100010001);
	  tester("Add no carry",                4'b0000,4'bxxxx,9'b001000101,16'b0001000100010001, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0010001000100010);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0000000000001000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000001000);
	  tester("Carry into slice 2",          4'b0000,4'bxxxx,9'b001000101,16'b0000000000001000, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000010000);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0000000010000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000010000000);
	  tester("Carry into slice 3",          4'b0000,4'bxxxx,9'b001000101,16'b0000000010000000, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000100000000);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0000100000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000100000000000);
	  tester("Carry into slice 4",          4'b0000,4'bxxxx,9'b001000101,16'b0000100000000000, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001000000000000);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b1000000000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1000000000000000);
	  tester("Carry out",                   4'b0000,4'bxxxx,9'b001000101,16'b1000000000000000, 1'b0, 1'b0, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000000000);

	  $display();
    $display("  Check subtraction");
$display("-----: -a-- -b-- ----i---- -d-------------- ~oe ci q0 q15 r0 r15 | -y-------------- ov f0 f15 c15 | --test description--");
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
	  tester("Subtract no carry",           4'b0000,4'bxxxx,9'b001001101,16'b0110010101000011, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001000100010001);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
	  tester("Borrow from slice 2",         4'b0000,4'bxxxx,9'b001001101,16'b0111011001010101, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111111111111);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
	  tester("Borrow from slice 3",         4'b0000,4'bxxxx,9'b001001101,16'b0111011001100100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111111110000);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
	  tester("Borrow from slice 4",         4'b0000,4'bxxxx,9'b001001101,16'b0111011101010100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111100000000);
	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
	  tester("Borrow from bit 16",          4'b0000,4'bxxxx,9'b001001101,16'b1000011001010100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111000000000000);

	  $display();
	  $display("  Check Shifters");
$display("-----: -a-- -b-- ----i---- -d-------------- ~oe ci q0 q15 r0 r15 | -y-------------- ov f0 f15 c15 | --test description--");
	  tester("Load Q",                      4'bxxxx,4'bxxxx,9'b000011111,16'b1010101010101010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1010101010101010);
	  tester("Load A",                      4'bxxxx,4'b0000,9'b011011111,16'b0000111100001111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000111100001111);
	  init(                                 4'bxxxx,4'b0001,9'b011011111,16'b0000000000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000000000); // clear B
	  tester("RAMQD, Y = A",                4'b0000,4'b0001,9'b100011100,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'b0, 1'bz, 1'b1, 16'b0000111100001111);
	  tester("B = A/2 (shift in 1)",        4'bxxxx,4'b0001,9'b001011011,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1000011110000111);
	  tester("Q = Q/2 (shift in 0)",        4'bxxxx,4'bxxxx,9'b001011010,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0101010101010101);

	  tester("Load Q",                      4'bxxxx,4'bxxxx,9'b000011111,16'b0000111100001111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000111100001111);
	  tester("Load A",                      4'bxxxx,4'b0000,9'b011011111,16'b0101010101010101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0101010101010101);
	  init(                                 4'bxxxx,4'b0001,9'b011011111,16'b0000000000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000000000); // clear B
	  tester("RAMQU, Y = A",                4'b0000,4'b0001,9'b110011100,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'b1, 1'bz, 1'b0, 1'bz, 16'b0101010101010101);
	  tester("B = 2*A (shift in 0)",        4'bxxxx,4'b0001,9'b001011011,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1010101010101010);
	  tester("Q = 2*Q (shift in 1)",        4'bxxxx,4'bxxxx,9'b001011010,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001111000011111);

	  #10 $finish;
end

endmodule
