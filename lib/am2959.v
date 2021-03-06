// variable width noninverting tristate - drivers
// am2959 is WIDTH=4, use 2 modules, if separate G is needed

module am2959(a, y, g_);
parameter WIDTH=4;
input [WIDTH-1:0] a;
output [WIDTH-1:0] y;
input g_;

assign y = (g_==1'b0) ? a : {WIDTH{1'bz}};
endmodule
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

