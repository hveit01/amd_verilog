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

// am2928 testbench

`include "am2928.v"

module am2928_test;
parameter WIDTH=4;
reg [WIDTH-1:0] d, busin;
reg s, endr, cp, be, enrec, oe;
wire [WIDTH-1:0] bus, y;

`define HEADER(title)\
    $display("%0s", title);\
    $display("-----: -d-- -s end be enr oe cp | -y-- -bus | description");

`define SHOW(d, s, endr, be, enrec, oe, cp, y, bus, descr)\
    $display("%5d: %4b  %b  %b   %b  %b   %b  %0s | %4b %4b | %0s",\
             $time,d,   s,  endr,be, enrec,oe,cp,   y,  bus,  descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task tester;
input [80*8-1:0] descr;
input [WIDTH-1:0] dval, busval;
input sval, endrval, beval, enrecval, oeval;
input [WIDTH-1:0] expecty, expectbus;
begin
    d <= dval; busin <= busval;
    s <= sval; endr <= endrval; be <= beval; enrec <= enrecval; oe <= oeval;
    cp <= 'b0;
    #1 ; // `SHOW(d, s, endr, be, enrec, oe, " ", y, bus, "");
    cp <= 'b1;
    #1 `SHOW(d, s, endr, be, enrec, oe, "^", y, bus, descr);
    `assert("Y", y, expecty);
    `assert("BUS_", bus, expectbus);
    cp <= 'b0;
    #1 ; // `SHOW(d, s, endr, be, enrec, oe, " ", y, bus, "");
end
endtask

assign bus = busin;

am2928 dut(.d(d), 
           .s(s), .endr_(endr), .be_(be), .enrec_(enrec), .oe_(oe),
           .cp(cp),
           .y(y), .bus_(bus)
          );

initial begin
    //Dump results of the simulation to am2928.vcd
    $dumpfile("am2928.vcd");
    $dumpvars;

//         ------descr------------------- ---d-- -bus-- -s- end -be enr -oe ex_y-- ex_bus
`HEADER("");
    tester("Tristate OE",                 'bXXXX,'bXXXX,'bX,'bX,'bX,'bX,'b1,'bZZZZ,'bXXXX);
    tester("Tristate BUS_",               'bXXXX,'bZZZZ,'bX,'bX,'b1,'bX,'bX,'bXXXX,'bZZZZ);
    tester("Load Driver from D",          'b1010,'bZZZZ,'b0,'b0,'b0,'bX,'bX,'bXXXX,'b0101);
    tester("Hold Driver",                 'bXXXX,'bZZZZ,'bX,'b1,'b0,'bX,'bX,'bXXXX,'b0101);
    tester("Load Receiver from BUS_",     'bXXXX,'b1011,'b0,'bX,'b1,'b0,'b0,'b0100,'b1011);  
    tester("Load Receiver from BUS_",     'bXXXX,'b1101,'bX,'b0,'b1,'b0,'b0,'b0010,'b1101);
    tester("Hold Receiver",               'bXXXX,'bXXXX,'bX,'bX,'b1,'b1,'b0,'b0010,'bXXXX);
    tester("Load Driver from Receiver",   'bXXXX,'bXXXX,'b1,'b0,'b1,'b1,'bX,'bXXXX,'bXXXX);
    tester("Driver to BUS_",              'bXXXX,'bZZZZ,'bX,'b1,'b0,'b1,'b0,'b0010,'b1101);
    tester("Load Driver from D",          'b0000,'bZZZZ,'b0,'b0,'b0,'b1,'b0,'b0010,'b1111);
end
endmodule
