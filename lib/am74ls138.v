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

// am74ls138 8-to-1 decoder/multiplexer

module am74ls138(a,b,c, g1, g2a_, g2b_, y);
input a,b,c;
input g1, g2a_, g2b_;
output [7:0] y;
reg [7:0] y;

always @(*) begin
	y = 8'b11111111;
	if (g1 == 1'b1 && g2a_ == 1'b0 && g2b_ == 1'b0) begin
		case ({c,b,a})
		0: y[0] = 1'b0;
		1: y[1] = 1'b0;
		2: y[2] = 1'b0;
		3: y[3] = 1'b0;
		4: y[4] = 1'b0;
		5: y[5] = 1'b0;
		6: y[6] = 1'b0;
		7: y[7] = 1'b0;
		default: y = 8'b11111111;
		endcase
	end
end
endmodule
