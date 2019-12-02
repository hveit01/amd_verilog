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

// am27s181 1024*8 bit ROM
`include "_genrom.v"

// am27s29 is WIDTH=8, HEIGHT=10

`timescale 1ns / 100ps

module am27s181(a, q, cs1_, cs2_, cs3, cs4);
parameter WIDTH=8;
parameter HEIGHT=10;
parameter INITH="";
parameter INITB="";
input [HEIGHT-1:0] a;
output [WIDTH-1:0] q;
input cs1_, cs2_, cs3, cs4;
wire cs;

assign cs = cs1_ | cs2_ | (~cs3) | (~cs4);

_genrom #(.WIDTH(WIDTH),.HEIGHT(10), .INITH(INITH), .INITB(INITB)) 
u0(
	.a(a), .q(q), .cs1_(cs), .cs2_(1'b0)
);

endmodule
