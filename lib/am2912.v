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

// am2912 n-bit/quad open collector bus transceiver
// use parameter WIDTH for different sizes
// 2912 is WIDTH=4

// note: to make an open collector BUS in Verilog, test if bus is 0, otherwise pull it up to 1
// this driver will only pull outputs low

module am2912(i, e_, b_, z);
parameter WIDTH=4;
input [WIDTH-1:0] i;
input e_;
inout [WIDTH-1:0] b_;
output [WIDTH-1:0] z;

genvar n;

for (n=0; n<WIDTH; n=n+1) begin
  assign b_[n] = (e_=='b0 && i[n]=='b1) ? 'b0 : 'bZ;
  assign z[n] =  (b_[n]==='b0) ? 'b1 : 'b0;
end

endmodule
