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

// am74lS251 8-to-1 multiplexer with tri-state

module am74ls251(d, a,b,c, s_, y, w_);
input [7:0] d;
input a,b,c;
input s_;

output y, w_;

assign y  = (s_ == 1'b0) ? d[{c,b,a}] : 1'bz;
assign w_ = (s_ == 1'b0) ? ~y : 1'bz;

endmodule
