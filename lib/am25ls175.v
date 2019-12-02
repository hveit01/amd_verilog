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

// am25ls175 6-DFF with clear
`include "am25ls174.v"
`timescale 1ns / 100ps

module am25ls175(d, q, q_, clk, clr_);
input [3:0] d;
output [3:0] q, q_;
input clk, clr_;

am25ls174 #(.WIDTH(4)) u0 (
	.d(d), 
	.q(q),
	.q_(q_),
	.clk(clk),
	.clr_(clr_)
);
	
endmodule
