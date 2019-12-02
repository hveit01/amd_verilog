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

// AM25LS2536 eight bit decoder/demultiplexer with storage

module am25ls2536(a, b, c, pol, clr_, ce_, oe_, g1_, g2, clk, y);
input a, b, c;
input pol, clr_, ce_, oe_, g1_, g2;
input clk;
output [7:0] y;

reg [2:0] selreg;
reg polreg;

wire [7:0] yp;

always @(clr_ or posedge(clk)) begin
    if (clr_ == 'b0) begin
        selreg <= 'b000;
        polreg <= 'b0;
    end else if (clk == 'b1 && ce_ == 'b0) begin
        selreg <= { c, b, a };
        polreg <= pol;
    end
end

assign g = ~g1_ & g2;
assign yp = (g=='b0) ? 'b1111_1111 :
            (selreg=='b000) ? 'b1111_1110 :
            (selreg=='b001) ? 'b1111_1101 :
            (selreg=='b010) ? 'b1111_1011 :
            (selreg=='b011) ? 'b1111_0111 :
            (selreg=='b100) ? 'b1110_1111 :
            (selreg=='b101) ? 'b1101_1111 :
            (selreg=='b110) ? 'b1011_1111 :
                              'b0111_1111;
assign y = (oe_ == 'b1) ? 'bZZZZ_ZZZZ :
           (polreg=='b0) ? yp : ~yp;

endmodule
 
    
