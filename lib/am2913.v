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

// am2913 priority interrupt expander

module am2913(i_, ei_, g1, g2, g3_, g4_, g5_, a, eo_);
input [7:0] i_;
input ei_;
input g1, g2, g3_, g4_, g5_;
output [2:0] a;
output eo_;

wire [2:0] ai;
wire g;

assign ai = (ei_=='b1) ?     'b000 :
            (i_[7] == 'b0) ? 'b111 :
            (i_[6] == 'b0) ? 'b110 :
            (i_[5] == 'b0) ? 'b101 :
            (i_[4] == 'b0) ? 'b100 :
            (i_[3] == 'b0) ? 'b011 :
            (i_[2] == 'b0) ? 'b010 :
            (i_[1] == 'b0) ? 'b001 :
                             'b000;
assign eo_ = (ei_=='b0 && i_=='b1111_1111) ? 'b0 : 'b1;

assign g = g1 & g2 & ~g3_ & ~g4_ & ~g5_;
assign a = (g=='b1) ? ai : 'bZZZ;

endmodule
