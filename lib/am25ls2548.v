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

// AM25LS2548 eight bit decoder/demultiplexer with storage

module am25ls2548(a, b, c, e1_, e2_, e3, e4, rd_, wr_, y, ack_);
input a, b, c;
input e1_, e2_, e3, e4;
input rd_, wr_;
output ack_;
output [7:0] y;

wire [2:0] cba;
wire e, rw;

assign cba = { c, b, a };
assign e = ~e1_ & ~e2_ & e3 & e4;
assign rw = ~(rd_ & wr_);

assign y =  (e=='b0) ? 'b1111_1111 :
            (cba=='b000) ? 'b1111_1110 :
            (cba=='b001) ? 'b1111_1101 :
            (cba=='b010) ? 'b1111_1011 :
            (cba=='b011) ? 'b1111_0111 :
            (cba=='b100) ? 'b1110_1111 :
            (cba=='b101) ? 'b1101_1111 :
            (cba=='b110) ? 'b1011_1111 :
                           'b0111_1111;
assign ack_ = ~(e & rw);

endmodule
 
    
