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

// AM25LS2535 eight bit multiplexer with control register

module am25ls2535(a, b, c, pol, d, me_, re_, clr_, oe_, clk, y);
input a, b, c;
input [7:0] d;
input me_, re_, clr_, oe_, pol;
input clk;
output y;

reg [2:0] selreg;
wire yp;
reg polreg;

always @(clr_ or posedge(clk)) begin
    if (clr_ == 'b0) begin
        selreg <= 'b000;
        polreg <= 'b0;
    end else if (re_ == 'b0 && clk == 'b1) begin
        selreg <= { c, b, a };
        polreg <= pol;
    end
end

assign yp = (me_== 'b0) ? d[selreg] : 'b1;
assign y = (oe_=='b1) ? 'bZ : (yp ^ polreg);
endmodule
 
    
