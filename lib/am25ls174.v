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

// am25ls174 / ls175 n-DFF with clear
// configure this with PARAMETER WIDTH!

// 25ls174 is WIDTH=6
// 25ls175 is WIDTH=4

`timescale 1ns / 100ps

module am25ls174(d, q, q_, clk, clr_);
parameter WIDTH = 6;
input [WIDTH-1:0] d;
output [WIDTH-1:0] q;
output [WIDTH-1:0] q_;
input clk;
input clr_;

reg [WIDTH-1:0] q;

always @(clr_)
begin
  q  = {WIDTH{1'b0}};
end

always @(posedge clk)
begin
	if (clr_ == 1'b1) begin
		q = d;
	end
end

assign q_  = ~q;

endmodule
