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

// am29811a next address generator
`include "am29811a.v"

module am29811a_testbench;

reg [3:0] i;
reg test;

wire [1:0] s;
wire fe_, pup;
wire ld_, e_;
wire me_, pe_;

am29811a dut(
	.i			(i),
	.test		(test),
	.s			(s),
	.fe_		(fe_),
	.pup		(pup),
	.cntload_	(ld_),
	.cnte_		(e_),
	.mape_		(me_),
	.ple_		(pe_)
);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [3:0] ival;
	input testval;
	input [1:0] expect_s;
	input expect_fe, expect_pup, expect_ld, expect_e, expect_me, expect_pe;
	begin
		i <= ival;
		test <= testval;
		#1 $display("%5g: %4b  %1b   |  %2b  %1b%1b  %1b%1b   %1b  %1b  | %0s",
					$time,i,   test,    s,   fe_,pup,ld_,e_,  me_, pe_,   descr);
		`assert("s",   		expect_s,   s);
		`assert("fe_",		expect_fe,  fe_);
		`assert("pup",		expect_pup, pup);
		`assert("cntload_", expect_ld,	ld_);
		`assert("cnte_",	expect_e,	e_);
		`assert("mape_",	expect_me,	me_);
		`assert("ple_",		expect_pe,	pe_);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am29811a.vcd");
	$dumpvars;
	
$display("-time: -i-- test | nas file ctr map pl | description");

//                         ---d---  -test --s--  -fe-- -pup- -ld-- --e-- -me-- -pe-
	tester("JZ"          , 4'b0000, 1'bx, 2'b11, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0);
	$display;
	tester("CJS  test=0" , 4'b0001, 1'b0, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b0001, 1'b1, 2'b11, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("JMAP"        , 4'b0010, 1'bx, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1);
	$display;
	tester("CJP  test=0" , 4'b0011, 1'b0, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b0011, 1'b1, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("PUSH test=0" , 4'b0100, 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b0100, 1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0);
	$display;
	tester("JSRP test=0" , 4'b0101, 1'b0, 2'b01, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b0101, 1'b1, 2'b11, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("CJV  test=0" , 4'b0110, 1'b0, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1);
	tester("     test=1" , 4'b0110, 1'b1, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1);
	$display;
	tester("JRP  test=0" , 4'b0111, 1'b0, 2'b01, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b0111, 1'b1, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("RFCT test=0" , 4'b1000, 1'b0, 2'b10, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0);
	tester("     test=1" , 4'b1000, 1'b1, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("RPCT test=0" , 4'b1001, 1'b0, 2'b11, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0);
	tester("     test=1" , 4'b1001, 1'b1, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("CRTN test=0" , 4'b1010, 1'b0, 2'b00, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b1010, 1'b1, 2'b10, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("CJPP test=0" , 4'b1011, 1'b0, 2'b00, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b1011, 1'b1, 2'b11, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("LDCT"        , 4'b1100, 1'bx, 2'b00, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0);
	$display;
	tester("LOOP test=0" , 4'b1101, 1'b0, 2'b10, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	tester("     test=1" , 4'b1101, 1'b1, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("CONT"        , 4'b1110, 1'bx, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	tester("JP"          , 4'b1111, 1'bx, 2'b11, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);
	$display;
	#10 $finish;
end
	
endmodule
