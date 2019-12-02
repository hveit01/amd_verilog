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

// variable length AM2918
// D register with std and three state outputs

`timescale 1ns / 100ps

module am2918(d, cp, oe_, q, y);

parameter WIDTH=4;
input [WIDTH-1:0] d;
input cp;
input oe_;
output [WIDTH-1:0] q;
output [WIDTH-1:0] y;
reg [WIDTH-1:0] q;

initial
begin 
	q = 'b0; 
end

always @(posedge cp) 
begin
	q <= d;
end
	
assign y = oe_ ? 'bz : q;

endmodule

