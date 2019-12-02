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

// test for am2925
// cx is tied to c2

`include "am2925.v"

module am2925_test;

reg l1,l2,l3;
reg halt, run;
reg firstlast;
reg ssno,ssnc;
reg waitreq;
reg ready;
reg init;
reg clkin;

wire c1,cx,c3,c4;
wire f0;
wire waitack;

`define HEADER(title)\
    $display("%0s", title);\
    $display("       lll                                      cccc");\
    $display("-time: 321 fl ini hlt run sso ssc wai rdy clk | 1234 ack | description");

`define SHOW(l3,l2,l1, firstlast, init, halt, run , ssno, ssnc, waitreq, ready, clk, c1,c2,c3,c4, waitack, descr)\
    $display("%5d: %b%b%b  %b  %b   %b   %b   %b   %b   %b   %b   %0s  | %b%b%b%b  %b  | %0s",\
             $time,l3,l2,l1, firstlast, init, halt, run, ssno, ssnc, waitreq, ready, clk, c1, c2, c3,c4, waitack, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %d but is %d", name , expectval, val);       

task setup;
input [80*8-1:0] descr;
input l3val, l2val, l1val;
input flval;
input ival, hval, rval, soval, scval, wrval, rdyval;
begin
    l3 <= l3val; l2 <= l2val; l1 <= l1val;
    firstlast <= flval;
    init <= ival; halt <= hval; run <= rval; ssno <= soval; ssnc <= scval; waitreq <= wrval; ready <= rdyval;
    #1 `SHOW(l3,l2,l1, firstlast, init, halt, run , ssno, ssnc, waitreq, ready, "_", c1,cx,c3,c4, waitack, descr);
end
endtask

