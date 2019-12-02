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

// AM25LS2521 eight/N bit equal comparator
// use parameter WIDTH for different sizes
// for 2521 WIDTH=8

module am25ls2521(a, b, ein_, eout_);
parameter WIDTH=8;
input [WIDTH-1:0] a, b;
input ein_;
output eout_;

assign eout_ = ein_ | |(a ^ b);

endmodule
 
    
