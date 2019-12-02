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

// variable width inverting tristate bus transceiver
// am2948 is WIDTH=8, use different WIDTH for larger bus width

module am2948(a, b, tr_, rc_);
parameter WIDTH=8;
inout [WIDTH-1:0] a, b;
input tr_, rc_;

always @(rc_ or tr_) begin
	if (rc_=='b0 && tr_=='b0) begin
		$display("Error: AM2948: RC and TR may not both be 0");
		$stop;
	end
end

assign a = (rc_=='b1) ? {WIDTH{1'bZ}} : ~b;
assign b = (tr_=='b1) ? {WIDTH{1'bZ}} : ~a;

endmodule
