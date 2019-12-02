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

// am25ls153 4-line-to-1 dataselector / multiplexer

`timescale 1ns / 100ps

module am25ls153(sel, g, c,
				y);

input [1:0] sel;
input g;
input [3:0] c;

output y;
wire y;
	
assign y = (g==0) ?
			((sel==2'b00) ? c[0] :
			 (sel==2'b01) ? c[1] :
			 (sel==2'b10) ? c[2] :
			 (sel==2'b11) ? c[3] : 0) : 0;

endmodule
