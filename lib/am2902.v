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

module am2902(cn, g_, p_,
			  cnx, cny, cnz, go_, po_);
input cn;
input [3:0] g_;
input [3:0] p_;
output cnx, cny, cnz;
output go_, po_;

wire cn_;
wire x1, x2;
wire y1, y2, y3;
wire z1, z2, z3, z4;
wire g1, g2, g3, g4;

not U1(cn_, cn);

and Ux1(x1, g_[0], p_[0]);
and Ux2(x2, cn_, g_[0]);
nor Ux3(cnx, x1, x2);

and Uy1(y1, g_[1], p_[1]);
and Uy2(y2, g_[0], g_[1], p_[0]);
and Uy3(y3, g_[0], g_[1], cn_);
nor Uy4(cny, y1, y2, y3);

and Uz1(z1, g_[2], p_[2]);
and Uz2(z2, g_[1], g_[2], p_[1]);
and Uz3(z3, g_[0], g_[1], g_[2], p_[0]);
and Uz4(z4, cn_, g_[0], g_[1], g_[2]);
nor Uz5(cnz, z1, z2, z3, z4);

and Ug1(g1, g_[3], p_[3]);
and Ug2(g2, g_[2], g_[3], p_[2]);
and Ug3(g3, g_[1], g_[2], g_[3], p_[1]);
and Ug4(g4, g_[0], g_[1], g_[2], g_[3]);
or  Ug5(go_, g1, g2, g3, g4);

or  Up1(po_, p_[0], p_[1], p_[2], p_[3]);

endmodule
