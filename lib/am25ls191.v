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

// am25ls191 parameterized binary up/down counter
// use parameter WIDTH to extend it to >4 bits
// parameter WIDTH=4 is standard 74ls191/am25ls191

module am25ls191(in, load_, ent_, ud, clk, q, rco_, mxmn);
parameter WIDTH = 4;
input [WIDTH-1:0] in;
input load_, ent_, ud, clk;
output [WIDTH-1:0] q;
output rco_, mxmn;

reg [WIDTH-1:0] ctr;
wire all0, all1;

always @(posedge(clk)) begin
    if (ent_=='b0) begin
        if (load_=='b0)
            ctr <= in;
        else if (ud == 'b0)
            ctr <= ctr + 1;
        else
            ctr <= ctr - 1;
    end
end

assign all0 = |ctr;
assign all1 = &ctr;
assign mxmn = (ud=='b0) ? all1 : ~all0;
assign rco_ = ~(mxmn & ~clk);
assign q = ctr;

endmodule
