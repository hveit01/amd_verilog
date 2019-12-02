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

// amls163 variable width cup counter with synchronous load and clear

`timescale 1ns / 100ps

module am25ls163(din, cp, p, t, load_, clr_,
				 q, co);
parameter WIDTH = 4;
				 
input [WIDTH-1:0] din;
input cp;
input p;
input t;
input load_;
input clr_;

output [WIDTH-1:0] q;
output co;

reg [WIDTH-1:0] q;
	
initial begin
	q <= 'bx;
end
	
always @(posedge cp)
begin
	if (clr_==0) begin
		q <= 'b0;
	end else if (load_==0) begin
		q <= din;
	end else if (p && t) begin
		q <= q + 1;
	end
end
	
assign co = (q == {WIDTH{1'b1}} && t) ? 1 : 0;

endmodule
