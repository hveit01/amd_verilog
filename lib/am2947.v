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

// variable width noninverting tristate bus transceiver
// am2947 is WIDTH=8, use different WIDTH for larger bus width

module am2947(a, b, cd, tr_);
parameter WIDTH=8;
inout [WIDTH-1:0] a, b;
input cd, tr_;

assign a = (cd=='b1 || tr_=='b1) ? {WIDTH{1'bZ}} : b;
assign b = (cd=='b1 || tr_=='b0) ? {WIDTH{1'bZ}} : a;

endmodule
