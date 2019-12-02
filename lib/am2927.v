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

// am2927 quad/n-bit tristate bus drivers with clock enable
// user parameter WIDTH to extend to N bits
// am2927 is WIDTH=4

module am2927(d, s, endr_, be_, rle_, oe_, cp, bus_, y);
parameter WIDTH=4;
input [WIDTH-1:0] d;
input s, endr_, be_, rle_, oe_;
input cp;
inout [WIDTH-1:0] bus_;
output [WIDTH-1:0] y;

reg [WIDTH-1:0] dreg;
reg [WIDTH-1:0] rlatch;

wire [WIDTH-1:0] dmux, ndreg;
wire [WIDTH-1:0] rmux;

assign dmux = (s=='b0) ? d :
              (rle_=='b0) ? bus_ : ~rlatch;
assign ndreg = ~dreg;
assign rmux = (s & endr_) ? ndreg : bus_;

assign bus_ = (be_=='b0) ? ndreg : {WIDTH{1'bZ}};

// driver reg
always @(posedge(cp)) begin
    if (cp=='b1 && endr_=='b0)
        dreg <= dmux;
end

// latch
always @(rle_) begin
    if (rle_=='b1)
        rlatch <= rmux;
end

assign y = (oe_=='b1) ? {WIDTH{1'bZ}} :
           ~((rle_=='b1) ? rlatch : rmux);
            
endmodule
