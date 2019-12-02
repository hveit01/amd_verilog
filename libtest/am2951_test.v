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

// am2951 variable width inverting bidirectional I/O ports
`include "am2951.v"

module am2951_testbench;
parameter WIDTH = 8;

reg [WIDTH-1:0] ain, bin;
reg cpr, cps;
reg oea, oeb, cer, ces;
reg clrr, clrs;

wire [WIDTH-1:0] a, b;
wire frr, fsr;

am2951 #(.WIDTH(WIDTH)) dut(
	.a(a), .cpr(cpr), .cer_(cer), .oea_(oea), .fr(frr), .clrr(clrr),
	.b(b), .cps(cps), .ces_(ces), .oeb_(oeb), .fs(fsr), .clrs(clrs)
);

assign a = ain;
assign b = bin;

`define ASSERT(signame, signal, value) \
        if (signal !== value) begin \
			$display("Error: %s should be %b, but is %b", signame, value, signal); \
        end
`define SHOW(ain, cpr, cer, oea, clrr,  bin, cps, ces, oeb, clrs, a, fr, b, fs, descr)\
	$display("%5g: %8b  %0s   %b   %b   %0s  %8b  %0s   %b   %b   %0s  | %8b  %b %8b  %b | %0s",\
			 $time,ain, cpr,  cer, oea, clrr,bin, cps,  ces, oeb, clrs,  a,   fr,b,   fs,  descr);

task clockr;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] av;
	input cerv, oeav;
	input [WIDTH-1:0] bv;
	input cesv, oebv;
	input [WIDTH-1:0] expecta, expectb;
	input expectfr, expectfs;
	begin
		ain <= av; cer <= cerv; oea <= oeav; clrr <= 'b0;
		bin <= bv; ces <= cesv; oeb <= oebv; clrs <= 'b0; cps <= 'b0;
		
		cpr <= 'b0;
		#1 // `SHOW(ain, " ", cer, oea, "_",  bin, "_", ces, oeb, "_", a, frr, b, fsr, "");
		   cpr <= 'b1;
		#1 `SHOW(ain, "^", cer, oea, "_",  bin, "_", ces, oeb, "_", a, frr, b, fsr, descr);
		   cpr <= 'b0;
		#1 // `SHOW(ain, " ", cer, oea, "_",  bin, "_", ces, oeb, "_", a, frr, b, fsr, "");
		`ASSERT("a", a, expecta);
		`ASSERT("b", b, expectb);
		`ASSERT("fr", frr, expectfr);
		`ASSERT("fs", fsr, expectfs);
	end
endtask

task clocks;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] av;
	input cerv, oeav;
	input [WIDTH-1:0] bv;
	input cesv, oebv;
	input [WIDTH-1:0] expecta, expectb;
	input expectfr, expectfs;
	begin
		ain <= av; cer <= cerv; oea <= oeav; clrr <= 'b0; cpr <= 'b0;
		bin <= bv; ces <= cesv; oeb <= oebv; clrs <= 'b0;
		
		cps <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, "_",  bin, " ", ces, oeb, "_", a, frr, b, fsr, "");
		   cps <= 'b1;
		#1 `SHOW(ain, "_", cer, oea, "_",  bin, "^", ces, oeb, "_", a, frr, b, fsr, descr);
		   cps <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, "_",  bin, " ", ces, oeb, "_", a, frr, b, fsr, "");
		`ASSERT("a", a, expecta);
		`ASSERT("b", b, expectb);
		`ASSERT("fr", frr, expectfr);
		`ASSERT("fs", fsr, expectfs);
	end
endtask

