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

// am2942 Programmable Timer/counter, DMA address generator

`define WRCR  4'b0000
`define RDCR  4'b0001
`define RDWC  4'b0010
`define RDAC  4'b0011
`define REIN  4'b0100
`define LDAD  4'b0101
`define LDWC  4'b0110
`define ENCT  4'b0111
`define WCRT  4'b1000
`define REAC  4'b1001
`define RWCT  4'b1010
`define RACT  4'b1011
`define RAWC  4'b1100
`define LDAT  4'b1101
`define LWCT  4'b1110
`define REWC  4'b1111

`define CM0  2'b00
`define CM1  2'b01
`define CM2  2'b10
`define CM3  2'b11

module am2942(i, ien_, d, cp, oed_, aci_, aco_, wci_, wco_, done, cp);
input [3:0] i;
input ien_;
inout [7:0] d;
input oed_;
input aci_, wci_;
output aco_, wco_;
output done;
input cp;

reg [7:0] acnt, wcnt;
reg [7:0] areg, wreg;
reg [2:0] creg;

wire [8:0] acop2, wcop2, acsum, acdif, acres, wcsum, wcdif, wcres;

`define ZERO 8'b00000000

// increment/decrement logic
assign acop2  = { `ZERO, ~aci_ };
assign acsum  = { 1'b0, acnt } + acop2;
assign acdif  = { 1'b0, acnt } - acop2;
assign acres  = (creg[2]=='b1) ? acdif : acsum;

assign wcop2  = { `ZERO, ~wci_ };
assign wcsum  = { 1'b0, wcnt } + wcop2;
assign wcdif  = { 1'b0, wcnt } - wcop2;
assign wcres  = (creg[0]=='b1) ? wcsum :
				(creg[1]=='b0) ? wcdif : wcnt;
				
function [7:0] fdout(input [3:0] i, input ien_, input [2:0] creg, input [7:0] wcnt, acnt);
begin
	if (ien_ == 'b1)
		fdout = (i[3]==0) ? acnt : wcnt;
	else
		case(i)
		`RDCR, `WCRT:	fdout = { 5'b11111, creg };
		`RDWC, `LDAD,
		`RWCT, `LDAT,
		`REWC:			fdout = wcnt;
		`RDAC, `REIN,
		`ENCT, `REAC,
		`RACT, `RAWC:	fdout = acnt;
		default:		fdout = 8'b11111111;
		endcase
end
endfunction

always @(posedge(cp)) begin
    if (cp=='b1) begin
		if (ien_== 'b0) begin
			case (i)
			`WRCR: 	creg <= d[2:0];
			`REIN, `RAWC:
					begin
						wcnt <= (creg[1:0] == `CM1) ? `ZERO : wreg;
						acnt <= areg;
					end
			`LDAD, `LDAT:
					begin
						acnt <= d;
						areg <= d;
						if (i[3] == 'b1) wcnt <= wcres;
					end
			`LDWC, `LWCT:
					begin
						wreg <= d;
						wcnt <= (creg[1:0] ==`CM1) ? `ZERO : d;
						if (i[3]=='b1) acnt <= acres;
					end
			`RWCT, `ENCT:
					begin
						acnt <= acres;
						wcnt <= wcres;
					end			
			`RACT:	begin
						acnt <= acres;
						wcnt <= (creg[1:0] == `CM2) ? `ZERO : wcres;
					end
			`WCRT:	begin
						creg <= d[2:0];
						acnt <= acres;
						wcnt <= wcres;
					end
			`REAC:	begin
						acnt <= areg;
						wcnt <= wcres;
					end
			`REWC:	begin
						acnt <= acres;
						wcnt <= (creg[1:0] ==`CM2) ? `ZERO : wreg;
					end
			default:
				; // do nothing
			endcase
		end else begin	// ien_ == 1
			acnt <= acres;
			if (creg[1:0] != `CM2) wcnt <= wcres;
		end
    end
end

assign aco_   = ~acres[8];
assign wco_   = ~wcres[8];

assign done = (creg[1:0]==`CM0) ? (wcres[7:0] == `ZERO) :
              (creg[1:0]==`CM1) ? (wcres[7:0] == wreg) :
              (creg[1:0]==`CM2) ? (wcnt == acnt) : 'b0;
			  
assign d = 	(oed_=='b1) ? 8'bZZZZZZZZ :
						  fdout(i, ien_, creg, wcnt, acnt);

endmodule
