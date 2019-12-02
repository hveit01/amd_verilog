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

// am2929 variable width inverting tristate drivers/receivers
`include "am2926.v"

module am2926_testbench;
parameter WIDTH = 4;

reg [WIDTH-1:0] d;
reg [WIDTH-1:0] busin;
reg be, re;
wire [WIDTH-1:0] r, bus;

`define assert(signame, value, expval) \
        if (expval !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, expval, value); \
        end

task tester;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] dval, businval;
    input beval, reval;
	input [WIDTH-1:0] expectr, expectbus;
	begin
		d <= dval; busin <= businval;
        be <= beval; re <= reval;
		#1 $display("%5g: %4b  %b  %b | %4b %4b | %0s",
					$time, d,  be, re,  r,  bus,  descr);
		`assert("R", r, expectr);
		`assert("BUS_", bus, expectbus);
	end
endtask

assign bus = busin;

am2926 #(.WIDTH(WIDTH)) dut(
	.d(d),
    .be(be), .re_(re),
	.bus_(bus), .r(r)
);

initial begin
	//Dump results of the simulation
	$dumpfile("am2929.vcd");
	$dumpvars;
	
$display("-time: -d-- be re | -r-- -bus | descr");

//                                  ---d-- --bus- -be -re ex_r__ ex_bus
	tester("Tristate BUS_",         'bXXXX,'bZZZZ,'b0,'bX,'bXXXX,'bZZZZ);
	tester("Tristate R",            'bXXXX,'bXXXX,'bX,'b1,'bZZZZ,'bXXXX);
	tester("Drive BUS",             'b1010,'bZZZZ,'b1,'bX,'bXXXX,'b1010);
	tester("Drive BUS and receive", 'b0011,'bZZZZ,'b1,'b0,'b0011,'b0011);
	tester("Receive BUS",           'bXXXX,'b1101,'b0,'b0,'b1101,'b1101);
	#10 $finish;
end
	
endmodule
