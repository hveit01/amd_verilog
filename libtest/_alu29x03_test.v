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

`include "_alu29x03.v"

// basic function check of ALU

module test_alu29x03;
reg [3:0] a,b;
reg [12:0] ctrl;
reg cn;

wire gg, gp, n, ovr, cn4, bcdc4;
output [3:0] f;

_alu29x03 dut(
    .a(a), .b(b), 
    .ctrl(ctrl), 
    .cn(cn), 
    .gg(gg), .gp(gp), 
    .n(n), 
    .ovr(ovr), 
    .cn4(cn4), .bcdc4(bcdc4), 
    .f(f)
);

task check;
input [80*8-1:0] descr;
input [3:0] ai, bi;
input api, bpi, aei, bei, ji, ki, mi, cni;
begin
  a <= ai; b <= bi;
  ctrl[6:0] <= { mi, ki, ji, bei, aei, bpi, api };
  ctrl[10:7] = 4'b0000;
  ctrl[27:26] = 2'b00;
  cn <=cni;
  #1 $display("%4b %4b %7b %b  | %4b | %0s", a, b, ctrl[6:0], cn, f, descr);
end
endtask

initial begin

// apol=1 invert a signal
// bpol=1 invert b signal
// aen=1  enable a/~a signal
// ben=1  enable b/~b signal
// j=1    enable G and gate for bool ops
// k=1    enable bool ops
// m=1    invert result

  $display("             baba");
  $display("-a-- -b-- mkjeepp c0 | -f-- | ----operation------");
  check("f = 0000",              4'bxxxx, 4'bxxxx,  'bx,'bx,'b0,'b0,'b0,'b0,'b0,  'bx);
  check("f = 1111",              4'bxxxx, 4'bxxxx,  'bx,'bx,'b0,'b0,'b0,'b0,'b1,  'bx);
  check("f =   a ^ b",           4'b1100, 4'b1010,  'b0,'b0,'b1,'b1,'b0,'b0,'b0,  'bx);
  check("f = ~(a ^ b)",          4'b1100, 4'b1010,  'b1,'b0,'b1,'b1,'b0,'b0,'b0,  'bx);
  check("f = ~(a & b)",          4'b1100, 4'b1010,  'b0,'b0,'b1,'b1,'b1,'b0,'b0,  'bx);
  check("f = ~(a | b)",          4'b1100, 4'b1010,  'b1,'b1,'b1,'b1,'b1,'b0,'b1,  'bx);
  check("f =  ~a & b",           4'b1100, 4'b1010,  'b1,'b0,'b1,'b1,'b1,'b0,'b1,  'bx);
  check("f =   a & ~b",          4'b1100, 4'b1010,  'b0,'b1,'b1,'b1,'b1,'b0,'b1,  'bx);
  check("f =   a & b",           4'b1100, 4'b1010,  'b0,'b0,'b1,'b1,'b1,'b0,'b1,  'bx);
  check("f =  ~a | b",           4'b1100, 4'b1010,  'b0,'b1,'b1,'b1,'b1,'b0,'b0,  'bx);
  check("f =   a | ~b",          4'b1100, 4'b1010,  'b1,'b0,'b1,'b1,'b1,'b0,'b0,  'bx);
  check("f =   a | b",           4'b1100, 4'b1010,  'b1,'b1,'b1,'b1,'b1,'b0,'b0,  'bx);
  check("f =   a",               4'b1100, 4'b1010,  'b0,'bX,'b1,'b0,'b0,'b0,'b0,  'bx);
  check("f =  ~a",               4'b1100, 4'b1010,  'b1,'bX,'b1,'b0,'b0,'b0,'b0,  'bx);
  check("f =   b",               4'b1100, 4'b1010,  'bX,'b0,'b0,'b1,'b0,'b0,'b0,  'bx);
  check("f =  ~b",               4'b1100, 4'b1010,  'bX,'b1,'b0,'b1,'b0,'b0,'b0,  'bx); 
  check("f =   a + c(0)",        4'b1100, 4'bXXXX,  'b0,'bX,'b1,'b0,'b0,'b1,'b0,  'b0);
  check("f =   a + c(1)",        4'b1100, 4'bXXXX,  'b0,'bX,'b1,'b0,'b0,'b1,'b0,  'b1);
  check("f =  ~a + c(0)",        4'b1100, 4'bXXXX,  'b1,'bX,'b1,'b0,'b0,'b1,'b0,  'b0);
  check("f =  ~a + c(1)",        4'b1100, 4'bXXXX,  'b1,'bX,'b1,'b0,'b0,'b1,'b0,  'b1);
  check("f =   b + c(1)",        4'bXXXX, 4'b0101,  'bX,'b0,'b0,'b1,'b0,'b1,'b0,  'b1);
  check("f =  ~b + c(1)",        4'bXXXX, 4'b0101,  'bX,'b1,'b0,'b1,'b0,'b1,'b0,  'b1);
  check("f =   a + b + c(0)",    4'b0101, 4'b0100,  'b0,'b0,'b1,'b1,'b0,'b1,'b0,  'b0);
  check("f =   a + b + c(1)",    4'b0101, 4'b0100,  'b0,'b0,'b1,'b1,'b0,'b1,'b0,  'b1);
  check("f =   a - b - 1 + c",   4'b0101, 4'b0100,  'b0,'b1,'b1,'b1,'b0,'b1,'b0,  'b1);
  check("f =   b - a - 1 + c",   4'b0100, 4'b0101,  'b1,'b0,'b1,'b1,'b0,'b1,'b0,  'b1);

end

endmodule