task clock;
input [80*8-1:0] descr;
input [3:0] expstate;
input expack;
begin
    clkin <= 'b0;
    #1 clkin <= 'b1;
    #1 clkin <= 'b0;
       `SHOW(l3,l2,l1, firstlast, init, halt, run , ssno, ssnc, waitreq, ready, "^", c1,cx,c3,c4, waitack, descr);
    `assert("FSM State", dut.fsmcnt, expstate);
    `assert("WaitAck", waitack, expack);
end
endtask

am2925 dut(.clkin(clkin),
           .l1(l1), .l2(l2), .l3(l3), .firstlast_(firstlast),
           .init_(init), .halt_(halt), .run_(run), .ssno(ssno), .ssnc(ssnc),
           .waitreq_(waitreq), .cx(cx), .ready_(ready),
           .c1(c1), .c2(cx), .c3(c3), .c4(c4), .f0(f0),
           .waitack_(waitack)
          );
           
initial begin
    //Dump results of the simulation to am2925.vcd
    $dumpfile("am2925.vcd");
    $dumpvars;

//        ------descr-------------------  -l3 -l2 -l1 -fl ini hlt run sso ssc wai rdy
`HEADER("Init F3");
    setup("Initialize F3, free running",  'b0,'b0,'b0,'b1,'b0,'bX,'bX,'bX,'bX,'bX,'bX);
//        ------descr-------------- poststate waitack
    clock("Stabilize",                    1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);

`HEADER("Test Waveform F3");
    setup("Initialize F3",                'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);

`HEADER("Test Waveform F4");
    setup("Initialize F4",                'b0,'b0,'b1,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 2, finish F3",           3,  'b1);
    clock("Cycle 3, finish F3",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);

`HEADER("Test Waveform F5");
    setup("Initialize F5",                'b1,'b0,'b1,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 2, finish F4",           3,  'b1);
    clock("Cycle 3, finish F4",           4,  'b1);
    clock("Cycle 4, finish F4",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);

`HEADER("Test Waveform F6");
    setup("Initialize F6",                'b1,'b1,'b1,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 4, finish F5",           5,  'b1);
    clock("Cycle 5, finish F5",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      6,  'b1);
    clock("Cycle 6",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);

`HEADER("Test Waveform F7");
    setup("Initialize F7",                'b0,'b1,'b1,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 2, finish F6",           3,  'b1);
    clock("Cycle 3, finish F6",           4,  'b1);
    clock("Cycle 4, finish F6",           5,  'b1);
    clock("Cycle 5, finish F6",           6,  'b1);
    clock("Cycle 6, finish F6",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      6,  'b1);
    clock("Cycle 6",                      7,  'b1);
    clock("Cycle 7",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);

`HEADER("Test Waveform F8");
    setup("Initialize F8",                'b0,'b1,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 4, finish F7",           5,  'b1);
    clock("Cycle 5, finish F7",           6,  'b1);
    clock("Cycle 6, finish F7",           7,  'b1);
    clock("Cycle 7, finish F7",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);

`HEADER("Test Waveform F9");
    setup("Initialize F9",                'b1,'b1,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 4, finish F8",           5,  'b1);
    clock("Cycle 5, finish F8",           6,  'b1);
    clock("Cycle 6, finish F8",           7,  'b1);
    clock("Cycle 7, finish F8",           8,  'b1);
    clock("Cycle 8, finish F8",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      6,  'b1);
    clock("Cycle 6",                      7,  'b1);
    clock("Cycle 7",                      8,  'b1);

`HEADER("Test Waveform F10");
    setup("Initialize F10",               'b1,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 8, finish F9",           9,  'b1);
    clock("Cycle 9, finish F9",           1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      6,  'b1);
    clock("Cycle 6",                      7,  'b1);
    clock("Cycle 7",                      8,  'b1);
    clock("Cycle 8",                      9,  'b1);
    clock("Cycle 9",                      10, 'b1);
    clock("Cycle 10",                     1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      4,  'b1);
    clock("Cycle 4",                      5,  'b1);
    clock("Cycle 5",                      6,  'b1);
    clock("Cycle 6",                      7,  'b1);
    clock("Cycle 7",                      8,  'b1);
    clock("Cycle 8",                      9,  'b1);
    
`HEADER("Test Wait/Halt/SST with waveform F3");
    setup("Initialize F3",                'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 9, finish F10",          10, 'b1);
    clock("Cycle 19, finish F10",         1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    
`HEADER("Test Request Wait/Ready");
    setup("Set Waitreq=0",                'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b0,'b1);
    clock("Cycle 2, WaitAck",             3,  'b0);
    setup("Set Waitreq=1",                'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'b1);
    clock("Cycle 2, Waiting",             3,  'b0);
    clock("Cycle 2, Waiting",             3,  'b0);
    clock("Cycle 2, Waiting",             3,  'b0);
    clock("Cycle 2, Waiting",             3,  'b0);
    clock("Cycle 2, Waiting",             3,  'b0);
    setup("Set Ready=0",                  'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'b0);
    clock("Cycle 3, Continuing",          1,  'b1);
    setup("Set Ready=1",                  'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
`HEADER("Test Halt, First/Last_=1");
    setup("Set Halt=0, Run=1",            'b0,'b0,'b0,'b1,'b1,'b0,'b1,'b1,'b0,'b1,'bX);
    clock("Cycle 2, finish",              3,  'b1);
    clock("Cycle 3, finish",              1,  'b1);
    clock("Cycle 1, halting",             1,  'b1);
    clock("Cycle 1",                      1,  'b1);
    clock("Cycle 1",                      1,  'b1);
    setup("Set Run=0",                    'b0,'b0,'b0,'b1,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 1, continuing",          2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
`HEADER("Test Halt, First/Last_=0");
    setup("Set Halt=0, Run=1",            'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bX);
    clock("Cycle 1, finish",              2,  'b1);
    clock("Cycle 2, finish",              3,  'b1);
    clock("Cycle 3, halting",             3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    clock("Cycle 3",                      3,  'b1);
`HEADER("Test Single Step");
//        ------descr-------------------  -l3 -l2 -l1 -fl ini hlt run sso ssc wai rdy
    setup("Push SS button,SSNC=1, SSNO=0",'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b0,'b1,'b1,'bX);
    clock("Cycle 3, enable step",         1,  'b1);
    setup("Release SS button",            'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bX);
    clock("Cycle 1, continuing",          2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3, halt again",          3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    setup("Push SS again",                'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b0,'b1,'b1,'bX);
    clock("Cycle 3, enable step",         1,  'b1);
    clock("Cycle 1, continuing",          2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3, halt again",          3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    setup("Release SS late",              'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bX);
    clock("Cycle 3",                      3,  'b1);
    clock("Cycle 3",                      3,  'b1);
    setup("Set Run=0",                    'b0,'b0,'b0,'b0,'b1,'b1,'b0,'bX,'bX,'b1,'bX);
    clock("Cycle 3, continuing",          1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    clock("Cycle 1",                      2,  'b1);
    clock("Cycle 2",                      3,  'b1);
    clock("Cycle 3",                      1,  'b1);
    
end
endmodule
