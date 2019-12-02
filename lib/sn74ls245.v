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
// sn74ls245 is WIDTH=8, use different WIDTH for larger bus width

module sn74ls245(a, b, dir, g_);
parameter WIDTH=8;
inout [WIDTH-1:0] a, b;
input dir, g_;

assign a = (g_=='b1 || dir=='b1) ? {WIDTH{1'bZ}} : b;
assign b = (g_=='b1 || dir=='b0) ? {WIDTH{1'bZ}} : a;

endmodule
