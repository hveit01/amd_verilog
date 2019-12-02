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

// 16x4 dual port RAM
module am29705(a, b, d, we1_, we2_, le_, oea_, oeb_, alo_, ya, yb);
input [3:0] a, b;
input [3:0] d;
input we1_, we2_, le_;
input oea_, oeb_;
input alo_;
output [3:0] ya, yb;

reg [3:0] ram[0:15];
reg [3:0] alatch, blatch;

// RAM latches
always @(negedge le_) begin
    if (le_=='b0) begin
        alatch <= ram[a];
        blatch <= ram[b];
    end
end

// RAM write
always @(we1_ or we2_ or d) begin
    if (~(we1_ | we2_))
       ram[b] <= d;
end

// outputs
assign ya = (oea_=='b1) ? 'bZZZZ :
            (alo_=='b0) ? 'b0000 : 
            (le_ =='b1) ? ram[a] : alatch;
assign yb = (oeb_=='b1) ? 'bZZZZ :
            (le_ =='b1) ? ram[b] : blatch;

endmodule
