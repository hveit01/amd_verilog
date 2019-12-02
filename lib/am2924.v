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

// am2924 8-to-1 decoder/multiplexer, same as 74ls138

module am2924(a,b,c, g1, g2a_, g2b_, y);
input a,b,c;
input g1, g2a_, g2b_;
output [7:0] y;

wire g, na, nb, nc;

assign g = g1 & ~g2a_ & ~g2b_;
assign na = ~a;
assign nb = ~b;
assign nc = ~c;

assign y[0] = ~(g & na & nb & nc);
assign y[1] = ~(g &  a & nb & nc);
assign y[2] = ~(g & na &  b & nc);
assign y[3] = ~(g &  a &  b & nc);
assign y[4] = ~(g & na & nb &  c);
assign y[5] = ~(g &  a & nb &  c);
assign y[6] = ~(g & na &  b &  c);
assign y[7] = ~(g &  a &  b &  c);

endmodule
