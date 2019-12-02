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

`include "am25ls163.v"

module am25ls163_testbench;

reg clr_;
reg load_;
reg [7:0] din;
reg cp;
reg p;
reg t;

wire [7:0] q;
wire co;
wire carry;
	
am25ls163 #(.WIDTH(4)) 
	dut1(
		.din	(din[3:0]), 
		.cp		(cp),
		.p		(p),
		.t		(t),
		.load_	(load_),
		.clr_	(clr_),
		.q		(q[3:0]),
		.co		(carry)
	);
		
am25ls163 #(.WIDTH(4)) 
	dut2(
		.din	(din[7:4]), 
		.cp		(cp),
		.p		(p),
		.t		(carry),
		.load_	(load_),
		.clr_	(clr_),
		.q		(q[7:4]),
		.co		(co)
	);

task tester;
	input [80*8-1:0] descr;
	input [7:0] dval;
	input lval;
	input pval;
	input tval;
	input clrval;
	begin
		din <= dval;
		load_ <= lval;
		p <= pval;
		t <= tval;
		clr_ <= clrval;
		cp <= 1'b0;
		#1 $display("%5g: %8b  %1b    %1b   %1b    %1b    0   | %8b  %1b   | %0s",
			        $time,din, load_, p,    t,     clr_,        q,   co, descr);
		cp <= 1'b1;
		#1 $display("%5g: %8b  %1b    %1b   %1b    %1b    r   | %8b  %1b   |",
				    $time,din, load_, p,    t,     clr_,        q,   co);
		cp <= 1'b0;
//		#1 $display("%5g: %8b  %1b    %1b   %1b    %1b    f   | %8b  %1b   |",
//			        $time,din, load_, p,    t,     clr_,        q,   co);
	end
endtask

// run test once
initial
begin
	//Dump results of the simulation to ff.cvd
	$dumpfile("am25ls163.vcd");
	$dumpvars;
	
	$display("-time: --din--- -ld- -p- -t- -clr- -cp- | ----q--- -co- |");
//                            ----din---- -load- -p--  -t--  -clr-
	tester("RESET"           ,8'bxxxxxxxx,1'bx,  1'bx, 1'bx, 1'b0 );
	tester("LOAD"            ,8'b00001101,1'b0,  1'bx, 1'bx, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("COUNT, BIT4 CO"  ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("HOLD T"          ,8'bxxxxxxxx,1'b1,  1'bx, 1'b0, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("HOLD P"          ,8'bxxxxxxxx,1'b1,  1'b0, 1'bx, 1'b1 );
	tester("LOAD"            ,8'b11111110,1'b0,  1'bx, 1'bx, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("COUNT, BIT8 CO"  ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	tester("COUNT"           ,8'bxxxxxxxx,1'b1,  1'b1, 1'b1, 1'b1 );
	#10 $finish;
end

endmodule
