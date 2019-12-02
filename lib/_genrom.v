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

// generic WIDTH*HEIGHT ROM
// configure this with PARAMETERS WIDTH AND SIZE!

// WIDTH = bit width of output
// HEIGHT = number of address bits
// INITH = bitmap init file ($readmemb)
// INITB = hex init file ($readmemh)

`timescale 1ns / 100ps

module _genrom(a, q, cs1_, cs2_);
parameter WIDTH = 4;
parameter HEIGHT = 8;
parameter INITH = "";
parameter INITB = "";
input [HEIGHT-1:0] a;
output [WIDTH-1:0] q;
input cs1_, cs2_;

reg [WIDTH-1:0] rom[0:2**HEIGHT-1];

assign q = (cs1_==1'b0 && cs2_==1'b0) ? rom[a] : {WIDTH{1'bz}};

initial begin
    if (INITH != "") begin
        $display("Loading ROM from %0s", INITH);
        $readmemh(INITH, rom);
    end else if (INITB != "") begin
        $display("Loading ROM from %0s", INITB);
        $readmemh(INITB, rom);
    end
end

endmodule
