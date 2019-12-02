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

// variable width noninverting tristate bidirectional I/O port
// am2950 is WIDTH=8, use different WIDTH for larger bus width

module am2950(cpr, cer_, a, oea_, fr, clrr,
			  cps, ces_, b, oeb_, fs, clrs);
parameter WIDTH=8;
input cpr, cer_, oea_, clrr;
inout [WIDTH-1:0] a;
output fr;
input cps, ces_, oeb_, clrs;
inout [WIDTH-1:0] b;
output fs;

reg [WIDTH-1:0] r, s;
reg fr, fs;

always @(posedge(cpr)) begin
	if (cpr == 'b1 && cer_ == 'b0) begin
		fr <= 'b1;
		r <= a;
	end
end

always @(posedge(cps)) begin
	if (cps == 'b1 && ces_ == 'b0) begin
		fs <= 'b1;
		s <= b;
	end
end

always @(posedge(clrr)) begin
	if (clrr == 'b1)
		fr <= 'b0;
end

always @(posedge(clrs)) begin
	if (clrs == 'b1)
		fs <= 'b0;
end

assign a = (oea_=='b0) ? s : {WIDTH{1'bZ}};
assign b = (oeb_=='b0) ? r : {WIDTH{1'bZ}};

endmodule
