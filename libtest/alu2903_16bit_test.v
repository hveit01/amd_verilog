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

// am2903/am2902 testbench 16 bit size
`include "am2903.v"
`include "am2902.v"

`define HEADER(x)\
    $display("Test %0s", x);\
    $display("-----: -a-- -b-- ----i---- -da- -db- ~ea oeb oey cin -q0 q15 -s0 s15 | -y-- ovr -z- -n- c15 | --test description--");

// checks basic operations that do not need special wiring

module alu2903_16bit_testbench;

// test inputs
reg [3:0] a, b;
reg [8:0] i;
reg [15:0] dai, dbi, yi;
reg oey, oeb, ea, ien;
reg cn;
reg cp;
reg qio0i, qio15i;
reg sio0i, sio15i;

// test outputs
wire [15:0] da, db, y;
wire q0, q15;
wire sio0, sio15;
wire z, cn4, n, ovr;
wire we;

// internal connections
wire [3:0] zi;
wire [3:0] gi, pi;
wire [4:0] cni;
wire [4:0] qio;
wire [4:0] sio;

// instantiate carry lookahead generator
am2902 cgen(
	.cn(cn),
	.g_(gi), 
	.p_(pi),
	.cnx(cni[1]), .cny(cni[2]), .cnz(cni[3])
//	, .go_(), .po_()
);

// mss
assign wrmss = 1'b0;
am2903 bit15_12(
    .a(a), .b(b), .da(da[15:12]), .db(db[15:12]),
    .i(i), .ien_(ien),
    .lss_(1'b1), .wrmss_(wrmss), .we_(we), .ea_(ea), .oeb_(oeb), .cn(cni[3]),
    .gn(n), .povr(ovr), .z(zi[3]), .cn4(cn15),
    .qio0(qio[3]), .qio3(qio[4]), .sio0(sio[3]), .sio3(sio[4]),
    .y(y[15:12]), .oey_(oey),
    .cp(cp)
);

// is1
assign wriss = 1'b1;
am2903 bit11_8(
    .a(a), .b(b), .da(da[11:8]), .db(db[11:8]),
    .i(i), .ien_(ien),
    .lss_(1'b1), .wrmss_(wriss), .we_(we), .ea_(ea), .oeb_(oeb), .cn(cni[2]),
    .gn(gi[2]), .povr(pi[2]), .z(zi[2]),
    .qio0(qio[2]), .qio3(qio[3]), .sio0(sio[2]), .sio3(sio[3]),
    .y(y[11:8]), .oey_(oey),
    .cp(cp)
);

// is2
am2903 bit7_4(
    .a(a), .b(b), .da(da[7:4]), .db(db[7:4]),
    .i(i), .ien_(ien),
    .lss_(1'b1), .wrmss_(wriss), .we_(we), .ea_(ea), .oeb_(oeb), .cn(cni[1]),
    .gn(gi[1]), .povr(pi[1]), .z(zi[1]), 
    .qio0(qio[1]), .qio3(qio[2]), .sio0(sio[1]), .sio3(sio[2]),
    .y(y[7:4]), .oey_(oey),
    .cp(cp)
);

// lss
am2903 bit3_0(
    .a(a), .b(b), .da(da[3:0]), .db(db[3:0]),
    .i(i), .ien_(ien),
    .lss_(1'b0), .wrmss_(we), .we_(we), .ea_(ea), .oeb_(oeb), .cn(cn),
    .gn(gi[0]), .povr(pi[0]), .z(zi[0]),
    .qio0(qio[0]), .qio3(qio[1]), .sio0(sio[0]), .sio3(sio[1]),
    .y(y[3:0]), .oey_(oey),
    .cp(cp)
);

// connect carry in and zero
assign cni[0] = cn;
assign z = &zi;

// connect SIO0/3
assign sio[0] = sio0i;
assign sio15 = sio[4];
assign sio[4] = sio15i;
assign sio0 = sio[0];

// connect QIO0/QIO3
assign qio[0] = qio0i;
assign qio15 = qio[4];
assign qio[4] = qio15i;
assign qio0 = qio[0];

// connect da, db, y
assign da = dai;
assign db = dbi;
assign y = yi;

initial begin
	$dumpfile("alu2903_16bit.vcd");
	$dumpvars;
end

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval, bval;
	input [8:0] ival;
	input [15:0] daval, dbval, yval;
	input eaval, oebval, oeyval;
	input cnval;
	input qio0val, qio15val, sio0val, sio15val;
	input [15:0] expecty;
	begin
		a <= aval;
		b <= bval;
		i <= ival;
        ien <= 1'b0;
		dai <= daval;
		dbi <= dbval;
        yi <= yval;
        ea <= eaval;
		oeb <= oebval;
		oey <= oeyval;
		cn <= cnval;
		qio0i <= qio0val;
		qio15i <= qio15val;
		sio0i <= sio0val;
		sio15i <= sio15val;
		cp <= 0;
		#1 cp <= 1;
		#1 cp <= 0;
		$display("%5g: %4b %4b %9b %4h %4h  %1b   %1b   %1b   %1b   %1b   %1b   %1b   %1b  | %4h  %1b   %1b   %1b   %1b  | %0s",
		         $time, a, b,  i,  da,  db,  ea,  oeb,  oey,  cn,   qio0, qio15,sio0, sio15,  y,  ovr,   z,    n,   cn15,  descr);
		if (expecty !== y) begin
			$display("Error: y should be H'%4h, but is H'%4h", expecty, y);
		end
	end
endtask

task init;
	input [3:0] aval, bval;
	input [8:0] ival;
	input [15:0] daval, dbval, yval;
	input eaval, oebval, oeyval;
	input cnval;
	input qio0val, qio15val, sio0val, sio15val;
	input [15:0] expecty;
	begin
		a <= aval;
		b <= bval;
		i <= ival;
        ien <= 1'b0;
		dai <= daval;
		dbi <= dbval;
        yi <= yval;
        ea <= eaval;
		oeb <= oebval;
		oey <= oeyval;
		cn <= cnval;
		qio0i <= qio0val;
		qio15i <= qio15val;
		sio0i <= sio0val;
		sio15i <= sio15val;
		cp <= 0;
		#1 cp <= 1;
		#1 cp <= 0;
		$display("%5g: %4b %4b %9b %4h %4h  %1b   %1b   %1b   %1b   %1b   %1b   %1b   %1b  | %4h  %1b   %1b   %1b   %1b",
		         $time, a, b,  i,  da,  db,  ea,  oeb,  oey,  cn,   qio0, qio15,sio0, sio15,  y,  ovr,   z,    n,   cn15);
		if (expecty !== y) begin
			$display("Error: y should be %16b, but is %16b", expecty, y);
		end
	end
endtask

initial begin
//                                        ---a--- ---b--- -----i------ ---da--- ---db--- ----y--- -ea- -oeb -oey -cin -q0- -q3- -s0- -s3- --expy--
    `HEADER("OEy enable");
	tester("OE disable",                  4'bxxxx,4'bxxxx,9'bXXXXXXXXX,16'hXXXX,16'hXXXX,16'hZZZZ,'bX, 'bX, 'b1, 'bX, 'bX, 'bX, 'bX, 'bX, 16'hZZZZ);
	tester("Y = DA+0",                    4'bxxxx,4'bxxxx,9'b110000110,16'h0F5A,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h0F5A);
	tester("Y = DB+0+C(1)",               4'bxxxx,4'bxxxx,9'b110000110,16'h0000,16'hC33C,16'hZZZZ,'b1, 'b1, 'b0, 'b1, 'bX, 'bX, 'bX, 'bX, 16'hC33D);  
  	`HEADER("addition");
//                                        ---a--- ---b--- -----i------ ---da--- ---db--- ----y--- -ea- -oeb -oey -cin -q0- -q3- -s0- -s3- --expy--
	init(                                 4'bxxxx,4'b0000,9'b111111110,16'h1111,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'bX, 'bX, 'bX, 'bX, 'bX, 16'h1111);
	tester("Add no carry",                4'b0000,4'bxxxx,9'b110000110,16'hZZZZ,16'h1111,16'hZZZZ,'b0, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h2222);
	init(                                 4'bxxxx,4'b0000,9'b111111110,16'h0008,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'bX, 'bX, 'bX, 'bX, 'bX, 16'h0008);
	tester("Carry into slice 2",          4'b0000,4'bxxxx,9'b110000110,16'hZZZZ,16'h0008,16'hZZZZ,'b0, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h0010);
	init(                                 4'bxxxx,4'b0000,9'b111111110,16'h0080,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'bX, 'bX, 'bX, 'bX, 'bX, 16'h0080);
	tester("Carry into slice 3",          4'b0000,4'bxxxx,9'b110000110,16'hZZZZ,16'h0080,16'hZZZZ,'b0, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h0100);
	init(                                 4'bxxxx,4'b0000,9'b111111110,16'h0800,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'bX, 'bX, 'bX, 'bX, 'bX, 16'h0800);
	tester("Carry into slice 4",          4'b0000,4'bxxxx,9'b110000110,16'hZZZZ,16'h0800,16'hZZZZ,'b0, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h1000);
	init(                                 4'bxxxx,4'b0000,9'b111111110,16'h8000,16'h0000,16'hZZZZ,'b1, 'b1, 'b0, 'bX, 'bX, 'bX, 'bX, 'bX, 16'h8000);
	tester("Carry out",                   4'b0000,4'bxxxx,9'b110000110,16'hZZZZ,16'h8000,16'hZZZZ,'b0, 'b1, 'b0, 'b0, 'bX, 'bX, 'bX, 'bX, 16'h0000);

//    $display("subtraction");
//                                        ---a--- ---b--- -----i------ ---da--- ---db--- ----y--- -ea- -oeb -oey -cin -q0- -q3- -s0- -s3- --expy--
//	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
//	  tester("Subtract no carry",           4'b0000,4'bxxxx,9'b001001101,16'b0110010101000011, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001000100010001);
//	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
//	  tester("Borrow from slice 2",         4'b0000,4'bxxxx,9'b001001101,16'b0111011001010101, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111111111111);
//	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
//	  tester("Borrow from slice 3",         4'b0000,4'bxxxx,9'b001001101,16'b0111011001100100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111111110000);
//	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
//	  tester("Borrow from slice 4",         4'b0000,4'bxxxx,9'b001001101,16'b0111011101010100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111111100000000);
//	  init(                                 4'bxxxx,4'b0000,9'b011011111,16'b0111011001010100, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0111011001010100);
//	  tester("Borrow from bit 16",          4'b0000,4'bxxxx,9'b001001101,16'b1000011001010100, 1'b0, 1'b1, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1111000000000000);

//	  $display("shifters");
//	  tester("Load Q",                      4'bxxxx,4'bxxxx,9'b000011111,16'b1010101010101010, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1010101010101010);
//	  tester("Load A",                      4'bxxxx,4'b0000,9'b011011111,16'b0000111100001111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000111100001111);
//	  init(                                 4'bxxxx,4'b0001,9'b011011111,16'b0000000000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000000000); // clear B
//	  tester("RAMQD, Y = A",                4'b0000,4'b0001,9'b100011100,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'b0, 1'bz, 1'b1, 16'b0000111100001111);
//	  tester("B = A/2 (shift in 1)",        4'bxxxx,4'b0001,9'b001011011,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1000011110000111);
//	  tester("Q = Q/2 (shift in 0)",        4'bxxxx,4'bxxxx,9'b001011010,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0101010101010101);

//	  tester("Load Q",                      4'bxxxx,4'bxxxx,9'b000011111,16'b0000111100001111, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000111100001111);
//	  tester("Load A",                      4'bxxxx,4'b0000,9'b011011111,16'b0101010101010101, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0101010101010101);
//	  init(                                 4'bxxxx,4'b0001,9'b011011111,16'b0000000000000000, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0000000000000000); // clear B
//	  tester("RAMQU, Y = A",                4'b0000,4'b0001,9'b110011100,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'b1, 1'bz, 1'b0, 1'bz, 16'b0101010101010101);
//	  tester("B = 2*A (shift in 0)",        4'bxxxx,4'b0001,9'b001011011,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b1010101010101010);
//	  tester("Q = 2*Q (shift in 1)",        4'bxxxx,4'bxxxx,9'b001011010,16'bxxxxxxxxxxxxxxxx, 1'b0, 1'bx, 1'bz, 1'bz, 1'bz, 1'bz, 16'b0001111000011111);

	  #10 $finish;
end

endmodule
