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

// am2909 microprogram sequencer

`timescale 1ns /100ps

module am2911(din,cp,cn,oe_,zero_,re_,fe_,pup,s,
			  y,cn4);
parameter WIDTH = 4;
input [WIDTH-1:0] din;
input cp;
input cn;
input oe_;
input zero_;
input re_;
input fe_;
input pup;
input [1:0] s;
output [WIDTH-1:0] y;
output cn4;

reg [WIDTH-1:0] areg;
reg [WIDTH-1:0] upc;
reg [WIDTH-1:0] stack[0:3];
reg [1:0] sp;
wire [WIDTH-1:0] x;
wire [WIDTH-1:0] incin;
wire [WIDTH:0] sum;

initial begin
	sp <= 2'b00;
	upc <= {WIDTH{1'b0}};
end

assign x =  (s==2'b00) ? upc :
			(s==2'b01) ? areg :
			(s==2'b10) ? stack[sp] :
			(s==2'b11) ? din : {WIDTH{1'bx}};
assign incin = x & ((zero_==0) ? {WIDTH{1'b0}} : {WIDTH{1'b1}});
assign y = (oe_==0) ? incin : {WIDTH{1'bz}};
assign sum = incin + { 4'b0000, cn };
assign cn4 = sum[WIDTH];

always @(negedge cp)
begin
	if (re_==0) begin
		areg = din;
	end;
	if (fe_==0) begin
		if (pup==1) begin
			sp = (sp+1) & 2'b11;
			stack[sp] = upc;
		end else begin
			sp = (sp-1) & 2'b11;
		end;
	end;
	
	upc <= sum[WIDTH-1:0];
end

endmodule