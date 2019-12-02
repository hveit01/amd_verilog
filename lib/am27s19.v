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

// am27s19 32*8 bit ROM
`include "_genrom.v"

module am27s19(a, q, cs_);
parameter WIDTH=8;
parameter HEIGHT=5;
parameter INITH="";
parameter INITB="";

input [HEIGHT-1:0] a;
output [WIDTH-1:0] q;
input cs_;

_genrom #(.WIDTH(WIDTH),.HEIGHT(HEIGHT), .INITH(INITH), .INITB(INITB))
u0(
	.a(a), .q(q), .cs1_(cs_), .cs2_(1'b0)
);

endmodule
