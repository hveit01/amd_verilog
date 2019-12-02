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

// test for am2904

//am2904 functions
//111
//2109876543210   usr                 msr             y       ct                  c0
//-------------   ------------------- --------------- ------- ------------------- -----
//XXXXXXX000000   msr                 y               input   (un ^ uo) | uz      uc
//XXXXXXX000001   1111                1111            usr     (un ~^ uo) & ~uz    uc
//XXXXXXX000010   msr                 usr             usr     un ^ uo             uc
//XXXXXXX000011   0000                0000            usr     un ~^ uo            uc
//XXXXXXX000100   {iz,ic,in,io}       {iz,mo,in,mc}   usr     uz                  uc
//XXXXXXX000101   {iz,ic,in,io}       ~msr            usr     ~uz                 uc
//XXXXXXX000110   {iz,ic,in,io|uo}    {iz,ic,in,io}   usr     uo                  uc
//XXXXXXX000111   {iz,ic,in,io|uo}    {iz,ic,in,io}   usr     ~uo                 uc
//
//XXXXXXX001000   uz=0                {iz,ic,in,io}   usr     uc | uz             ~uc
//XXXXXXX001001   uz=1                {iz,ic,in,io}   usr     ~uc & ~uz           ~uc
//XXXXXXX001010   uc=0                {iz,ic,in,io}   usr     uc                  uc
//XXXXXXX001011   uc=1                {iz,ic,in,io}   usr     ~uc                 uc
//XXXXXXX001100   un=0                {iz,ic,in,io}   usr     ~uc | uz            uc
//XXXXXXX001101   un=1                {iz,ic,in,io}   usr     uc & ~uz            uc
//XXXXXXX001110   uo=0                {iz,ic,in,io}   usr     in ~^ mn            uc
//XXXXXXX001111   uo=1                {iz,ic,in,io}   usr     in ^ mn             uc
//
//XXXXXXX010000   {iz,ic,in,io}       {iz,ic,in,io}   usr     (un ^ uo) | uz      uc
//XXXXXXX010001   {iz,ic,in,io}       {iz,ic,in,io}   usr     (un ~^ uo ) & ~uz   uc
//XXXXXXX010010   {iz,ic,in,io}       {iz,ic,in,io}   usr     un ^ uo             uc
//XXXXXXX010011   {iz,ic,in,io}       {iz,ic,in,io}   usr     un ~^ uo            uc
//XXXXXXX010100   {iz,ic,in,io}       {iz,ic,in,io}   usr     uz                  uc
//XXXXXXX010101   {iz,ic,in,io}       {iz,ic,in,io}   usr     ~uz                 uc
//XXXXXXX010110   {iz,ic,in,io}       {iz,ic,in,io}   usr     uo                  uc
//XXXXXXX010111   {iz,ic,in,io}       {iz,ic,in,io}   usr     ~uo                 uc
//
//XXXXXXX011000   {iz,~ic,in,io}      {iz,~ic,in,io}  usr     uc | uz             ~uc
//XXXXXXX011001   {iz,~ic,in,io}      {iz,~ic,in,io}  usr     ~uc & ~uz           ~uc
//XXXXXXX011010   {iz,ic,in,io}       {iz,ic,in,io}   usr     uc                  uc
//XXXXXXX011011   {iz,ic,in,io}       {iz,ic,in,io}   usr     ~uc                 uc
//XXXXXXX011100   {iz,ic,in,io}       {iz,ic,in,io}   usr     ~uc | uz            uc
//XXXXXXX011101   {iz,ic,in,io}       {iz,ic,in,io}   usr     uc & ~uz            uc
//XXXXXXX011110   {iz,ic,in,io}       {iz,ic,in,io}   usr     un                  uc
//XXXXXXX011111   {iz,ic,in,io}       {iz,ic,in,io}   usr     ~un                 uc
//
//XXXXXXX100000   {iz,ic,in,io}       {iz,ic,in,io}   msr     (mn ^ mo) | mz      mc
//XXXXXXX100001   {iz,ic,in,io}       {iz,ic,in,io}   msr     (mn ~^ mo) & ~mz    mc
//XXXXXXX100010   {iz,ic,in,io}       {iz,ic,in,io}   msr     mn ^ mo             mc
//XXXXXXX100011   {iz,ic,in,io}       {iz,ic,in,io}   msr     mn ~^ mo            mc
//XXXXXXX100100   {iz,ic,in,io}       {iz,ic,in,io}   msr     mz                  mc
//XXXXXXX100101   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~mz                 mc
//XXXXXXX100110   {iz,ic,in,io}       {iz,ic,in,io}   msr     mo                  mc
//XXXXXXX100111   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~mo                 mc
//
//XXXXXXX101000   {iz,~ic,in,io}      {iz,ic,in,io}   msr     mc | mz             ~mc
//XXXXXXX101001   {iz,~ic,in,io}      {iz,ic,in,io}   msr     ~mc & ~mz           ~mc
//XXXXXXX101010   {iz,ic,in,io}       {iz,ic,in,io}   msr     mc                  mc
//XXXXXXX101011   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~mc                 mc
//XXXXXXX101100   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~mc | mz            mc
//XXXXXXX101101   {iz,ic,in,io}       {iz,ic,in,io}   msr     mc & ~ mz           mc
//XXXXXXX101110   {iz,ic,in,io}       {iz,ic,in,io}   msr     ct <= mn            mc
//XXXXXXX101111   {iz,ic,in,io}       {iz,ic,in,io}   msr     ct <= ~mn           mc
//
//XXXXXXX110000   {iz,ic,in,io}       {iz,ic,in,io}   msr     (in ^ io) | iz      mc
//XXXXXXX110001   {iz,ic,in,io}       {iz,ic,in,io}   msr     (in ~^ io) & ~iz    mc
//XXXXXXX110010   {iz,ic,in,io}       {iz,ic,in,io}   msr     in ^ io             mc
//XXXXXXX110011   {iz,ic,in,io}       {iz,ic,in,io}   msr     in ~^ io            mc
//XXXXXXX110100   {iz,ic,in,io}       {iz,ic,in,io}   msr     iz                  mc
//XXXXXXX110101   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~iz                 mc
//XXXXXXX110110   {iz,ic,in,io}       {iz,ic,in,io}   msr     io                  mc
//XXXXXXX110111   {iz,ic,in,io}       {iz,ic,in,io}   msr     ~io                 mc
//
//XXXXXXX111000   {iz,~ic,in,io}      {iz,ic,in,io}   i       ~ic | iz            ~mc
//XXXXXXX111001   {iz,~ic,in,io}      {iz,ic,in,io}   i       ic & ~iz            ~mc
//XXXXXXX111010   {iz,ic,in,io}       {iz,ic,in,io}   i       ic                  mc
//XXXXXXX111011   {iz,ic,in,io}       {iz,ic,in,io}   i       ~ic                 mc
//XXXXXXX111100   {iz,ic,in,io}       {iz,ic,in,io}   i       ~ic | iz            mc
//XXXXXXX111101   {iz,ic,in,io}       {iz,ic,in,io}   i       ic & ~iz            mc
//XXXXXXX111110   {iz,ic,in,io}       {iz,ic,in,io}   i       in                  mc
//XXXXXXX111111   {iz,ic,in,io}       {iz,ic,in,io}   i       ~in                 mc
//
//00XXXXXXXXXXX   c0 <= 0
//01XXXXXXXXXXX   c0 <= 1
//10XXXXXXXXXXX   c0 <= cx
//
//
//111
//2109876543210   MC      RAM         Q
//-------------   ------  ----------  ---------
//XX00000XXXXXX   no      0->SHR->    0->SHR->
//XX00001XXXXXX   no      1->SHR->    1->SHR->
//XX00010XXXXXX   sio0    0->SHR->c   n->SHR->
//XX00011XXXXXX   no      1->SHR------->SHR->
//XX00100XXXXXX   no      c->SHR------->SHR->
//XX00101XXXXXX   no      n->SHR------->SHR->
//XX00110XXXXXX   no      0->SHR------->SHR->
//XX00111XXXXXX   qio0    0->SHR------->SHR->n
//XX01000XXXXXX   sio0    s0->ROTR->  q0->ROTR->
//XX01001XXXXXX   sio0    c->ROTR->c  q0->ROTR->
//XX01010XXXXXX   no      s0->ROTR->  q0->ROTR->
//XX01011XXXXXX   no      ic->SHR------>SHR->
//XX01100XXXXXX   qio0    c->SHR------->SHR->c
//XX01101XXXXXX   qio0    q0->SHR------>SHR->s0
//XX01110XXXXXX   no      n^o->SHR----->SHR->
//XX01111XXXXXX   no      q0->SHR------>SHR->
//XX10000XXXXXX   sion    c<-SHL<-0   <-SHL<-0
//XX10001XXXXXX   sion    c<-SHL<-1   <-SHL<-1
//XX10010XXXXXX   no      <-SHL<-0    <-SHL<-0
//XX10011XXXXXX   no      <-SHL<-1    <-SHL<-1
//XX10100XXXXXX   sion    c<-SHL<-------SHL<-0
//XX10101XXXXXX   sion    c<-SHL<-------SHL<-1
//XX10110XXXXXX   no      <-SHL<--------SHL<-0
//XX10111XXXXXX   no      <-SHL<--------SHL<-1
//XX11000XXXXXX   sion    c<-ROTL<-sn <-ROTL<-qn
//XX11001XXXXXX   sion    c<-ROTL<-c  <-ROTL<-qn
//XX11010XXXXXX   no      <-ROTL<-sn  <-ROTL<-qn
//XX11011XXXXXX   no      <-SHL<-c    <-SHL<-0
//XX11100XXXXXX   sion    c<-SHL<-------SHL<-c
//XX11101XXXXXX   sion    c<-SHL<-------SHL<-sn
//XX11110XXXXXX   no      <-SHL<--------SHL<-c
//XX11111XXXXXX   no      <-SHL<--------SHL<-sn

