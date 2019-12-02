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

// variable width noninverting tristate - drivers
// sn74241 is WIDTH=4, 

module sn74ls241(a1, y1, g1_, a2, y2, g2);
parameter WIDTH=4;
input [WIDTH-1:0] a1, a2;
output [WIDTH-1:0] y1, y2;
input g1_, g2;

assign y1 = (g1_==1'b0) ? a1 : {WIDTH{1'bz}};
assign y2 = (g2==1'b1) ? a2 : {WIDTH{1'bz}};
endmodule
