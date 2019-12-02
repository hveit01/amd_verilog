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

`include "am2918.v"

module am2918_testbench;
reg [3:0] d;
reg cp;
reg oe_;
wire [3:0] q;
wire [3:0] y;

am2918 #(.WIDTH(4))
	dut(d,cp, oe_,q,y);
	
task tester;
	input [80*8-1:0] descr;
	input [3:0] dval;
	input oeval;
	input cpval;
	begin
		d <= dval;
		oe_ <= oeval;
		cp <= cpval;
		#1 $display("%5g: %4b  %1b    %1b   | %4b %4b | %0s",
			        $time,d,   oe_,   cp,    q,   y,    descr);
	end
endtask
	
initial
begin
	//Dump results of the simulation to ff.cvd
	$dumpfile("am2918.vcd");
	$dumpvars;

    $display("-time: -d-- -oe- -cp- | -q-- -y-- |");
//                             ---d---  -oe-  -cp-
	tester("DIS Y, CP=0" ,     4'bxxxx, 1'b1, 1'b0);
	tester("DIS Y, CP=1" ,     4'bxxxx, 1'b1, 1'b1);
	tester("CLOCK" ,           4'b0101, 1'b1, 1'b0);
	tester("" ,                4'b0101, 1'b1, 1'b1);
	tester("" ,                4'bxxxx, 1'b1, 1'b0);
	tester("EN Y, CLOCK" ,     4'b1010, 1'b0, 1'b0);
	tester("" ,                4'b1010, 1'b0, 1'b1);
	tester("" ,                4'bxxxx, 1'b0, 1'b0);
	#10 $finish;
end

endmodule
