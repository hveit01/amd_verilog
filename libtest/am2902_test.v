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

// am2902 testbench
`include "am2902.v"

module am2902_testbench;

reg [3:0] g, p;
reg cn;

wire go, po;
wire cnx, cny, cnz;

am2902 dut(
		.cn		(cn),
		.g_		(g),
		.p_		(p),

		.cnx	(cnx),
		.cny	(cny),
		.cnz	(cnz),
		.go_	(go),
		.po_	(po)
);

task tester;
	input [80*8-1:0] descr;
	input [3:0] gval, pval;
	input cnval;
	begin
		g <= gval;
		p <= pval;
		cn <= cnval;

		#1 $display("%5g: %4b %4b %1b  |  %1b   %1b   %1b  %1b  %1b  | %0s",
					$time, g, p,  cn,   cnx,cny,cnz,go, po,   descr);
	end
endtask

initial begin
$display("-----: -g-- -p-- cn | cnx cny cnz go po | description");
//                                     ---g--- ---p--- -cn- --din--  -oe-  -cin- -q0-  -q3-  -r0-  -r3- 	



	tester("CNX = high",             4'bxxx0,4'bxxxx,1'bx);
	tester("",                       4'bxxxx,4'bxxx0,1'b1);
	tester("CNX = low",              4'bxxx1,4'bxxx1,1'bx);
	tester("",                       4'bxxx1,4'bxxxx,1'b0);
 	tester("CNY = high",             4'bxx0x,4'bxxxx,1'bx);
	tester("",                       4'bxxx0,4'bxx0x,1'bx);
	tester("",                       4'bxxxx,4'bxx00,1'b1);
	tester("CNY = low",              4'bxx1x,4'bxx1x,1'bx);
	tester("",                       4'bxx11,4'bxxx1,1'bx);
	tester("",                       4'bxx11,4'bxxxx,1'b0);
 	tester("CNZ = high",             4'bx0xx,4'bxxxx,1'bx);
	tester("",                       4'bxx0x,4'bx0xx,1'bx);
	tester("",                       4'bxxx0,4'bx00x,1'bx);
	tester("",                       4'bxxxx,4'bx000,1'b1);
	tester("CNZ = low",              4'bx1xx,4'bx1xx,1'bx);
	tester("",                       4'bx11x,4'bxx1x,1'bx);
	tester("",                       4'bx111,4'bxxx1,1'bx);
	tester("",                       4'bx111,4'bxxxx,1'b0);
	tester("GO = high",              4'b1xxx,4'b1xxx,1'bx);
	tester("",                       4'b11xx,4'bx1xx,1'bx);
	tester("",                       4'b111x,4'bxx1x,1'bx);
	tester("",                       4'b1111,4'bxxxx,1'bx);
	tester("GO = low",               4'b0xxx,4'bxxxx,1'bx);
	tester("",                       4'bx0xx,4'b0xxx,1'bx);
	tester("",                       4'bxx0x,4'b00xx,1'bx);
	tester("",                       4'bxxx0,4'b000x,1'bx);
	tester("PO = high",              4'bxxxx,4'bxxx1,1'bx);
	tester("",                       4'bxxxx,4'bxx1x,1'bx);
	tester("",                       4'bxxxx,4'bx1xx,1'bx);
	tester("",                       4'bxxxx,4'b1xxx,1'bx);
	tester("PO = low",               4'bxxxx,4'b0000,1'bx);
	
	#10 $finish;
end

endmodule
