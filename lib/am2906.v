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

// am2906 bus transceiver with parity

// user parameter WIDTH to configure bus width
// am2905 is by default WIDTH=4

module am2906(a,b,sel,drcp,be_,
			  bus_,
			  rle_, r, odd);
parameter WIDTH=4;
input [WIDTH-1:0] a, b;
input sel, drcp, be_;
inout [WIDTH-1:0] bus_;
input rle_;
output [WIDTH-1:0] r;
output odd;

wand [WIDTH-1:0] bus_;
wire [WIDTH-1:0] insel;

reg [WIDTH-1:0] dreg;
reg [WIDTH-1:0] rlatch;

assign insel = (sel==1'b0) ? a : b;

always @(posedge drcp) begin
	if (drcp==1'b1) begin
		dreg = insel;
	end
end

assign bus_ = (be_ === 1'b0) ? ~dreg : {WIDTH{1'bz}};

always @(bus_,rle_) begin
	if (rle_==1'b0) begin
		rlatch = ~bus_;
	end else if (rle_===1'bx) begin
		rlatch = {WIDTH{1'bx}};
	end
end

assign r = (rle_===1'b0) ? ~bus_ : rlatch;
assign odd = (be_==1'b0) ? ^insel : ^rlatch;

endmodule
