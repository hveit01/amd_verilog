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

// sn74181 ALU
`include "sn74181.v"

module sn74181_testbench;
reg [3:0] a, b;
reg [3:0] s;
reg m, cn_;

wire [3:0] f;
wire g, p, aeqb, cn4_;

sn74181 dut(
		.a		(a),
		.b		(b),
		.s		(s),
		.m		(m),
		.cn_	(cn_),
		.f		(f),
		.cn4_	(cn4_),
		.g		(g),
		.p		(p),
		.aeqb	(aeqb)
	);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

`define showvals\
		$display("%5g: %4b %4b %4b  %1b   %1b  | %4b  %1b   %1b   %1b   %1b   | %0s",\
		         $time,a,  b,  s,   m,    cn_,   f,   cn4_, g,    p,    aeqb,   descr);

task tester;
	input [80*8-1:0] descr;
	input [3:0] aval, bval, sval;
	input mval;
	input cnval;
	
	input [3:0] expectf;
	input expectcn4;

	begin
		a <= aval;
		b <= bval;
		s <= sval;
		m <= mval;
		cn_ <= cnval;
		#1 `showvals;
		`assert ("f", expectf, f);
		`assert ("cn4", expectcn4, cn4_);
	end
endtask

initial
begin
	//Dump results of the simulation to ff.cvd
	$dumpfile("sn74181.vcd");
	$dumpvars;

	$display("Logic functions");
    $display("-time: -a-- -b-- -s-- -m- cn_ | -f-- cn4  g   p  aeqb | descr");

