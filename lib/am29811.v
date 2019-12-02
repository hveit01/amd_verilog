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

// am29811 Next Address Control Unit

`timescale 1ns / 100ps

// instructions
`define JZ 		4'b0000
`define CJS		4'b0001
`define JMAP	4'b0010
`define CJP		4'b0011
`define PUSH	4'b0100
`define JSRP	4'b0101
`define CJV		4'b0110
`define JRP		4'b0111
`define RFCT	4'b1000
`define RPCT	4'b1001
`define CRTN	4'b1010
`define CJPP	4'b1011
`define LDCT	4'b1100
`define LOOP	4'b1101
`define CONT	4'b1110
`define JP 		4'b1111

// next address source
`define NAS_PC	2'b00
`define NAS_R	2'b01
`define NAS_F	2'b10
`define NAS_D	2'b11

// file op
`define F_POP	2'b00
`define F_PUSH	2'b01
`define F_HOLD0	2'b10
`define F_HOLD	2'b11

// counter op
`define CT_LL	2'b00
`define CT_LOAD	2'b01
`define CT_DEC	2'b10
`define CT_HOLD	2'b11

module am29811(i, test, oe_, cntload_, cnte_, mape_, ple_, fe_, pup, s);
input [3:0] i;
input test;
input oe_;
output cntload_, cnte_;
output mape_, ple_;
output fe_, pup;
output [1:0] s;

reg [7:0] tmp;

always @(i,test) 
begin
	case (i)
	`JZ:     tmp = 					{`NAS_D,  `F_HOLD,  `CT_LL,   1'b1, 1'b0};
	`CJS:    tmp = (test==1'b0) ?	{`NAS_PC, `F_HOLD,  `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_D,  `F_PUSH,  `CT_HOLD, 1'b1, 1'b0};
	`JMAP:   tmp = 					{`NAS_D,  `F_HOLD,  `CT_HOLD, 1'b0, 1'b1};
	`CJP:    tmp = (test==1'b0) ?	{`NAS_PC, `F_HOLD,  `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_D,  `F_HOLD,  `CT_HOLD, 1'b1, 1'b0};
	`PUSH:   tmp = (test==1'b0) ?	{`NAS_PC, `F_PUSH,  `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_PC, `F_PUSH,  `CT_LOAD, 1'b1, 1'b0};
	`JSRP:   tmp = (test==1'b0) ?	{`NAS_R,  `F_PUSH,  `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_D,  `F_PUSH,  `CT_HOLD, 1'b1, 1'b0};
	`CJV:    tmp = (test==1'b0) ?	{`NAS_PC, `F_HOLD,  `CT_HOLD, 1'b1, 1'b1}:
									{`NAS_D,  `F_HOLD,  `CT_HOLD, 1'b1, 1'b1};
	`JRP:    tmp = (test==1'b0) ?	{`NAS_R,  `F_HOLD,  `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_D,  `F_HOLD,  `CT_HOLD, 1'b1, 1'b0};
	`RFCT:   tmp = (test==1'b0) ?	{`NAS_F,  `F_HOLD0, `CT_DEC,  1'b1, 1'b0}:
									{`NAS_PC, `F_POP,   `CT_HOLD, 1'b1, 1'b0};
	`RPCT:   tmp = (test==1'b0) ?	{`NAS_D,  `F_HOLD,  `CT_DEC,  1'b1, 1'b0}:
									{`NAS_PC, `F_HOLD,  `CT_HOLD, 1'b1, 1'b0};
	`CRTN:   tmp = (test==1'b0) ?	{`NAS_PC, `F_HOLD0, `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_F,  `F_POP,   `CT_HOLD, 1'b1, 1'b0};
	`CJPP:   tmp = (test==1'b0) ?	{`NAS_PC, `F_HOLD0, `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_D,  `F_POP,   `CT_HOLD, 1'b1, 1'b0};
	`LDCT:   tmp = 					{`NAS_PC, `F_HOLD,  `CT_LOAD, 1'b1, 1'b0};
	`LOOP:   tmp = (test==1'b0) ?	{`NAS_F,  `F_HOLD0, `CT_HOLD, 1'b1, 1'b0}:
									{`NAS_PC, `F_POP,   `CT_HOLD, 1'b1, 1'b0};
	`CONT:   tmp = 					{`NAS_PC, `F_HOLD,  `CT_HOLD, 1'b1, 1'b0};
	`JP:     tmp = 					{`NAS_D,  `F_HOLD,  `CT_HOLD, 1'b1, 1'b0};
	default: tmp = 					8'bxxxxxxxx;
	endcase
end

assign s   		= tmp[7:6];
assign fe_ 		= tmp[5];
assign pup		= tmp[4];
assign cntload_	= tmp[3];
assign cnte_	= tmp[2];
assign mape_	= tmp[1];
assign ple_		= tmp[0];

endmodule