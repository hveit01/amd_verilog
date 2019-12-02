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

`include "am2910.v"

// am2910 test
module am2910_testbench;

reg [11:0] din;
reg [3:0] i;
reg cc_, ccen_;
reg cin;
reg rld_;
reg oe_;
reg cp;

wire [11:0] y;
wire full_;
wire pl_;
wire map_;
wire vect_;

`define HEADER(title)\
    $display(title)
    
`define SHOW(clk, descr)\
		$display("%5g: %4b  %3xh  %1b    %1b    %1b    %1b    %1b    %0s   |  %3xh  %1b    %1b    %1b    %1b    | %3xh  %3xh   %3b | %0s",\
			     $time,i,   din,  cc_,   ccen_, cin,   rld_,  oe_,   clk,     y,    full_, pl_,   map_,  vect_,   dut.upc,dut.ctreg,dut.sp, descr);

`define assert(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [3:0] ival;
	input [11:0] dval;
	input ccval, ccenval;
	input cinval;
	input rldval;
	input oeval;
	
	input [11:0] expecty;
	input expectfull,expectpl,expectmap,expectvect;
	
	begin
		din <= dval;
		i <= ival;
		cc_ <= ccval;
		ccen_ <= ccenval;
		cin <= cinval;
		rld_ <= rldval;
		oe_ <= oeval;
		cp <= 1'b0;
//		#1 `SHOW(" ", "");
//				    $time,i,   din,  cc_,   ccen_, cin,   rld_,  oe_,          y,    full_, pl_,   map_,  vect_,   dut.upc,dut.ctreg,dut.sp,descr);
		#1 cp <= 1'b1;
		`SHOW("^", descr);

   		`assert("y", expecty, y);

        #1 cp <= 1'b0;
        `SHOW(" ", "");
					
		`assert("full_", expectfull, full_);
		`assert("pl_", expectpl, pl_);
		`assert("map_", expectmap, map_);
		`assert("vect_", expectvect, vect_);
	end
endtask

am2910 dut(
	.din 	(din),
	.i		(i),
	.cc_	(cc_),
	.ccen_	(ccen_),
	.cin	(cin),
	.rld_	(rld_),
	.oe_	(oe_),
	.cp		(cp),
	.y		(y),
	.full_	(full_),
	.pl_	(pl_),
	.map_	(map_),
	.vect_	(vect_)
);

initial begin
	//Dump results of the simulation to am2910.vcd
	$dumpfile("am2910.vcd");
	$dumpvars;

    $display("-time: -i-- --d-- -cc- ccen cin- rld- -oe- -cp- | --y-- full -pl- map- vect_ | -upc- -reg- -sp- | description");
`HEADER("Test output disable ");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("Y DISABLE",           4'bxxxx,12'bxxxxxxxxxxxx,1'bx,1'bx,1'bx,1'bx,1'b1,12'bzzzzzzzzzzzz,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test JZ, CONT, CONT");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("xxx: JZ",             4'b0000,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000000,1'b1,1'b0,1'b1,1'b1);
	tester("000: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000000,1'b1,1'b0,1'b1,1'b1);
	tester("001: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000001,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test CJS to 17h, CONT, CRTN PASS");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("002: CJS FAIL",       4'b0001,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000000000010,1'b1,1'b0,1'b1,1'b1);
	tester("003: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000011,1'b1,1'b0,1'b1,1'b1);
	tester("004: CJS 17h PASS",   4'b0001,12'b000000010111,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000000100,1'b1,1'b0,1'b1,1'b1);
	tester("017: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000010111,1'b1,1'b0,1'b1,1'b1);
	tester("018: CRTN PASS",      4'b1010,12'bxxxxxxxxxxxx,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000011000,1'b1,1'b0,1'b1,1'b1);
	tester("005: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000101,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test JMAP, MAP to 35h");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("006: JMAP",           4'b0010,12'b000000110101,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000000110,1'b1,1'b1,1'b0,1'b1);
	tester("035: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000110101,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test CJP 163h");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("036: CJP FAIL",       4'b0011,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000000110110,1'b1,1'b0,1'b1,1'b1);
	tester("037: CJP PASS",       4'b0011,12'b000101100011,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000110111,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test PUSH until stack full");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("163: PUSH 1 FAIL",    4'b0100,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000101100011,1'b1,1'b0,1'b1,1'b1);
	tester("164: PUSH 2 PASS",    4'b0100,12'b000000001000,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000101100100,1'b1,1'b0,1'b1,1'b1);
	tester("165: PUSH 3 FAIL",    4'b0100,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000101100101,1'b1,1'b0,1'b1,1'b1);
	tester("166: PUSH 4 PASS",    4'b0100,12'b000000100010,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000101100110,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test JSRP to F=22h, P=28h, CRTN, CRTN");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("167: JSRP FAIL",      4'b0101,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000101100111,1'b0,1'b0,1'b1,1'b1);
	tester("022: JSRP 28h PASS",  4'b0101,12'b000000101000,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000100010,1'b0,1'b0,1'b1,1'b1);
	tester("028: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b000000101000,1'b0,1'b0,1'b1,1'b1);
	tester("029: CRTN PASS",      4'b1010,12'bxxxxxxxxxxxx,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000101001,1'b1,1'b0,1'b1,1'b1);
	tester("023: CRTN PASS",      4'b1010,12'bxxxxxxxxxxxx,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000000100011,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test CJV to 204h");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("167: CJV FAIL",       4'b0110,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b000101100111,1'b1,1'b0,1'b1,1'b1);
	tester("168: CJV 204h PASS",  4'b0110,12'b001000000100,1'b0,1'bx,1'b1,1'bx,1'b0,12'b000101101000,1'b1,1'b1,1'b1,1'b0);
`HEADER("Test JRP to F=209h, P=20Bh");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("204: LDCT 209h",      4'b1100,12'b001000001001,1'bx,1'bx,1'b1,1'bx,1'b0,12'b001000000100,1'b1,1'b0,1'b1,1'b1);
	tester("205: JRP FAIL",       4'b0111,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b001000000101,1'b1,1'b0,1'b1,1'b1);
	tester("209: JRP 20Bh PASS",  4'b0111,12'b001000001011,1'b0,1'bx,1'b1,1'bx,1'b0,12'b001000001001,1'b1,1'b0,1'b1,1'b1);
	tester("20B: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'bx,1'b0,12'b001000001011,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test RFCT");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("20C: PUSH & LDCT 2",  4'b0100,12'b000000000010,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001000001100,1'b1,1'b0,1'b1,1'b1);
	tester("20D: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001101,1'b1,1'b0,1'b1,1'b1);
	tester("20E: RFCT CTR<>0",    4'b1000,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001110,1'b1,1'b0,1'b1,1'b1);
	tester("20D: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001101,1'b1,1'b0,1'b1,1'b1);
	tester("20E: RFCT CTR<>0",    4'b1000,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001110,1'b1,1'b0,1'b1,1'b1);
	tester("20D: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001101,1'b1,1'b0,1'b1,1'b1);
	tester("20E: RFCT CTR==0",    4'b1000,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000001110,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test RPCT");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("20F: PUSH & LDCT 3",  4'b0100,12'b000000000011,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001000001111,1'b1,1'b0,1'b1,1'b1);
	tester("210: RPCT CTR<>0",    4'b1001,12'b001000010000,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000010000,1'b1,1'b0,1'b1,1'b1);
	tester("210: RPCT CTR<>0",    4'b1001,12'b001000010000,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000010000,1'b1,1'b0,1'b1,1'b1);
	tester("210: RPCT CTR<>0",    4'b1001,12'b001000010000,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000010000,1'b1,1'b0,1'b1,1'b1);
	tester("210: RPCT CTR=0",     4'b1001,12'bxxxxxxxxxxxx,1'bx,1'bx,1'b1,1'b1,1'b0,12'b001000010000,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test CJPP");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("211: PUSH 213h",      4'b0100,12'b001000010011,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001000010001,1'b0,1'b0,1'b1,1'b1);
	tester("212: CJPP FAIL",      4'b1011,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b001000010010,1'b0,1'b0,1'b1,1'b1);
	tester("213: CJPP PASS 240h", 4'b1011,12'b001001000000,1'b0,1'bx,1'b1,1'bx,1'b0,12'b001000010011,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test LOOP");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("240: PUSH 241h",      4'b0100,12'b001001000001,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001001000000,1'b0,1'b0,1'b1,1'b1);
	tester("241: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000001,1'b0,1'b0,1'b1,1'b1);
	tester("242: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000010,1'b0,1'b0,1'b1,1'b1);
	tester("243: LOOP FAIL",      4'b1101,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'bx,1'b0,12'b001001000011,1'b0,1'b0,1'b1,1'b1);
	tester("241: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000001,1'b0,1'b0,1'b1,1'b1);
	tester("242: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000010,1'b0,1'b0,1'b1,1'b1);
	tester("243: LOOP PASS",      4'b1101,12'bxxxxxxxxxxxx,1'b0,1'b1,1'b1,1'bx,1'b0,12'b001001000011,1'b1,1'b0,1'b1,1'b1);
`HEADER("Test TWB");
//                                ---i--- -------d-------- -cc- ccen cin- rld- -oe- ----expect y---- e-fu e-pl,e-mp,e-ve
	tester("244: PUSH & LDCT 3",  4'b0100,12'b000000000011,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001001000100,1'b0,1'b0,1'b1,1'b1);
	tester("245: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000101,1'b0,1'b0,1'b1,1'b1);
	tester("246: TWB FAIL CTR<>0",4'b1111,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'b1,1'b0,12'b001001000110,1'b0,1'b0,1'b1,1'b1);
	tester("245: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000101,1'b0,1'b0,1'b1,1'b1);
	tester("246: TWB FAIL CTR<>0",4'b1111,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'b1,1'b0,12'b001001000110,1'b0,1'b0,1'b1,1'b1);
	tester("245: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000101,1'b0,1'b0,1'b1,1'b1);
	tester("246: TWB FAIL CTR<>0",4'b1111,12'bxxxxxxxxxxxx,1'b1,1'b0,1'b1,1'b1,1'b0,12'b001001000110,1'b0,1'b0,1'b1,1'b1);
	tester("245: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000101,1'b0,1'b0,1'b1,1'b1);
	tester("246: TWB FAIL CTR=0", 4'b1111,12'b001001000111,1'b1,1'b0,1'b1,1'b1,1'b0,12'b001001000110,1'b1,1'b0,1'b1,1'b1);
	tester("247: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001000111,1'b1,1'b0,1'b1,1'b1);
	tester("248: TWB PASS CTR=0", 4'b1111,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001001000,1'b1,1'b0,1'b1,1'b1);
	tester("249: PUSH & LDCT 2",  4'b0100,12'b000000000010,1'b1,1'b0,1'b1,1'b0,1'b0,12'b001001001001,1'b1,1'b0,1'b1,1'b1);
	tester("24A: TWB PASS CTR<>0",4'b1111,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001001010,1'b1,1'b0,1'b1,1'b1);
	tester("24B: CONT",           4'b1110,12'bxxxxxxxxxxxx,1'bx,1'b1,1'b1,1'b1,1'b0,12'b001001001011,1'b1,1'b0,1'b1,1'b1);
	#10 $finish;
end

endmodule