//	                             ---a---  ---b--- ---s--- -m-- -cn- expectf expectcn
	tester ("f=!a",              4'b0011, 4'bxxxx,4'b0000,1'b1,1'bx,4'b1100,1'b1);
	tester ("f=!(a|b)",          4'b0011, 4'b0101,4'b0001,1'b1,1'bx,4'b1000,1'b1);
	tester ("f=!a&b",            4'b0011, 4'b0101,4'b0010,1'b1,1'bx,4'b0100,1'b1);
	tester ("f=0",               4'b1100, 4'b1010,4'b0011,1'b1,1'bx,4'b0000,1'bx);
	tester ("f=!(a&b)",          4'b0011, 4'b0101,4'b0100,1'b1,1'bx,4'b1110,1'b1);
	tester ("f=!b",              4'b1100, 4'b0101,4'b0101,1'b1,1'bx,4'b1010,1'b0);
	tester ("f=a^b",             4'b0011, 4'b0101,4'b0110,1'b1,1'bx,4'b0110,1'b1);
	tester ("f=a&!b",            4'b0011, 4'b0101,4'b0111,1'b1,1'bx,4'b0010,1'b0);
	tester ("f=!a|b",            4'b0011, 4'b0101,4'b1000,1'b1,1'bx,4'b1101,1'b1);
	tester ("f=!(a^b)",          4'b0011, 4'b0101,4'b1001,1'b1,1'bx,4'b1001,1'b1);
	tester ("f=b",               4'b1100, 4'b0101,4'b1010,1'b1,1'bx,4'b0101,1'b0);
	tester ("f=a&b",             4'b0011, 4'b0101,4'b1011,1'b1,1'bx,4'b0001,1'b0);
	tester ("f=1",               4'b1100, 4'b0101,4'b1100,1'b1,1'bx,4'b1111,1'b0);
	tester ("f=a|!b",            4'b0011, 4'b0101,4'b1101,1'b1,1'bx,4'b1011,1'b1);
	tester ("f=a|b",             4'b0011, 4'b0101,4'b1110,1'b1,1'bx,4'b0111,1'b1);
	tester ("f=a",               4'b0011, 4'b0101,4'b1111,1'b1,1'bx,4'b0011,1'b0);

	$display("Arithmetic functions");
    $display("-time: -a-- -b-- -s-- -m- cn_ | -f-- cn4  g   p  aeqb | descr");
	tester ("f=a",               4'b0011, 4'b0101,4'b0000,1'b0,1'b1,4'b0011,1'b1);
	tester ("f=a+1",             4'b0011, 4'b0101,4'b0000,1'b0,1'b0,4'b0100,1'b1);
	tester ("f=a|b",             4'b0011, 4'b0101,4'b0001,1'b0,1'b1,4'b0111,1'b1);
	tester ("f=a|b+1",           4'b0011, 4'b0101,4'b0001,1'b0,1'b0,4'b1000,1'b1);
	tester ("f=a|!b",            4'b0011, 4'b0101,4'b0010,1'b0,1'b1,4'b1011,1'b1);
	tester ("f=a|!b+1",          4'b0011, 4'b0101,4'b0010,1'b0,1'b0,4'b1100,1'b1);
	tester ("f=-1",              4'b0011, 4'b0101,4'b0011,1'b0,1'b1,4'b1111,1'b1);
	tester ("f=0",               4'b0011, 4'b0101,4'b0011,1'b0,1'b0,4'b0000,1'b0);
	tester ("f=a+(a&!b)",        4'b0011, 4'b0101,4'b0100,1'b0,1'b1,4'b0101,1'b1);
	tester ("f=a+(a&!b)+1",      4'b0011, 4'b0101,4'b0100,1'b0,1'b0,4'b0110,1'b1);
	tester ("f=(a|b)+(a&!b)",    4'b0011, 4'b0101,4'b0101,1'b0,1'b1,4'b1001,1'b1);
	tester ("f=(a|b)+(a&!b)+1",  4'b0011, 4'b0101,4'b0101,1'b0,1'b0,4'b1010,1'b1);
	tester ("f=a-b-1",           4'b0011, 4'b0101,4'b0110,1'b0,1'b1,4'b1101,1'b1);
	tester ("f=a-b",             4'b0011, 4'b0101,4'b0110,1'b0,1'b0,4'b1110,1'b1);
	tester ("f=(a&!b)-1",        4'b0011, 4'b0101,4'b0111,1'b0,1'b1,4'b0001,1'b0);
	tester ("f=a&!b",            4'b0011, 4'b0101,4'b0111,1'b0,1'b0,4'b0010,1'b0);
	tester ("f=a+(a&b)",         4'b0011, 4'b0101,4'b1000,1'b0,1'b1,4'b0100,1'b1);
	tester ("f=a+(&b)+1",        4'b0011, 4'b0101,4'b1000,1'b0,1'b0,4'b0101,1'b1);
	tester ("f=a+b",             4'b0011, 4'b0101,4'b1001,1'b0,1'b1,4'b1000,1'b1);
	tester ("f=a+b+1",           4'b0011, 4'b0101,4'b1001,1'b0,1'b0,4'b1001,1'b1);
	tester ("f=(a|!b)+(a&b)",    4'b0011, 4'b0101,4'b1010,1'b0,1'b1,4'b1100,1'b1);
	tester ("f=(a|!b)+(a&b)+1",  4'b0011, 4'b0101,4'b1010,1'b0,1'b0,4'b1101,1'b1);
	tester ("f=(a&b)-1",         4'b0011, 4'b0101,4'b1011,1'b0,1'b1,4'b0000,1'b0);
	tester ("f=a&b",             4'b0011, 4'b0101,4'b1011,1'b0,1'b0,4'b0001,1'b0);
	tester ("f=a+a",             4'b0011, 4'b0101,4'b1100,1'b0,1'b1,4'b0110,1'b1);
	tester ("f=a+a+1",           4'b0011, 4'b0101,4'b1100,1'b0,1'b0,4'b0111,1'b1);
	tester ("f=(a|b)+a",         4'b0011, 4'b0101,4'b1101,1'b0,1'b1,4'b1010,1'b1);
	tester ("f=(a|b)+a+1a",      4'b0011, 4'b0101,4'b1101,1'b0,1'b0,4'b1011,1'b1);
	tester ("f=(a|!b)+a",        4'b0011, 4'b0101,4'b1110,1'b0,1'b1,4'b1110,1'b1);
	tester ("f=(a|!b)+a+1",      4'b0011, 4'b0101,4'b1110,1'b0,1'b0,4'b1111,1'b1);
	tester ("f=a-1",             4'b0011, 4'b0101,4'b1111,1'b0,1'b1,4'b0010,1'b0);
	tester ("f=a",               4'b0011, 4'b0101,4'b1111,1'b0,1'b0,4'b0011,1'b0);

	#10 $finish;
end

endmodule
