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

// am27s27 512*n bit ROM with pipeline register
// use parameter WIDTH to set output width

// am27s27 is WIDTH=8

`include "_genrom.v"

module am27s27(a, q, clk, e1_, e2_);
parameter WIDTH = 8;
parameter HEIGHT = 9;
parameter INITH = "";
parameter INITB = "";

input [HEIGHT-1:0] a;
output [WIDTH-1:0] q;
input clk;
input e1_, e2_;

wire [WIDTH-1:0] romout;
reg [WIDTH-1:0] pipeline;
reg dff;

initial begin
	dff = 1'b1;
end

_genrom #(.WIDTH(WIDTH),.HEIGHT(HEIGHT), .INITH(INITH), .INITB(INITB)) 
u0(
	.a(a), .q(romout), .cs1_(1'b0), .cs2_(1'b0)
);

always @(posedge clk) begin
	if (clk==1'b1) begin
		dff = e2_;
		pipeline = romout;
	end
end

assign q = (e1_ == 1'b0 && dff == 1'b0) ? pipeline : {WIDTH{1'bz}};

endmodule
