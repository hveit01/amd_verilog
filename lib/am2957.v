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

// am2957 inverting n-Latch with tristate outputs
// configure this with PARAMETER WIDTH!

// am2957 is WIDTH=8

module am2957(d, y, g, oe_);
parameter WIDTH = 8;
input [WIDTH-1:0] d;
output [WIDTH-1:0] y;
input g;
input oe_;

reg [WIDTH-1:0] q;

always @(negedge g)
begin
	if (g == 'b0) begin
		q <= d;
	end
end

assign y = (oe_=='b1) ? {WIDTH{1'bZ}} : 
		   ~((g=='b1) ? d : q);

endmodule
