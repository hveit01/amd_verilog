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

`timescale 1ns /100ps

// declarations of opcodes
`define SRC   i[2:0]
`define AQ    3'b000
`define AB    3'b001
`define ZQ    3'b010
`define ZB    3'b011
`define ZA    3'b100
`define DA    3'b101
`define DQ    3'b110
`define DZ    3'b111

`define FUNC  i[5:3]
`define ADD   3'b000
`define SUBR  3'b001
`define SUBS  3'b010
`define OR    3'b011
`define AND   3'b100
`define NOTRS 3'b101
`define EXOR  3'b110
`define EXNOR 3'b111

`define DST   i[8:6]
`define QREG  3'b000
`define NOP   3'b001
`define RAMA  3'b010
`define RAMF  3'b011
`define RAMQD 3'b100
`define RAMD  3'b101
`define RAMQU 3'b110
`define RAMU  3'b111

module am2901(a,b,i,din,oe_,cn,cp,
			  q0, q3,
			  ram0, ram3,
			  y, ovr, f0, f3, cn4, g_, p_
			 );

// RAM addresses
input [3:0] a, b;

// opcode
input [8:0] i;

// direct data
input [3:0] din;

// output enable
input oe_;

// carry in
input cn;

// clock
input cp;

// carry in/out for shifters
inout q0, q3;
inout ram0, ram3;

// result output
output [3:0] y;

// overflow from arithmetic ops
output ovr;

// zero, sign, carry
output f0;		// Note: this is NOT implemented as open collector!!!
output f3;
output cn4;

// generate, propagate carry
output g_, p_;

reg [3:0] ram[0:15];
reg [3:0] qreg;
reg [3:0] alatch;
reg [3:0] blatch;

wire [3:0] aluf;
wire [3:0] ymux;
wire [3:0] rmux;
wire [3:0] smux;

wire [3:0] adda;
wire [3:0] addb;
wire [4:0] addc;
wire [3:0] addf;
wire [3:0] addp;
wire [3:0] addg;
genvar n;

// some standard vectors
`define ALL0  4'b0000
`define ALLX  4'bxxxx
`define ALLZ  4'bzzzz

// alu source mux
assign rmux = 	(`SRC == `AQ || `SRC == `AB)                ? alatch :
				(`SRC == `ZQ || `SRC == `ZB || `SRC == `ZA) ? `ALL0  :
				(`SRC == `DA || `SRC == `DQ || `SRC == `DZ) ? din    : `ALLX;

assign smux =   (`SRC == `AQ || `SRC == `ZQ || `SRC == `DQ) ? qreg   :
				(`SRC == `AB || `SRC == `ZB)                ? blatch :
				(`SRC == `ZA || `SRC == `DA)                ? alatch :
				(`SRC == `DZ) 								? `ALL0  : `ALLX;

// adder
assign adda =	(`FUNC == `SUBR) ? smux : rmux;
assign addb =	(`FUNC == `SUBR) ? (~rmux) :
				(`FUNC == `SUBS) ? (~smux) : smux;
assign addc[0] = cn;
for (n=0; n<4; n=n+1) begin:aluadd
	wire w1, w2;
	xor a1(w1,       adda[n], addb[n]);
	xor a2(addf[n],  w1,      addc[n]);
	and a3(addg[n],  adda[n], addb[n]);
	and a4(w2,       w1,      addc[n]);
	or a5(addc[n+1], addg[n], w2);
	or a6(addp[n],   adda[n], addb[n]);
end
assign cn4 = addc[4];
assign p_ = ~(& addp);
assign g_ = ~(addg[3] |
			 (addp[3] & addg[2]) |
			 (addp[3] & addp[2] & addg[1]) |
			 (addp[3] & addp[2] & addp[1] & addg[0]));

// other ALU ops
assign aluf = 	(`FUNC == `ADD || `FUNC == `SUBR || `FUNC == `SUBS)	? addf :
				(`FUNC == `OR)										? ( rmux  |  smux) :
				(`FUNC == `AND)										? ( rmux  &  smux) :
				(`FUNC == `NOTRS)									? (~rmux  &  smux) :
				(`FUNC == `EXOR)									? ( rmux  ^  smux) :
				(`FUNC == `EXNOR)									? ( rmux  ~^ smux) : `ALLX;

// dest mux
assign ymux = (`DST == `RAMA) ? alatch : aluf;

// y output, cn+4, ovr, f==0 f3
assign y = (oe_ == 0) ? ymux : `ALLZ;
assign f3 = aluf[3];
assign ovr = cn4 ^ addc[3];
assign f0 = ~|aluf; // this is not open collector!!!

// ram load
always @(posedge cp)
begin
	// a, b latches
	alatch <= ram[a];
	blatch <= ram[b];
	
	// RAM, Q loading
	#1 case (`DST) // note #1: need some time to have aluf become stabled
		`QREG:         qreg <= aluf;
		`RAMA, `RAMF:  ram[b] <= aluf;
		`RAMQD:		   begin ram[b] <= {ram3 , aluf[3:1]}; qreg <= { q3, qreg[3:1] }; end
		`RAMD: 		   ram[b] <= {ram3, aluf[3:1]};
		`RAMQU:		   begin ram[b] <= {aluf[2:0], ram0}; qreg <= {qreg[2:0], q0}; end
		`RAMU:		   ram[b] <= {aluf[2:0], ram0};
		default:       ;
	endcase
end

// ram shift
assign ram0 = (`DST == `RAMQD || `DST == `RAMD) ? aluf[0] : 1'bz;
assign ram3 = (`DST == `RAMQU || `DST == `RAMU) ? aluf[3] : 1'bz;

// q shift
assign q0 = (`DST == `RAMQD || `DST == `RAMD) ? qreg[0] : 1'bz;
assign q3 = (`DST == `RAMQU || `DST == `RAMU) ? qreg[3] : 1'bz;

endmodule
