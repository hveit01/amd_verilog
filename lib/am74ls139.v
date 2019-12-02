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

// am74ls139 4-to-1 decoder/multiplexer
// note the real 74139 has two independent decoders in it

`timescale 1ns / 100ps

module am74ls139(a,b, g_, y);
input a,b;
input g_;
output [3:0] y;
reg [3:0] y;

always @(*) begin
	y = 4'b111;
	if (g_ == 1'b1) begin
		case ({b,a})
		0: y[0] = 1'b0;
		1: y[1] = 1'b0;
		2: y[2] = 1'b0;
		3: y[3] = 1'b0;
		default: y = 4'b1111;
		endcase
	end
end
endmodule
