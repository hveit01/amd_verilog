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

// am2929 quad/n-bit inverting tristate bus drivers/receivers
// user parameter WIDTH to extend to N bits
// am2929 is WIDTH=4

module am2929(d, be, re_, bus_, r);
parameter WIDTH=4;
input [WIDTH-1:0] d;
input be, re_;
inout [WIDTH-1:0] bus_;
output [WIDTH-1:0] r;

assign bus_ = (be=='b0) ? {WIDTH{1'bZ}} : ~d;
assign r = (re_=='b0) ? ~bus_ : {WIDTH{1'bZ}};

endmodule
