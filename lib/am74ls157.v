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

// am74ls157 N 2-to-1 multiplexer
// use PARAMETER WIDTH for number of multiplexers
// ls157 is WIDTH=4

`timescale 1ns / 100ps

module am74ls157(a, b, g_, s, y);
parameter WIDTH=4;
input [WIDTH-1:0] a, b;
input g_;
input s;

output [WIDTH-1:0] y;

assign y = (g_==1'b1) ? {WIDTH{1'b0}} : ((s==1'b0) ? a : b);

endmodule