task clearr;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] av;
	input cerv, oeav;
	input [WIDTH-1:0] bv;
	input cesv, oebv;
	input [WIDTH-1:0] expecta, expectb;
	input expectfr, expectfs;
	begin
		ain <= av; cer <= cerv; oea <= oeav; cpr <= 'b0;
		bin <= bv; ces <= cesv; oeb <= oebv; cps <= 'b0; clrs <= 'b0;
		
		clrr <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, " ",  bin, "_", ces, oeb, "_", a, frr, b, fsr, "");
		   clrr <= 'b1;
		#1 `SHOW(ain, "_", cer, oea, "^",  bin, "_", ces, oeb, "_", a, frr, b, fsr, descr);
		   clrr <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, " ",  bin, "_", ces, oeb, "_", a, frr, b, fsr, "");
		`ASSERT("a", a, expecta);
		`ASSERT("b", b, expectb);
		`ASSERT("fr", frr, expectfr);
		`ASSERT("fs", fsr, expectfs);
	end
endtask

task clears;
	input [80*8-1:0] descr;
	input [WIDTH-1:0] av;
	input cerv, oeav;
	input [WIDTH-1:0] bv;
	input cesv, oebv;
	input [WIDTH-1:0] expecta, expectb;
	input expectfr, expectfs;
	begin
		ain <= av; cer <= cerv; oea <= oeav; cpr <= 'b0; clrr <= 'b0;
		bin <= bv; ces <= cesv; oeb <= oebv; cps <= 'b0; 
		
		clrs <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, "_",  bin, "_", ces, oeb, " ", a, frr, b, fsr, "");
		   clrs <= 'b1;
		#1 `SHOW(ain, "_", cer, oea, "_",  bin, "_", ces, oeb, "^", a, frr, b, fsr, descr);
		   clrs <= 'b0;
		#1 // `SHOW(ain, "_", cer, oea, "_",  bin, "_", ces, oeb, " ", a, frr, b, fsr, "");
		`ASSERT("a", a, expecta);
		`ASSERT("b", b, expectb);
		`ASSERT("fr", frr, expectfr);
		`ASSERT("fs", fsr, expectfs);
	end
endtask

initial begin
	//Dump results of the simulation
	$dumpfile("am2951.vcd");
	$dumpvars;
	
	$display("-time: ---ain-- cpr cer oea clr ---bin-- cps ces oeb cls | ---a---- fr ---b---- fs | descr");

//                          ----a----- cer oea ----b----- ces oeb --expecta- --expectb- efr efs
	clearr("Clear FR",      'bZZZZZZZZ,'bX,'b1,'bZZZZZZZZ,'bX,'b1,'bZZZZZZZZ,'bZZZZZZZZ,'b0,'bX);
	clears("Clear FS",      'bZZZZZZZZ,'bX,'b1,'bZZZZZZZZ,'bX,'b1,'bZZZZZZZZ,'bZZZZZZZZ,'b0,'b0);
	clockr("LoadR, CER=1",  'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'bX,'b1,'bZZZZZZZZ,'bZZZZZZZZ,'b0,'b0);
	clockr("LoadR, CER=0",  'b10101010,'b0,'b1,'bZZZZZZZZ,'bX,'b1,'b10101010,'bZZZZZZZZ,'b1,'b0);
	clockr("ReadR",         'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'bX,'b0,'bZZZZZZZZ,'b01010101,'b1,'b0);
	clearr("ACK FR",        'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'bX,'b0,'bZZZZZZZZ,'b01010101,'b0,'b0);
	clocks("LoadS, CES=1",  'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'b1,'b1,'bZZZZZZZZ,'bZZZZZZZZ,'b0,'b0);
	clocks("LoadS, CES=0",  'bZZZZZZZZ,'b1,'b1,'b11001100,'b0,'b1,'bZZZZZZZZ,'b11001100,'b0,'b1);
	clocks("ReadS",         'bZZZZZZZZ,'b1,'b0,'bZZZZZZZZ,'b1,'b0,'b00110011,'b01010101,'b0,'b1);
	clears("ACK FS",        'bZZZZZZZZ,'b1,'b0,'bZZZZZZZZ,'b1,'b0,'b00110011,'b01010101,'b0,'b0);
	
	#10 $finish;
end
	
endmodule
