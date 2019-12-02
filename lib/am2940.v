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

// am2940 DMA address generator

`define WCR  3'b000
`define RCR  3'b001
`define RWC  3'b010
`define RAC  3'b011
`define INIT 3'b100
`define LDA  3'b101
`define LDW  3'b110
`define ENA  3'b111

`define CM0  2'b00
`define CM1  2'b01
`define CM2  2'b10
`define CM3  2'b11

module am2940(i, a, d, cp, oea_, aci_, aco_, wci_, wco_, done, cp);
input [2:0] i;
inout [7:0] d;
output [7:0] a;
input oea_;
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
		

always @(posedge(cp)) begin
    if (cp=='b1) begin
        case (i)
        `WCR:  creg <= d[2:0];
        `INIT: 
			begin
				wcnt <= (creg[1:0]==`CM1) ? `ZERO : wreg;
				acnt <= areg;
			end
        `LDA: 
            begin
                acnt <= d;
                areg <= d;
            end			
        `LDW:
            begin
                wreg <= d;
                wcnt <= (creg[1:0]==`CM1) ? `ZERO : d;
            end
        `ENA:
            begin
				acnt <= acres;
				if (creg[1:0] != `CM2) wcnt <= wcres;
            end
        default:
            ; // do nothing
        endcase
    end
end

assign aco_   = ~acres[8];
assign wco_   = ~wcres[8];

assign done = (creg[1:0]==`CM0) ? (wcres[7:0] == `ZERO) :
              (creg[1:0]==`CM1) ? (wcres[7:0] == wreg) :
              (creg[1:0]==`CM2) ? (wcnt == acnt) : 'b0;
			  
assign d = (i==`RCR) ? { 5'b11111, creg } :
           (i==`RWC) ? wcnt :
           (i==`RAC) ? acnt : 8'bZZZZZZZZ;

assign a = (oea_=='b0) ? acnt[7:0] : 8'bZZZZZZZZ;

endmodule