`include "am2904.v"

module am2904_test;
reg [12:0] inst;
reg cem, ceu, se;
reg [3:0] i, e, yi;
reg oey, oect;

wire [3:0] y;
wire ct;

reg [1:0] sioi, qioi;
wire [1:0] sio, qio;

reg cx;
wire c0;

reg cp;

wire [3:0] dutusr, dutmsr;

`define HEADER(title)\
    $display("%0s", title);\
    $display("     :               -i-- -e-- yin- c c o o s sio qio c | yout sio qio c c |");\
    $display("-----: -----inst---- zcno zcno zcno m u e c e n0  n0  x | zcno n0  n0  0 t | description");

`define SHOW(inst, ival, eval, yval, cem, ceu, oey, oect, se, sioi,qioi, cx, y, sio,qio, c0, ct, descr)\
    $display("%5d: %12b %4b %4b %4b %b %b %b %b %b %2b  %2b  %b | %4b %2b  %2b  %b %b | %0s",\
        $time, inst, ival, eval, yval, cem, ceu, oey, oect, se, sioi,qioi, cx, y, sio,qio, c0, ct, descr);

`define assert(name, val, expectval)\
    if (val !== expectval)\
        $display("Error: %0s should be %b but is %b", name , expectval, val);       

task setup;
input [80*8-1:0] descr;
input [12:0] instval;
input [3:0] yval;
input [3:0] ival, eval;
input cemval, ceuval, oeyval, oectval, seval;
input [1:0] sioval, qioval;
input cxval;
input [3:0] expecty;
input [1:0] expectsio, expectqio;
input expectc0, expectct;
input [3:0] expectusr, expectmsr;
begin
    inst <= instval;
    yi <= yval;
    i <= ival;
    e <= eval;
    cem <= cemval; ceu <= ceuval; oey <= oeyval; oect <= oectval;
    sioi <= sioval; qioi <= qioval;
    se <= seval; cx <= cxval;
    
    cp <= 'b0;
    #1 cp <= 'b1;
    #1 cp <= 'b0;
