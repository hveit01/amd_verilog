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

`include "am2909.v"

// 4 bit am2909 test
module am2909_testbench;

reg [3:0] din;
reg [3:0] rin;
reg [3:0] orin;
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

`define HEADER\
    $display("-time: -d-- -r-- -or- -cn- -oe- -zr- -re- -fe- -pup -s-- -cp | -y-- -c4- | -upc -sp- stk0 stk1 stk2 stk3 |")

`define SHOW(clk, descr)\
    $display("%5g: %4b %4b %4b  %1b    %1b    %1b    %1b    %1b     %1b   %2b   %0s  | %4b  %1b   | %4b  %2b  %4b %4b %4b %4b | %0s",\
             $time,din,rin,orin,cn,    oe_,   zero_, re_,   fe_,    pup,  s,    clk,   y,   cn4,    dut.upc, dut.sp, dut.stack[dut.sp], dut.stack[(dut.sp-1)&2'b11], dut.stack[(dut.sp-2)&2'b11], dut.stack[(dut.sp-3)&2'b11], descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       
             
am2909 #(.WIDTH(4)) dut(
	.din 	(din),
	.rin	(rin),
	.orin	(orin),
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
	input [3:0] rval;
	input [3:0] oval;
	input cnval;
	input oeval;
	input zval;
	input reval;
	input [1:0] sval;
	input feval;
	input pupval;
    input [3:0] expy;
	begin
		din <= dval;
		rin <= rval;
		orin <= oval;
		cn <= cnval;
		oe_ <= oeval;
		zero_ <= zval;
		re_ <= reval;
		fe_ <= feval;
		pup <= pupval;
		s <= sval;
		cp <= 1'b0;
		#1 `SHOW(" ", "");
		cp <= 1'b1;
		#1 `SHOW("^", descr);
        
        `assert("Y", y, expy);      
        
		cp <= 1'b0;
		#1 `SHOW(" ", "");
		$display("");
	end
endtask

initial begin
	//Dump results of the simulation to am2909.vcd
	$dumpfile("am2909.vcd");
	$dumpvars;

`HEADER;
//                              --din-- --rin-- -orin-- -cn- -oe- -zr- -re-  --s-- -fe- -pup -expy-
	$display("  Check OE, ZERO, OR"); 
	tester("Y DISABLE",         4'bxxxx,4'bxxxx,4'bxxxx,1'bx,1'b1,1'bx,1'bx, 2'bxx,1'b1,1'bx,'bZZZZ);
	tester("ZERO->Y",           4'bxxxx,4'bxxxx,4'bxxxx,1'bx,1'b0,1'b0,1'bx, 2'bxx,1'b1,1'bx,'b0000);
	tester("ORIN=H->Y",         4'bxxxx,4'bxxxx,4'b1111,1'bx,1'b0,1'b1,1'bx, 2'bxx,1'b1,1'bx,'b1111);
	tester("ORIN=L->Y",         4'b0000,4'bxxxx,4'b0000,1'bx,1'b0,1'b1,1'bx, 2'b11,1'b1,1'bx,'b0000);
	$display("  Check DIN");
	tester("DIN=5->Y",          4'b0101,4'bxxxx,4'b0000,1'bx,1'b0,1'b1,1'bx, 2'b11,1'b1,1'bx,'b0101);
	$display("  Load AR");
	tester("LOAD AREG",         4'bxxxx,4'b1010,4'b0000,1'b1,1'b0,1'b1,1'b0, 2'b01,1'b1,1'bx,'b1010);
	$display("  Check uPC");
	tester("CLEAR uPC",         4'bxxxx,4'bxxxx,4'bxxxx,1'b0,1'b0,1'b0,1'b1, 2'bxx,1'b1,1'bx,'b0000);
	tester("INC uPC",           4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx,'b0001);
	tester("INC uPC",           4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx,'b0010);
	$display("  Fill Stack");
	tester("PUSH uPC, INC",     4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1,'b0011);
	tester("PUSH uPC, INC",     4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1,'b0100);
	tester("PUSH uPC, INC",     4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1,'b0101);
	tester("PUSH uPC, INC",     4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1,'b0110);
	$display("  Run sequence in Figure 6 of data sheet");
	tester("End Loop",          4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b0,'b0111);
	tester("Set-up Loop",       4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b0,1'b1,'b1000);
	tester("Continue",          4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b00,1'b1,1'bx,'b1001);
	tester("End Loop",          4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b0,1'b0,'b1010);
	tester("JSR AR",            4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b0,1'b1,'b1010);
	tester("JMP AR",            4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b01,1'b1,1'bx,'b1010);
	tester("RTS",               4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b0,1'b0,'b0100);
	tester("JMP STK0, PUSH uPC",4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b0,1'b1,'b1100);
	tester("Stack Ref (Loop)",  4'bxxxx,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b10,1'b1,1'bx,'b1100);
	tester("End Loop, JMP D",   4'b1110,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b0,1'b0,'b1110);
	tester("JSR D",             4'b1101,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b0,1'b1,'b1101);
	tester("JMP D",             4'b1100,4'bxxxx,4'b0000,1'b1,1'b0,1'b1,1'b1, 2'b11,1'b1,1'bx,'b1100);
	#10 $finish;
end

endmodule
