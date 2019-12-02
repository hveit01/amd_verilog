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

`include "am2911.v"

// 4 bit am2911 test
module am2911_testbench;

reg [3:0] din;
reg cp;
reg cn;
reg oe_;
reg zero_;
reg re_;
reg fe_;
reg pup;
reg [1:0] s;
wire [3:0] y;
wire cn4;

am2911 #(.WIDTH(4)) dut(
	.din 	(din),
	.cp		(cp),
	.cn		(cn),
	.oe_	(oe_),
	.zero_	(zero_),
	.re_	(re_),
	.fe_	(fe_),
	.pup	(pup),
	.s		(s),
	.y		(y),
	.cn4	(cn4)
);

task tester;
	input [80*8-1:0] descr;
	input [3:0] dval;
	input cnval;
	input oeval;
	input zval;
	input reval;
	input [1:0] sval;
	input feval;
	input pupval;
	begin
		din <= dval;
		cn <= cnval;
		oe_ <= oeval;
		zero_ <= zval;
		re_ <= reval;
		fe_ <= feval;
		pup <= pupval;
		s <= sval;
		cp <= 1'b0;
		#1 $display("%5g: %4b  %1b    %1b    %1b    %1b    %1b     %1b   %2b   0   | %4b  %1b   | %4b  %2b  %4b %4b %4b %4b | %0s",
				    $time,din, cn,    oe_,   zero_, re_,   fe_,    pup,  s,          y,   cn4,    dut.upc, dut.sp, dut.stack[dut.sp], dut.stack[(dut.sp-1)&2'b11], dut.stack[(dut.sp-2)&2'b11], dut.stack[(dut.sp-3)&2'b11], descr);
		cp <= 1'b1;
		#1 $display("%5g: %4b  %1b    %1b    %1b    %1b    %1b     %1b   %2b   r   | %4b  %1b   | %4b  %2b  %4b %4b %4b %4b |",
				    $time,din, cn,    oe_,   zero_, re_,   fe_,    pup,  s,          y,   cn4,    dut.upc, dut.sp, dut.stack[dut.sp], dut.stack[(dut.sp-1)&2'b11], dut.stack[(dut.sp-2)&2'b11], dut.stack[(dut.sp-3)&2'b11]);
		cp <= 1'b0;
		#1 $display("%5g: %4b  %1b    %1b    %1b    %1b    %1b     %1b   %2b   f   | %4b  %1b   | %4b  %2b  %4b %4b %4b %4b |",
				    $time,din, cn,    oe_,   zero_, re_,   fe_,    pup,  s,          y,   cn4,    dut.upc, dut.sp, dut.stack[dut.sp], dut.stack[(dut.sp-1)&2'b11], dut.stack[(dut.sp-2)&2'b11], dut.stack[(dut.sp-3)&2'b11]);
		$display("");
	end
endtask

initial begin
	//Dump results of the simulation to am2911.vcde
	$dumpfile("am2911.vcd");
	$dumpvars;

    $display("-time: -d-- -cn- -oe- -zr- -re- -fe- -pup -s-- -cp- | -y-- -c4- | -upc -sp- stk0 stk1 stk2 stk3 |");
//                              --din-- -cn- -oe- -zr- -re-  --s-- -fe- -pup
	$display("  Check OE, ZERO, OR"); 
	tester("Y DISABLE",         4'bxxxx,1'bx,1'b1,1'bx,1'bx, 2'bxx,1'b1,1'bx);
	tester("ZERO->Y",           4'bxxxx,1'bx,1'b0,1'b0,1'bx, 2'bxx,1'b1,1'bx);
	$display("  Check DIN");
	tester("DIN=5->Y",          4'b0101,1'bx,1'b0,1'b1,1'bx, 2'b11,1'b1,1'bx);
	$display("  Load AR");
	tester("LOAD AREG",         4'b1010,1'b1,1'b0,1'b1,1'b0, 2'b01,1'b1,1'bx);
	$display("  Check uPC");
	tester("CLEAR uPC",         4'bxxxx,1'b0,1'b0,1'b0,1'b1, 2'bxx,1'b1,1'bx);
	tester("INC uPC",           4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx);
	tester("INC uPC",           4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx);
	$display("  Fill Stack");
	tester("PUSH uPC, INC",     4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1);
	tester("PUSH uPC, INC",     4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1);
	tester("PUSH uPC, INC",     4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1);
	tester("PUSH uPC, INC",     4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1);
	$display("  Run sequence in Figure 6 of data sheet");
	tester("End Loop",          4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b0);
	tester("Set-up Loop",       4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1);
	tester("Continue",          4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx);
	tester("End Loop",          4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b0,1'b0);
	tester("JSR AR",            4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b0,1'b1);
	tester("JMP AR",            4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b1,1'bx);
	tester("RTS",               4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b0,1'b0);
	tester("JMP STK0, PUSH uPC",4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b0,1'b1);
	tester("Stack Ref (Loop)",  4'bxxxx,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b1,1'bx);
	tester("End Loop, JMP D",   4'b1110,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b0,1'b0);
	tester("JSR D",             4'b1101,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b0,1'b1);
	tester("JMP D",             4'b1100,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b1,1'bx);
	#10 $finish;
end

endmodule
