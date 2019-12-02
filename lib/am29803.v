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

// am29803 16-way branch control unit

module am29803(i, orx, oe1_, oe2_, t);
input [3:0] i;
input [3:0] t;
input oe1_, oe2_;
output [3:0] orx;

reg [3:0] orval;

always @(i,t) begin
	case (i)
	4'b0000: orval <=   4'b0000;
	4'b0001: orval <= {  3'b000, t[0] };
	4'b0010: orval <= {  3'b000, t[1] };
	4'b0011: orval <= {   2'b00, t[1:0] };
	4'b0100: orval <= {  3'b000, t[2] };
	4'b0101: orval <= {   2'b00, t[2], t[0] };
	4'b0110: orval <= {   2'b00, t[2:1] };
	4'b0111: orval <= {    1'b0, t[2:0] }; 
	4'b1000: orval <= {  3'b000, t[3] };
	4'b1001: orval <= {   2'b00, t[3], t[0] };
	4'b1010: orval <= {   2'b00, t[3], t[1] };
	4'b1011: orval <= {    1'b0, t[3], t[1:0] };
	4'b1100: orval <= {   2'b00, t[3:2] };
	4'b1101: orval <= {    1'b0, t[3:2], t[0] };
	4'b1110: orval <= {    1'b0, t[3:1] };
	4'b1111: orval <=   t;
	default: orval <=   4'b0000;
	endcase
end

assign orx = (oe1_==1'b0 && oe2_==1'b0) ? orval : 4'bzzzz;

endmodule