//    `SHOW(inst, ival, eval, yval, cem, ceu, oey, se, sioi,qioi, cx,  y, sio,qio, c0, ct, descr);
    `assert("YZ", y[3], expecty[3]);
    `assert("YC", y[2], expecty[2]);
    `assert("YN", y[1], expecty[1]);
    `assert("YO", y[0], expecty[0]);
    `assert("SIO0", sio[0], expectsio[0]);
    `assert("SION", sio[1], expectsio[1]);
    `assert("QIO0", qio[0], expectqio[0]);
    `assert("QION", qio[1], expectqio[1]);
    `assert("C0", c0, expectc0);
    `assert("CT", ct, expectct);
    `assert("uSR", dutusr, expectusr);
    `assert("MSR", dutmsr, expectmsr);
end
endtask

task tester;
input [80*8-1:0] descr;
input [12:0] instval;
input [3:0] yval, ival, eval;
input cemval, ceuval, oeyval, oectval, seval;
input [1:0] sioval, qioval;
input cxval;
input [3:0] expecty;
input [1:0] expectsio, expectqio;
input expectc0, expectct;
input [3:0] expectusr, expectmsr;
begin

    inst <= instval;
    yi <= yval;
    i <= ival;
    e <= eval;
    cem <= cemval; ceu <= ceuval; oey <= oeyval; oect <= oectval;
    sioi <= sioval; qioi <= qioval;
    se <= seval; cx <= cxval;
    cp <= 'b0;
    #1 cp <= 'b1;
    #1 cp <= 'b0;
    `SHOW(inst, ival, eval, yval, cem, ceu, oey, oect, se, sioi,qioi, cx, y, sio,qio, c0, ct, descr);
    `assert("YZ", y[3], expecty[3]);
    `assert("YC", y[2], expecty[2]);
    `assert("YN", y[1], expecty[1]);
    `assert("YO", y[0], expecty[0]);
    `assert("SIO0", sio[0], expectsio[0]);
    `assert("SION", sio[1], expectsio[1]);
    `assert("QIO0", qio[0], expectqio[0]);
    `assert("QION", qio[1], expectqio[1]);
    `assert("C0", c0, expectc0);
    `assert("CT", ct, expectct);
    `assert("uSR", dutusr, expectusr);
    `assert("MSR", dutmsr, expectmsr);
end
endtask

am2904 dut(
    .yz(y[3]), .yc(y[2]), .yn(y[1]), .yovr(y[0]),
    .ez_(e[3]), .ec_(e[2]), .en_(e[1]), .eovr_(e[0]),
    .iz(i[3]), .ic(i[2]), .in(i[1]), .iovr(i[0]),
    .i(inst), .cem_(cem), .ceu_(ceu), .oey_(oey), .oect_(oect),
    .sio0(sio[0]), .sion(sio[1]), .qio0(qio[0]), .qion(qio[1]),
    .se_(se), .c0(c0), .cx(cx), .ct(ct), .cp(cp)
);

assign sio = sioi;
assign qio = qioi;
assign y   = yi;

// peek into chip registers
assign dutusr = { dut.usr_z, dut.usr_c, dut.usr_n, dut.usr_ovr };
assign dutmsr = { dut.msr_z, dut.msr_c, dut.msr_n, dut.msr_ovr };

initial begin
`HEADER("Test Tristate");
    tester("XX: Check OEY",                 'bXX_00000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'bX,'bX,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bZZZZ, 'bZZ,'bZZ, 'bX,'bZ,'bxxxx,'bXXXX);
`HEADER("Test uSR, MSR load, Y <= uSR");
    tester("00: Load MSR <= Y(0000)",       'b00_00000_000000,'b0000,'bXXXX,'b0000,'b0,'bX,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'bX,'bxxxx,'b0000);
    tester("00: Load MSR <= USR",           'b00_00000_000000,'bZZZZ,'bXXXX,'bXXXX,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bZZZZ, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);
    tester("00: Verify CT=0",               'b00_00000_010000,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);
    tester("01: Load MSR <= 1111",          'b01_00000_000001,'bZZZZ,'b1111,'b0000,'b0,'bX,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b1,'b1,'b0000,'b1111);
    tester("02: Swap uSR<->MSR",            'b01_00000_000010,'bZZZZ,'b1111,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b0, 'b1111, 'bZZ,'bZZ, 'b1,'b0,'b1111,'b0000);
    tester("03: Load uSR <= 0000",          'b00_00000_000011,'bZZZZ,'b1111,'bXXXX,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("04: Load uSR <= I(1010)",       'b10_00000_000100,'bZZZZ,'b1010,'bXXXX,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b0, 'b1010, 'bZZ,'bZZ, 'b0,'b1,'b1010,'b0000);
    tester("05: Invert MSR",                'b10_00000_000101,'bZZZZ,'bXXXX,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1010, 'bZZ,'bZZ, 'b1,'b0,'b1010,'b1111);
     setup("06: Load MSR <= I(0110)",       'b00_00000_000110,'bZZZZ,'b0110,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b1010, 'bZZ,'bZZ, 'b0,'b0,'b1010,'b0110);
    tester("06: MSR Shift thru OVR",        'b10_00000_000110,'bZZZZ,'b1X0X,'b0101,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1010, 'bZZ,'bZZ, 'b1,'b0,'b1010,'b1100);
    tester("07: Load with OVR retain",      'b10_00000_000111,'bZZZZ,'b1X0X,'b0101,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1010, 'bZZ,'bZZ, 'b1,'b1,'b1010,'b1100);
     setup("06: Load uSR <= I(1111)",       'b00_00000_000110,'bZZZZ,'b1111,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'b1111, 'bZZ,'bZZ, 'b0,'b1,'b1111,'b1100);
    tester("10: Set Z=0",                   'b10_00000_001000,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0111, 'bZZ,'bZZ, 'b1,'b1,'b0111,'b1100);
    tester("11: Set Z=1",                   'b10_00000_001001,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1111, 'bZZ,'bZZ, 'b1,'b0,'b1111,'b1100);
    tester("12: Set C=0",                   'b10_00000_001010,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1011, 'bZZ,'bZZ, 'b1,'b0,'b1011,'b1100);
    tester("13: Set C=1",                   'b10_00000_001011,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1111, 'bZZ,'bZZ, 'b1,'b0,'b1111,'b1100);
    tester("14: Set N=0",                   'b10_00000_001100,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1101, 'bZZ,'bZZ, 'b1,'b1,'b1101,'b1100);
    tester("15: Set N=1",                   'b10_00000_001101,'bZZZZ,'bXXXX,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1111, 'bZZ,'bZZ, 'b1,'b0,'b1111,'b1100);
    tester("16: Set OVR=0",                 'b10_00000_001110,'bZZZZ,'bXX1X,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1110, 'bZZ,'bZZ, 'b1,'b1,'b1110,'b1100);
    tester("17: Set OVR=1",                 'b10_00000_001111,'bZZZZ,'bXX1X,'b1111,'b1,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1111, 'bZZ,'bZZ, 'b1,'b0,'b1111,'b1100);
    tester("20: Load uSR,MSR = I(0010)",    'b10_00000_010000,'bZZZZ,'b0010,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0010, 'bZZ,'bZZ, 'b1,'b1,'b0010,'b0010);
    tester("21: Load MSR = I(0101)",        'b10_00000_010001,'bZZZZ,'b0101,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0010, 'bZZ,'bZZ, 'b1,'b0,'b0010,'b0101);
    tester("30: Load uSR,MSR = I(0~010)",   'b10_00000_011000,'bZZZZ,'b0010,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0110, 'bZZ,'bZZ, 'b1,'b1,'b0110,'b0110);
    tester("31: Load MSR = I(0~101)",       'b10_00000_011001,'bZZZZ,'b0101,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0110, 'bZZ,'bZZ, 'b1,'b0,'b0110,'b0001);
    tester("2X,3X: Load uSR = I(0011)",     'b10_00000_01X01X,'bZZZZ,'b0011,'bXXXX,'b1,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b0011, 'bZZ,'bZZ, 'b1,'bZ,'b0011,'b0001);
    tester("2X,3X: Load MSR = I(1110)",     'b10_00000_01X1XX,'bZZZZ,'b1110,'b0000,'b0,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b0011, 'bZZ,'bZZ, 'b1,'bZ,'b0011,'b1110);
`HEADER("Test uSR, MSR load, Y <= MSR");
    tester("40: Load uSR,MSR = I(1010)",    'b10_00000_100000,'bZZZZ,'b1010,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b1010, 'bZZ,'bZZ, 'b1,'b1,'b1010,'b1010);
    tester("41: Load MSR = I(0111)",        'b10_00000_100001,'bZZZZ,'b0111,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b0, 'b0111, 'bZZ,'bZZ, 'b0,'b1,'b1010,'b0111);
    tester("50: Load uSR,MSR = I(1~010)",   'b10_00000_101000,'bZZZZ,'b1010,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b0, 'b1110, 'bZZ,'bZZ, 'b0,'b1,'b1110,'b1110);
    tester("51: Load MSR = I(0~111)",       'b10_00000_101001,'bZZZZ,'b0111,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0011, 'bZZ,'bZZ, 'b1,'b1,'b1110,'b0011);
    tester("4X,5X: Load MSR,uSR = I(1101)", 'b10_00000_10X01X,'bZZZZ,'b1101,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b1101, 'bZZ,'bZZ, 'b1,'bZ,'b1101,'b1101);
    tester("4X,5X: Load MSR = I(1001)",     'b10_00000_10X1XX,'bZZZZ,'b1001,'b0000,'b0,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b1001, 'bZZ,'bZZ, 'b1,'bZ,'b1101,'b1001);
    tester("6X: Load MSR,uSR = I(1000)",    'b10_00000_110XXX,'bZZZZ,'b1000,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b1000, 'bZZ,'bZZ, 'b1,'bZ,'b1000,'b1000);
    tester("6X: Load MSR = I(0111)",        'b10_00000_110XXX,'bZZZZ,'b0111,'b0000,'b0,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b0, 'b0111, 'bZZ,'bZZ, 'b0,'bZ,'b1000,'b0111);
`HEADER("Test uSR, MSR load, Y <= I");
    tester("70: Load MSR,uSR = I(0~000)",   'b10_00000_111000,'bZZZZ,'b0000,'b0000,'b0,'b0,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b1, 'b0000, 'bZZ,'bZZ, 'b1,'b1,'b0100,'b0100);
    tester("71: Load MSR = I(0~111)",       'b10_00000_111001,'bZZZZ,'b0111,'b0000,'b0,'b1,'b0,'b0, 'b1, 'bZZ,'bZZ, 'b0, 'b0111, 'bZZ,'bZZ, 'b0,'b1,'b0100,'b0011);
    tester("6X: Load MSR,uSR = I(1100)",    'b10_00000_111X1X,'bZZZZ,'b1100,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b1, 'b1100, 'bZZ,'bZZ, 'b1,'bZ,'b1100,'b1100);
    tester("6X: Load MSR = I(0100)",        'b10_00000_1111XX,'bZZZZ,'b0100,'b0000,'b0,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'b0, 'b0100, 'bZZ,'bZZ, 'b0,'bZ,'b1100,'b0100);
`HEADER("Test C0 <= uSR/MSR");
     setup("06: Load MSR,uSR = I(0000)",    'b00_00000_000110,'bZZZZ,'b0000,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...0x100x: Test C <= ~uC",    'b11_00000_0X100X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b1,'bZ,'b0000,'b0000);
    tester("11...0x0xxx: Test C <= uC",     'b11_00000_0X0XXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...0xx1xx: Test C <= uC",     'b11_00000_0XX1XX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...0xxx1x: Test C <= uC",     'b11_00000_0XXX1X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...1x100x: Test C <= ~MC",    'b11_00000_1X100X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b1,'bZ,'b0000,'b0000);
    tester("11...1x0xxx: Test C <= MC",     'b11_00000_1X0XXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...1xx1xx: Test C <= MC",     'b11_00000_1XX1XX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("11...1xxx1x: Test C <= MC",     'b11_00000_1XXX1X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
     setup("06: Load MSR,uSR = I(0100)",    'b00_00000_000110,'bZZZZ,'b0100,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0100, 'bZZ,'bZZ, 'b0,'bZ,'b0100,'b0100);
    tester("11...0x100x: Test C <= ~uC",    'b11_00000_0X100X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0100, 'bZZ,'bZZ, 'b0,'bZ,'b0100,'b0100);
    tester("11...0x0xxx: Test C <= uC",     'b11_00000_0X0XXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
    tester("11...0xx1xx: Test C <= uC",     'b11_00000_0XX1XX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0100, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
    tester("11...0xxx1x: Test C <= uC",     'b11_00000_0XXX1X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0100, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
    tester("11...1x100x: Test C <= ~MC",    'b11_00000_1X100X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'bZ,'b0100,'b0100);
    tester("11...1x0xxx: Test C <= MC",     'b11_00000_1X0XXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
    tester("11...1xx1xx: Test C <= MC",     'b11_00000_1XX1XX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
    tester("11...1xxx1x: Test C <= MC",     'b11_00000_1XXX1X,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b1,'bZ,'b0100,'b0100);
`HEADER("Test CT");
     setup("06: Load MSR = I(0000)",        'b00_00000_000110,'bZZZZ,'b0000,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0000, 'bZZ,'bZZ, 'b0,'bZ,'b0000,'b0000);
    tester("16: Test IN ^ MN",              'b00_00000_001110,'bZZZZ,'bXX1X,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("17: Test IN ~^ MN",             'b00_00000_001111,'bZZZZ,'bXX0X,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("60: Test (N ^ O) | Z",          'b00_00000_110000,'bZZZZ,'b0X10,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("61: Test (N ~^ O) & ~Z",        'b00_00000_110001,'bZZZZ,'b0X11,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("62: Test N ^ O",                'b00_00000_110010,'bZZZZ,'bXX10,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("63: Test N ~^ O",               'b00_00000_110011,'bZZZZ,'bXX11,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("64: Test Z",                    'b00_00000_110100,'bZZZZ,'b1XXX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("65: Test ~Z",                   'b00_00000_110101,'bZZZZ,'b1XXX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);
    tester("66: Test O",                    'b00_00000_110110,'bZZZZ,'bXXX1,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("67: Test ~O",                   'b00_00000_110111,'bZZZZ,'bXXX1,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);
    tester("70: Test ~C | Z",               'b00_00000_111000,'bZZZZ,'b00XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("71: Test C & ~Z",               'b00_00000_111001,'bZZZZ,'b01XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("72: Test C",                    'b00_00000_111010,'bZZZZ,'bX1XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("73: Test ~C",                   'b00_00000_111011,'bZZZZ,'bX1XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);
    tester("74: Test ~C | Z",               'b00_00000_111100,'bZZZZ,'b11XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("75: Test C & ~Z",               'b00_00000_111101,'bZZZZ,'b01XX,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("76: Test N",                    'b00_00000_111110,'bZZZZ,'bXX1X,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b1,'b0000,'b0000);
    tester("77: Test ~N",                   'b00_00000_111111,'bZZZZ,'bXX1X,'bXXXX,'b1,'b1,'b1,'b0, 'b1, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZZ,'bZZ, 'b0,'b0,'b0000,'b0000);

`HEADER("Test Right Shift functions");
     setup("06: Load MSR,uSR = I(0110)",      'b00_00000_000110,'bZZZZ,'b0110,'b0000,'b0,'b0,'b0,'b1, 'b1, 'bZZ,'bZZ, 'bX, 'b0110, 'bZZ,'bZZ, 'b0,'bZ,'b0110,'b0110);
    tester("00xx: 0->RAM, 0->Q",              'b00_00000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'bZZ, 'bX, 'bzzzz, 'b0Z,'b0Z, 'b0,'bZ,'b0110,'b0110);
    tester("01xx: 1->RAM, 1->Q",              'b00_00001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'bZZ, 'bX, 'bzzzz, 'b1Z,'b1Z, 'b0,'bZ,'b0110,'b0110);
    tester("02xx: 0->RAM->0->C, N->Q",        'b00_00010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b00,'b1Z, 'b0,'bZ,'b0110,'b0010);
    tester("03xx: 1->RAM->0->Q",              'b00_00011_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b10,'b0Z, 'b0,'bZ,'b0110,'b0010);
    tester("03xx: 1->RAM->1->Q",              'b00_00011_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b11,'b1Z, 'b0,'bZ,'b0110,'b0010);
    tester("04xx: C->RAM->0->Q",              'b00_00100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b00,'b0Z, 'b0,'bZ,'b0110,'b0010);
    tester("04xx: C->RAM->1->Q",              'b00_00100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b01,'b1Z, 'b0,'bZ,'b0110,'b0010);
    tester("05xx: N->RAM->0->Q",              'b00_00101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b10,'b0Z, 'b0,'bZ,'b0110,'b0010);
    tester("05xx: N->RAM->1->Q",              'b00_00101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b11,'b1Z, 'b0,'bZ,'b0110,'b0010);
    tester("06xx: 0->RAM->0->Q",              'b00_00110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b00,'b0Z, 'b0,'bZ,'b0110,'b0010);
    tester("06xx: 0->RAM->1->Q",              'b00_00110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b01,'b1Z, 'b0,'bZ,'b0110,'b0010);
    tester("07xx: 0->RAM->0->Q->0->C",        'b00_00111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ0, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("07xx: 0->RAM->1->Q->1->C",        'b00_00111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ1, 'bX, 'bzzzz, 'b01,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("10xx: RR(RAM->0)->C, RR(Q->1)",   'b00_01000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ1, 'bX, 'bzzzz, 'b00,'b11, 'b0,'bZ,'b0110,'b0010);
    tester("10xx: RR(RAM->1)->C, RR(Q->0)",   'b00_01000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ0, 'bX, 'bzzzz, 'b11,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("11xx: RRC(RAM->0), RR(Q->0)",     'b00_01001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ0, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("11xx: RRC(RAM->1), RR(Q->1)",     'b00_01001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ1, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("12xx: RR(RAM->0), RR(Q->0)",      'b00_01010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ0, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("12xx: RR(RAM->1), RR(Q->0)",      'b00_01010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ0, 'bX, 'bzzzz, 'b11,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("13xx: 1=IC->RAM->0->Q",           'b00_01011_XXXXXX,'bZZZZ,'bX1XX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b10,'b0Z, 'b0,'bZ,'b0110,'b0110);
    tester("13xx: 0=IC->RAM->1->Q",           'b00_01011_XXXXXX,'bZZZZ,'bX0XX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b01,'b1Z, 'b0,'bZ,'b0110,'b0110);
    tester("14xx: RRC(RAM->0->Q->0)",         'b00_01100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ0, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("14xx: RRC(RAM->0->Q->1)",         'b00_01100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ1, 'bX, 'bzzzz, 'b10,'b01, 'b0,'bZ,'b0110,'b0110);
    tester("15xx: 0=Q0->RRC(RAM->1->Q->1)",   'b00_01101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ0, 'bX, 'bzzzz, 'b01,'b10, 'b0,'bZ,'b0110,'b0010);
    tester("15xx: 1=Q0->RRC(RAM->1->Q->0)",   'b00_01101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ1, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("16xx: N^O->RAM->0->Q",            'b00_01110_XXXXXX,'bZZZZ,'bXX11,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZZ, 'bX, 'bzzzz, 'b00,'b0Z, 'b0,'bZ,'b0110,'b0110);
    tester("16xx: N^O->RAM->1->Q",            'b00_01110_XXXXXX,'bZZZZ,'bXX10,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZZ, 'bX, 'bzzzz, 'b11,'b1Z, 'b0,'bZ,'b0110,'b0110);
    tester("17xx: RR(RAM->1->Q->0)",          'b00_01111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ1,'bZ0, 'bX, 'bzzzz, 'b01,'b10, 'b0,'bZ,'b0110,'b0110);
    tester("17xx: RR(RAM->0->Q->1)",          'b00_01111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZ0,'bZ1, 'bX, 'bzzzz, 'b10,'b01, 'b0,'bZ,'b0110,'b0110);

`HEADER("Test Left Shift functions");
//          -------------descr--------------- --------i-------- y_zcno i_zcno e_zcno cem ceu oey oect -se  -sio -qio  -cx  xyzcno  xsio xqio  xc0 xct x_usr- x_msr-
    tester("20xx: C<-0<-RAM<-0, Q<-0",        'b00_10000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'bZZ, 'bX, 'bzzzz, 'b00,'bZ0, 'b0,'bZ,'b0110,'b0010);
    tester("21xx: C<-1<-RAM<-1, Q<-1",        'b00_10001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'bZZ, 'bX, 'bzzzz, 'b11,'bZ1, 'b0,'bZ,'b0110,'b0110);
    tester("22xx: RAM<-0, Q<-0",              'b00_10010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZ0,'bZ0, 'b0,'bZ,'b0110,'b0110);
    tester("23xx: RAM<-1, Q<-1",              'b00_10011_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZ1,'bZ1, 'b0,'bZ,'b0110,'b0110);
    tester("24xx: C<-0<-RAM<-0<-Q<-0",        'b00_10100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b0Z, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("24xx: C<-0<-RAM<-1<-Q<-0",        'b00_10100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b1Z, 'bX, 'bzzzz, 'b01,'b10, 'b0,'bZ,'b0110,'b0010);
    tester("25xx: C<-1<-RAM<-0<-Q<-1",        'b00_10101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b0Z, 'bX, 'bzzzz, 'b10,'b01, 'b0,'bZ,'b0110,'b0110);
    tester("25xx: C<-1<-RAM<-1<-Q<-1",        'b00_10101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b1Z, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("26xx: RAM<-1<-Q<-0",              'b00_10110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b1Z, 'bX, 'bzzzz, 'bZ1,'b10, 'b0,'bZ,'b0110,'b0110);
    tester("26xx: RAM<-0<-Q<-0",              'b00_10110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b0Z, 'bX, 'bzzzz, 'bZ0,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("27xx: RAM<-0<-Q<-1",              'b00_10111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b0Z, 'bX, 'bzzzz, 'bZ0,'b01, 'b0,'bZ,'b0110,'b0110);
    tester("27xx: RAM<-1<-0<-1",              'b00_10111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b1Z, 'bX, 'bzzzz, 'bZ1,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("30xx: C<-RL(0<-RAM),RL(1<-Q)",    'b00_11000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b1Z, 'bX, 'bzzzz, 'b00,'b11, 'b0,'bZ,'b0110,'b0010);
    tester("30xx: C<-RL(1<-RAM),RL(0<-Q)",    'b00_11000_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b0Z, 'bX, 'bzzzz, 'b11,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("31xx: RLC(0<-RAM),RL(0<-Q)",      'b00_11001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b0Z, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("31xx: RLC(1<-RAM),RL(1<-Q)",      'b00_11001_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b1Z, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("32xx: RL(0<-RAM), RL(1<-Q)",      'b00_11010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b1Z, 'bX, 'bzzzz, 'b00,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("32xx: RL(1<-RAM), RL(0<-Q)",      'b00_11010_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b0Z, 'bX, 'bzzzz, 'b11,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("33xx: RAM<-C, Q<-0",              'b00_11011_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'bZZ, 'bX, 'bzzzz, 'bZ1,'bZ0, 'b0,'bZ,'b0110,'b0110);
    tester("34xx: RLC(0<-RAM<-0<-Q)",         'b00_11100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b0Z, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0010);
    tester("34xx: RLC(1<-RAM<-1<-Q)",         'b00_11100_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b1Z, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("35xx: C<-RL(0<-RAM<-1<-Q)",       'b00_11101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b1Z, 'bX, 'bzzzz, 'b01,'b10, 'b0,'bZ,'b0110,'b0010);
    tester("35xx: C<-RL(1<-RAM<-0<-Q)",       'b00_11101_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b0Z, 'bX, 'bzzzz, 'b10,'b01, 'b0,'bZ,'b0110,'b0110);
    tester("36xx: RAM<-0<-Q<-C",              'b00_11110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b0Z, 'bX, 'bzzzz, 'bZ0,'b01, 'b0,'bZ,'b0110,'b0110);
    tester("36xx: RAM<-1<-Q<-C",              'b00_11110_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'bZZ,'b1Z, 'bX, 'bzzzz, 'bZ1,'b11, 'b0,'bZ,'b0110,'b0110);
    tester("37xx: RL(0<-RAM<-0<-Q)",          'b00_11111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b0Z,'b0Z, 'bX, 'bzzzz, 'b00,'b00, 'b0,'bZ,'b0110,'b0110);
    tester("37xx: RL(1<-RAM<-1<-Q)",          'b00_11111_XXXXXX,'bZZZZ,'bXXXX,'bXXXX,'b1,'b1,'b1,'b1, 'b0, 'b1Z,'b1Z, 'bX, 'bzzzz, 'b11,'b11, 'b0,'bZ,'b0110,'b0110);

end
endmodule
