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

// am2903 testbench 4 bit size
`include "am2903.v"

module am2903_testbench;

// drivers
reg [3:0] a, b;
reg [8:0] i;
reg [3:0] da;
reg [3:0] dbo;
reg oey_, we_, cp, cn, oeb_, ea_;
reg  qio0o, qio3o, sio0o, sio3o;
reg ien_,lss_, zo, wrmsso;
reg [4:0] yo;


wire qio0,  qio3,  sio0,  sio3; // real I/O pins
wire z, wrmss;
wire [3:0] db, y;
wire gn, povr, cn4;

am2903 dut(
        .a        (a),
        .b        (b),
        .i        (i),
        .da     (da),
        .db     (db),
        .oey_    (oey_),
        .we_    (we_),
        .cp        (cp),
        .cn        (cn),
        .oeb_    (oeb_),
        .ea_    (ea_),
        .ien_    (ien_),
        .lss_    (lss_),

        .qio0    (qio0),
        .qio3     (qio3), 
        .sio0    (sio0), 
        .sio3    (sio3),
        .z      (z),
        .wrmss_ (wrmss),

        .y        (y), 
        .povr    (povr), 
        .gn        (gn), 
        .cn4    (cn4)
);

assign qio0  = qio0o;
assign qio3  = qio3o;
assign sio0  = sio0o;
assign sio3  = sio3o;
assign db    = dbo;
assign y     = yo;
assign z     = zo;
assign wrmss = wrmsso;


`define HEADER(d) $display("Test %s",d); $display("-----: ----i---- -a-- -b-- -da- -dbi -yi- oey we cn oeb ea ien lss s0 s3 q0 q3 zi mss cp | -y-- -db- po gn c4 s0 s3 q0 q3 wr | Description");
`define show(descr,i,a,b,da,dbv,yv,oy,we,cn,ob,ea,ie,ls,s0v,s3v,q0v,q3v,zv,wrv,cp, y,db,po,gn,c4,s0,s3,q0,q3,wrm) \
$display("%5g: %9b %4b %4b %4b %4b %4b  %b  %b  %b   %b  %b   %b   %b  %b  %b  %b  %b  %b   %b  %s  | %4b %4b %b  %b  %b  %b  %b  %b  %b  %b  | %0s", \
        $time,i,a,b,da,dbv,yv,oy,we,cn,ob,ea,ie,ls,s0v,s3v,q0v,q3v,zv,wrv,cp, y,db,po,gn,c4,s0,s3,q0,q3,wrm,descr)
`define assert(signame, signal, value) \
        if (signal !== value) begin \
            $display("Error: %s should be %b, but is %b", signame, signal, value); \
        end

task setup;
    input [80*8-1:0] descr;
    input [3:0] av, bv;
    input [8:0] iv;
    input [3:0] dav, dbv, yv;
    input oyv, wev, cnv, obv, ev, iev, lsv;
    input s0v, s3v, q0v, q3v;
    input zv, wrv;
    
    input [3:0] exy, exdb;
    input exp, exg, exc4, exz, exwr, exs0, exs3, exq0, exq3;
    input [3:0] exqreg;
       
    begin
        a <= av; b <= bv; i <= iv;
        da <= dav; dbo <= dbv; yo <= yv;
        oey_ <= oyv; we_ <= wev; cn <= cnv; oeb_ <= obv; ea_ <= ev; ien_ <= iev; lss_ <= lsv;
        qio0o <= q0v; qio3o <= q3v; sio0o <= s0v; sio3o <= s3v;
        zo <= zv; wrmsso <= wrv;

        cp <= 0;
        #1 cp <= 1;
        #1 cp <= 0;
        #1 `show(descr,i,a,b,da,db,yv,oey_,we_,cn,oeb_,ea_,ien_,lss_,s0v,s3v,q0v,q3v,zv,wrv,"^", y,db,povr,gn,cn4,sio0,sio3,qio0,qio3,wrmss);        
        `assert("y", exy, y);
        `assert("db", exdb, db);
        `assert("cn4", exc4, cn4);
        `assert("g_/n", exg, gn);
        `assert("p_/ovr", exp, povr);
        `assert("z", exz, z);
        `assert("wr/mss", exwr, wrmss);
        `assert("sio0", exs0, sio0);
        `assert("sio3", exs3, sio3);
        `assert("qio0", exq0, qio0);
        `assert("qio3", exq3, qio3);
        `assert("qreg", exqreg, dut.qreg);
    end
endtask

task tester;
    input [80*8-1:0] descr;
    input [3:0] av, bv;
    input [8:0] iv;
    input [3:0] dav, dbv, yv;
    input oyv, wev, cnv, obv, ev, iev, lsv;
    input s0v, s3v, q0v, q3v;
    input zv, wrv;
    
    input [3:0] exy, exdb;
    input exp, exg, exc4, exz, exwr, exs0, exs3, exq0, exq3;
    input [3:0] exqreg;
       
    begin
        a <= av; b <= bv; i <= iv;
        da <= dav; dbo <= dbv; yo <= yv;
        oey_ <= oyv; we_ <= wev; cn <= cnv; oeb_ <= obv; ea_ <= ev; ien_ <= iev; lss_ <= lsv;
        qio0o <= q0v; qio3o <= q3v; sio0o <= s0v; sio3o <= s3v;
        zo <= zv; wrmsso <= wrv;

        cp <= 0;
//        #1 `show("",   i,a,b,da,db,yv,oey_,we_,cn,oeb_,ea_,ien_,lss_,s0v,s3v,q0v,q3v,zv,wrv," ", y,db,povr,gn,cn4,sio0,sio3,qio0,qio3,wrmss);
        #1 cp <= 1;
//        #1 `show(descr,i,a,b,da,db,yv,oey_,we_,cn,oeb_,ea_,ien_,lss_,s0v,s3v,q0v,q3v,zv,wrv," ", y,db,povr,gn,cn4,sio0,sio3,qio0,qio3,wrmss);
        #1 cp <= 0;
        #1 `show(descr,i,a,b,da,db,yv,oey_,we_,cn,oeb_,ea_,ien_,lss_,s0v,s3v,q0v,q3v,zv,wrv,"^", y,db,povr,gn,cn4,sio0,sio3,qio0,qio3,wrmss);        
//        $display("");
        `assert("y", exy, y);
        `assert("db", exdb, db);
        `assert("cn4", exc4, cn4);
        `assert("g_/n", exg, gn);
        `assert("p_/ovr", exp, povr);
        `assert("z", exz, z);
        `assert("wr/mss", exwr, wrmss);
        `assert("sio0", exs0, sio0);
        `assert("sio3", exs3, sio3);
        `assert("qio0", exq0, qio0);
        `assert("qio3", exq3, qio3);
        `assert("qreg", exqreg, dut.qreg);
    end
endtask

initial begin

    //Dump results of the simulation to am2903.vcd
    $dumpfile("am2903.vcd");
    $dumpvars;

    `HEADER("Output Enable");
    tester("OEY disable",                 'bXXXX,'bXXXX,'bXXXXXXXXX,'bXXXX,'bXXXX,'bZZZZ,'b1,'bX,'bX,'bX,'bX,'bX,'bX,'bX,'bX,'bX,'bX,'bX,'bX,  'bZZZZ,'bXXXX,'b1,'b1,'b0,'bX,'bX,'bX,'bX,'bX,'bX,'bXXXX);

// setup RAM fill cell with addr
    `HEADER("RAM prefill (quiet)");
     setup("RAM[0] = 0",                  'bXXXX,'b0000,'b110011110,'b0000,'b0000,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0000,'b0000,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[1] = 1",                  'bXXXX,'b0001,'b110011110,'b0001,'b0001,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0001,'b0001,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[2] = 2",                  'bXXXX,'b0010,'b110011110,'b0010,'b0000,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0010,'b0000,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[3] = 3",                  'bXXXX,'b0011,'b110011110,'b0010,'b0001,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0011,'b0001,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[4] = 4",                  'bXXXX,'b0100,'b110011110,'b0000,'b0100,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0100,'b0100,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[5] = 5",                  'bXXXX,'b0101,'b110011110,'b0100,'b0001,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0101,'b0001,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[6] = 6",                  'bXXXX,'b0110,'b110011110,'b0100,'b0010,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0110,'b0010,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[7] = 7",                  'bXXXX,'b0111,'b110011110,'b0101,'b0010,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0111,'b0010,'bX,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[8] = 8",                  'bXXXX,'b1000,'b110010110,'b1100,'b0100,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1000,'b0100,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[9] = 9",                  'bXXXX,'b1001,'b110010110,'b1111,'b0110,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1001,'b0110,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[10] = 10",                'bXXXX,'b1010,'b110010110,'b0101,'b1111,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1010,'b1111,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[11] = 11",                'bXXXX,'b1011,'b110010110,'b0101,'b1110,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1011,'b1110,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[12] = 12",                'bXXXX,'b1100,'b110010110,'b0001,'b1101,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1100,'b1101,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[13] = 13",                'bXXXX,'b1101,'b110010110,'b0101,'b1000,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1101,'b1000,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[14] = 14",                'bXXXX,'b1110,'b110010110,'b1101,'b0011,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1110,'b0011,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
     setup("RAM[15] = 15",                'bXXXX,'b1111,'b110010110,'b0101,'b1010,'bZZZZ,'b0,'b0,'bX,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1111,'b1010,'bX,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    `HEADER("RAM read");
    tester("YBUS Read RAM[1] via rmux",   'b0001,'bXXXX,'b110011110,'bXXXX,'b0000,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0001,'b0000,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("Read RAM[2] via smux",        'bXXXX,'b0010,'b110001000,'b0000,'bXXXX,'bZZZZ,'b0,'b1,'b0,'b0,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0010,'bXXXX,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("Read RAM[4] via rmux,smux",   'b0100,'b0100,'b110011000,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'bX,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0100,'bXXXX,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("Read RAM[8] via rmux,smux",   'b1000,'b1000,'b110011110,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'bX,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1000,'bXXXX,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
//         ------------------------------ --a--- --b--- --i-------- --da-- --db-- --y--- oey -we -cn oeb -ea ien lss -s0 -s3 -q0 -q3 -z- -wm | --y--- --db-- -po -gn -c4 -z- -wm -s0 -s3 -q0 -q3 -qreg-
    `HEADER("Y as input");
    tester("Write RAM[15]=10 via y",      'bXXXX,'b1111,'b110011110,'bXXXX,'bXXXX,'b1010,'b1,'b0,'bX,'b0,'b0,'b0,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1010,'bXXXX,'bX,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("Read RAM[15] via rmux",       'b1111,'bXXXX,'b110011110,'bXXXX,'b0000,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1010,'b0000,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    `HEADER("basic ALU ops");
    tester("ALU HIGH",                    'bXXXX,'bXXXX,'b110000001,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'bX,'bX,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1111,'bXXXX,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU 7 - 3 - 1 + Cn",          'bXXXX,'bXXXX,'b110000010,'b0011,'b0111,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0100,'b0111,'b0,'b0,'b1,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R5 - 9 - 1 + Cn",         'b0101,'bXXXX,'b110000100,'bXXXX,'b1001,'bZZZZ,'b0,'b1,'b1,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1100,'b1001,'b1,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R6 + 9 + Cn",             'b0110,'bXXXX,'b110000110,'bXXXX,'b1001,'bZZZZ,'b0,'b1,'b0,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1111,'b1001,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU 10 + Cn",                 'bXXXX,'bXXXX,'b110001000,'bXXXX,'b1010,'bZZZZ,'b0,'b1,'b1,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1011,'b1010,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU ~10 + Cn",                'bXXXX,'bXXXX,'b110001010,'bXXXX,'b1010,'bZZZZ,'b0,'b1,'b0,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0101,'b1010,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R5 + Cn",                 'b0101,'bXXXX,'b110001101,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'b0,'bX,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0101,'bXXXX,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU ~R5 + Cn",                'b0101,'bXXXX,'b110001111,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'b1,'bX,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1011,'bXXXX,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU LOW",                     'bXXXX,'bXXXX,'b110010001,'bXXXX,'bXXXX,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0000,'bXXXX,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU ~R5 & R7",                'b0101,'b0111,'b110010010,'bXXXX,'bZZZZ,'bZZZZ,'b0,'b1,'bX,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0010,'b0111,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R6 ~^ 7",                 'b0110,'bXXXX,'b110010100,'bXXXX,'b0111,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1110,'b0111,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R14 ^ R4",                'b1110,'b0100,'b110010110,'bXXXX,'b0100,'bZZZZ,'b0,'b1,'bX,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1010,'b0100,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R9 & 1",                  'b1001,'bXXXX,'b110011000,'bXXXX,'b0001,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0001,'b0001,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU 12 ~| R10",               'bXXXX,'b1010,'b110011010,'b1100,'bZZZZ,'bZZZZ,'b0,'b1,'bX,'b0,'b1,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0001,'b1010,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R10 ~| 13",               'b1010,'b1111,'b110011100,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b0111,'b1101,'bX,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    tester("ALU R1 | R11",                'b0001,'b1011,'b110011110,'bXXXX,'bZZZZ,'bZZZZ,'b0,'b1,'bX,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'bX,'b0,  'b1011,'b1011,'b0,'b1,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'bXXXX);
    `HEADER("Shifter operations");
     setup("LOADQ = 1100",                'bXXXX,'bXXXX,'b011011110,'b0000,'b1100,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b1100,'b1100,'b0,'b1,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMDA, MSS, F3=L",            'bXXXX,'bXXXX,'b000011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b1100);
    tester("RAMDA, MSS, F3=H",            'bXXXX,'bXXXX,'b000011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b1010,'b1101,'b0,'b1,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b1100);
    tester("RAMDA, LSS, SIO3=L",          'bXXXX,'bXXXX,'b000011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bX,'bX,'bX,'bZ,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b1100);
    tester("RAMDA, LSS, SIO3=H",          'bXXXX,'bXXXX,'b000011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bX,'bX,'bX,'bZ,  'b1110,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bX,'bX,'b1100);
    tester("RAMDL, xSS, SIO3=L",          'bXXXX,'bXXXX,'b000111110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b1100);
    tester("RAMDL, xSS, SIO3=H",          'bXXXX,'bXXXX,'b000111110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bX,'bX,'bX,'bZ,  'b1010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bX,'bX,'b1100);
     setup("LOADQ = 1100",                'bXXXX,'bXXXX,'b011011110,'b0000,'b1100,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b1100,'b1100,'b0,'b1,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMDQA, MSS, F3=L, QIO3=H",   'bXXXX,'bXXXX,'b001011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b1,'bX,'b0,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'b0,'b1,'b1110);
    tester("RAMDQA, MSS, F3=H, QIO3=L",   'bXXXX,'bXXXX,'b001011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'bX,'b0,  'b1010,'b1101,'b0,'b1,'b0,'bX,'b0,'b1,'b0,'b1,'b0,'b0111);
    tester("RAMDQA, LSS, SIO3=L, QIO3=L", 'bXXXX,'bXXXX,'b001011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bX,'bZ,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'b1,'b0,'b0011);
    tester("RAMDQA, LSS, SIO3=H, QIO3=H", 'bXXXX,'bXXXX,'b001011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b1,'bX,'bZ,  'b1110,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'b1,'b1,'b1001);
    tester("RAMDQL, xSS, SIO3=L, QIO3=H", 'bXXXX,'bXXXX,'b001111110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b1,'bX,'bZ,  'b0010,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'b0,'b1,'b1100);
    tester("RAMDQL, xSS, SIO3=H, QIO3=L", 'bXXXX,'bXXXX,'b001111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'bX,'bZ,  'b1110,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'b0,'b0,'b0110);
    tester("RAM, xSS, SIO3=H, parity",    'bXXXX,'bXXXX,'b010011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bX,'bX,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b0,'b0,'b1,'bX,'bX,'b0110);
    tester("RAM, xSS, SIO3=L, parity",    'bXXXX,'bXXXX,'b010011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bX,'bX,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0110);
    tester("QD, xSS, QIO3=L",             'bXXXX,'bXXXX,'b010111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b1,'b0,'b1,'b1,'b0,'b0011);
    tester("QD, xSS, QIO3=H",             'bXXXX,'bXXXX,'b010111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b1,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b1,'b1,'b0,'b1,'b1,'b1001);
    tester("LOADQ = 1100, LSS, WR->1",    'bXXXX,'bXXXX,'b011011110,'b0000,'b1100,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bX,'bX,'bX,'bZ,  'b1100,'b1100,'b0,'b0,'b0,'bX,'b1,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMQ = 1100, LSS, WR->0",     'bXXXX,'bXXXX,'b011111110,'b0000,'b1100,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'b0,'bX,'bX,'bX,'bZ,  'b1100,'b1100,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMUPA, MSS, F3=L, SIO0=H",   'bXXXX,'bXXXX,'b100011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'b1,'bZ,'bX,'bX,'bX,'b0,  'b0011,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bX,'bX,'b1100);
    tester("RAMUPA, MSS, F3=H, SIO0=L",   'bXXXX,'bXXXX,'b100011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'b0,'bZ,'bX,'bX,'bX,'b0,  'b1010,'b1101,'b0,'b1,'b0,'bX,'b0,'b0,'b1,'bX,'bX,'b1100);
    tester("RAMUPA, LSS, SIO0=L",         'bXXXX,'bXXXX,'b100011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b0,'bZ,'bX,'bX,'bX,'bZ,  'b1010,'b0101,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMUPA, LSS, SIO0=H",         'bXXXX,'bXXXX,'b100011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b1,'bZ,'bX,'bX,'bX,'bZ,  'b1011,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bX,'bX,'b1100);
    tester("RAMUPL, xSS, SIO0=L",         'bXXXX,'bXXXX,'b100111110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b0,'bZ,'bX,'bX,'bX,'bZ,  'b1010,'b0101,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b1100);
    tester("RAMUPL, xSS, SIO0=H",         'bXXXX,'bXXXX,'b100111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b1,'bZ,'bX,'bX,'bX,'bZ,  'b1011,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bX,'bX,'b1100);
    tester("RAMQUPA, MSS, QIO0=H",        'bXXXX,'bXXXX,'b101011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'b1,'bZ,'b1,'bZ,'bX,'b0,  'b0011,'b0101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'b1,'b1,'b1001);
    tester("RAMQUPA, MSS, QIO0=L",        'bXXXX,'bXXXX,'b101011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'b0,'bZ,'b0,'bZ,'bX,'b0,  'b1010,'b1101,'b0,'b1,'b0,'bX,'b0,'b0,'b1,'b0,'b0,'b0010);
    tester("RAMQUPA, LSS, QIO0=L",        'bXXXX,'bXXXX,'b101011110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b0,'bZ,'b0,'bZ,'bX,'bZ,  'b1010,'b0101,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'b0,'b0,'b0100);
    tester("RAMQUPA, LSS, QIO0=H",        'bXXXX,'bXXXX,'b101011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b1,'bZ,'b1,'bZ,'bX,'bZ,  'b1011,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'b1,'b1,'b1001);
    tester("RAMQUPL, xSS, QIO0=L",        'bXXXX,'bXXXX,'b101111110,'b0000,'b0101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'b0,'bZ,'b0,'bZ,'bX,'b1,  'b1010,'b0101,'b0,'b0,'b0,'bX,'b1,'b0,'b0,'b0,'b0,'b0010);
    tester("RAMQUPL, xSS, QIO0=H",        'bXXXX,'bXXXX,'b101111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b1,'bZ,'b1,'bZ,'bX,'bZ,  'b1011,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'b1,'b0,'b0101);
    tester("YBUS, WR->1",                 'bXXXX,'bXXXX,'b110011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bX,'bX,'bX,'bX,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b1,'bX,'bX,'bX,'bX,'b0101);
    tester("QUP, xSS, QIO0=L",            'bXXXX,'bXXXX,'b110111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'bZ,'b0,'bZ,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b1,'bZ,'b1,'b0,'b1,'b1010);
    tester("QUP, xSS, QIO0=H",            'bXXXX,'bXXXX,'b110111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bZ,'bZ,'b1,'bZ,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b1,'bZ,'b1,'b1,'b0,'b0101);
    tester("SIGNEXT, xSS, SIO0=L",        'bXXXX,'bXXXX,'b111011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b0,'bZ,'bZ,'bZ,'bX,'bZ,  'b0000,'b1101,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bZ,'bZ,'b0101);
    tester("SIGNEXT, xSS, SIO0=H",        'bXXXX,'bXXXX,'b111011110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'b1,'bZ,'bZ,'bZ,'bX,'bZ,  'b1111,'b1101,'b0,'b0,'b0,'bX,'b0,'b1,'b1,'bZ,'bZ,'b0101);
    tester("RAMEXT, WR->0",               'bXXXX,'bXXXX,'b111111110,'b0000,'b1101,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b0,'bX,'bX,'bX,'bX,'bX,'bZ,  'b1101,'b1101,'b0,'b0,'b0,'bX,'b0,'bX,'bX,'bX,'bX,'b0101);
    `HEADER("MULT, TWOMULT");
     setup("LOADQ = 0010",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0010,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0010,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0010);
    tester("MULT LSS, Z=Q(H), CN=L",      'bXXXX,'bXXXX,'b000000000,'b0010,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bZ,'bZ,  'b0011,'b0101,'b1,'b1,'b0,'b1,'b0,'b1,'b0,'b1,'b0,'b0001);
    tester("MULT LSS, Z=Q(L), CN=L",      'bXXXX,'bXXXX,'b000000000,'b0010,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bZ,'bZ,  'b0010,'b0101,'b1,'b1,'b0,'b0,'b0,'b1,'b0,'b0,'b0,'b0000);
    tester("MULT LSS, Z=Q(L), CN=H",      'bXXXX,'bXXXX,'b000000000,'b0010,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'bZ,'bZ,  'b1011,'b0101,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b0,'b0000);
    tester("MULT LSS, Z=Q(L), CN=H",      'bXXXX,'bXXXX,'b000000000,'b0010,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'bZ,'bZ,  'b1011,'b0101,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b0,'b0000);
    tester("MULT MSS, Z=L, CN=L",         'bXXXX,'bXXXX,'b000000000,'b0010,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'b0,'b0,  'b0010,'b0101,'b0,'b0,'b0,'b0,'b0,'b1,'b0,'b0,'b0,'b0000);
//         ------------------------------ --a--- --b--- --i-------- --da-- --db-- --y--- oey -we -cn oeb -ea ien lss -s0 -s3 -q0 -q3 -z- -wm | --y--- --db-- -po -gn -c4 -z- -wm -s0 -s3 -q0 -q3 -qreg-
     setup("LOADQ = 1000",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0010,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0010,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0010);
    tester("TWOMULT LSS, Z=L, CN=L",      'bXXXX,'bXXXX,'b001000000,'b1110,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bZ,'bZ,  'b0001,'b0101,'b0,'b0,'b1,'b1,'b0,'b1,'b0,'b1,'b0,'b0001);
    tester("TWOMULT MSS, Z=L, CN=L",      'bXXXX,'bXXXX,'b001000000,'b1110,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'b0,'b0,  'b0010,'b0101,'b0,'b0,'b0,'b0,'b0,'b1,'b0,'b0,'b0,'b0000);
    tester("TWOMULT MSS, Z=H, CN=H",      'bXXXX,'bXXXX,'b001000000,'b1110,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'b1,'b0,  'b0010,'b0101,'b0,'b0,'b1,'b1,'b0,'b0,'b0,'b0,'b0,'b0000);
    tester("TWOMULT MSS, Z=L, CN=H",      'bXXXX,'bXXXX,'b001000000,'b1110,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'bZ,'bZ,'b0,'b0,'b0,  'b0011,'b0101,'b0,'b0,'b0,'b0,'b0,'b0,'bZ,'b0,'b0,'b0000);
    tester("TWOMULT MSS, Z=H, CN=L",      'bXXXX,'bXXXX,'b001000000,'b1110,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'bZ,'bZ,'b0,'b1,'b0,  'b0001,'b0101,'b0,'b0,'b1,'b1,'b0,'b1,'bZ,'b0,'b0,'b0000);
    `HEADER("INCRMNT");
    tester("INCRMNT by 1, LSS evn parity",'bXXXX,'bXXXX,'b010000000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bZ,'bZ,  'b0110,'b0101,'b1,'b1,'b0,'b0,'b0,'b0,'b0,'bZ,'b0,'b0000);
    tester("INCRMNT by 2, LSS evn parity",'bXXXX,'bXXXX,'b010000000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'bZ,'bZ,  'b0111,'b0101,'b1,'b1,'b0,'b0,'b0,'b1,'b0,'bZ,'b0,'b0000);
    tester("INCRMNT by 1, MSS odd parity",'bXXXX,'bXXXX,'b010000000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'bZ,'b0,  'b0101,'b0101,'b0,'b0,'b0,'b0,'b0,'b1,'b1,'bZ,'b0,'b0000);
    tester("INCRMNT by 2, IS odd parity", 'bXXXX,'bXXXX,'b010000000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'bZ,'b1,  'b0110,'b0101,'b1,'b1,'b0,'b0,'b1,'b1,'b1,'bZ,'b0,'b0000);
    `HEADER("SGNTWO");
    tester("SGNTWO MSS,Z=L, CN=H, parity",'bXXXX,'bXXXX,'b010100000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'b0,'b0,  'b0110,'b0101,'b0,'b0,'b0,'b0,'b0,'b1,'b1,'bZ,'b0,'b0000);
    tester("SGNTWO MSS,Z=H, CN=L, parity",'bXXXX,'bXXXX,'b010100000,'bxxxx,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'b1,'b0,  'b1010,'b1101,'b0,'b0,'b0,'b1,'b0,'b0,'b1,'bZ,'b0,'b0000);
     setup("LOADQ = 0000",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0000,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0000,'b0000,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b0000);
    tester("SGNTWO LSS,Z=L, CN=L, parity",'bXXXX,'bXXXX,'b010100000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'b0,'b0,  'b0110,'b0101,'b1,'b1,'b0,'b0,'b0,'b1,'b1,'bZ,'b0,'b0000);
     setup("LOADQ = 0001",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0001,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0001,'b0001,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0001);
    tester("SGNTWO LSS,Z=H, CN=H, parity",'bXXXX,'bXXXX,'b010100000,'bxxxx,'b0101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b1,'bZ,'b0,'b1,'b0,  'b1010,'b0101,'b1,'b1,'b0,'b1,'b0,'b1,'b1,'bZ,'b0,'b0001);
    `HEADER("TWOLAST");
     setup("LOADQ = 0010",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0010,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0010,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0010);
    tester("TWOLAST LSS, Z=Q(H), CN=L",   'bXXXX,'bXXXX,'b011000000,'b1110,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b0,'bZ,'b0,'b1,'bZ,  'b0111,'b1101,'b1,'b1,'b0,'b1,'b0,'b0,'b0,'b1,'b0,'b0001);
    tester("TWOLAST MSS, Z=L, CN=L",      'bXXXX,'bXXXX,'b011000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'b0,'b0,  'b1110,'b1101,'b0,'b1,'b0,'b0,'b0,'b1,'b0,'b0,'b0,'b0000);
    tester("TWOLAST MSS, Z=H, CN=H",      'bXXXX,'bXXXX,'b011000000,'b1110,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'b0,'bZ,'b0,'b1,'b0,  'b1111,'b1101,'b0,'b1,'b0,'b1,'b0,'b1,'b0,'b0,'b0,'b0000);
    tester("TWOLAST MSS, Z=L, CN=H",      'bXXXX,'bXXXX,'b011000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'b0,'b0,  'b1111,'b1101,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b0,'b0000);
    tester("TWOLAST MSS, Z=H, CN=L",      'bXXXX,'bXXXX,'b011000000,'b1110,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'bZ,'b1,'bZ,'b0,'b1,'b0,  'b1111,'b1101,'b0,'b1,'b0,'b1,'b0,'b0,'b1,'b0,'b0,'b0000);
    `HEADER("SLN, DLN");
     setup("LOADQ = 0010",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0010,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0010,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0010);
    tester("SLN, CN=L",                   'bXXXX,'bXXXX,'b100000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'bZ,'b1,'b1,'bZ,'bZ,'bZ,  'b1101,'b1101,'b1,'b1,'b0,'b0,'b0,'bZ,'b1,'b1,'b0,'b0101);
    tester("SLN, CN=H",                   'bXXXX,'bXXXX,'b100000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'bZ,'b1,'b0,'bZ,'bZ,'bZ,  'b1110,'b1101,'b1,'b1,'b0,'b0,'b0,'bZ,'b1,'b0,'b1,'b1010);
     setup("LOADQ = 0010",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0010,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0010,'b0010,'b0,'b0,'b0,'bX,'b0,'b1,'b0,'bX,'bX,'b0010);
    tester("DLN, CN=L, SIO0=L",           'bXXXX,'bXXXX,'b101000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'b0,'b1,'b1,'bZ,'bZ,'bZ,  'b1010,'b1101,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b1,'b0,'b0101);
    tester("DLN, CN=H, SIO0=L",           'bXXXX,'bXXXX,'b101000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'b0,'b1,'b0,'bZ,'bZ,'bZ,  'b1100,'b1101,'b1,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b1,'b1010);
    tester("DLN, CN=L, SIO0=H",           'bXXXX,'bXXXX,'b101000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'b1,'b1,'b1,'bZ,'bZ,'bZ,  'b1011,'b1101,'b1,'b1,'b0,'b0,'b0,'b1,'b1,'b1,'b0,'b0101);
    tester("DLN, CN=H, SIO0=H",           'bXXXX,'bXXXX,'b101000000,'bXXXX,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'b1,'b1,'b0,'bZ,'bZ,'bZ,  'b1101,'b1101,'b1,'b1,'b0,'b0,'b0,'b1,'b1,'b0,'b1,'b1010);
    `HEADER("DIVIDE");
//         ------------------------------ --a--- --b--- --i-------- --da-- --db-- --y--- oey -we -cn oeb -ea ien lss -s0 -s3 -q0 -q3 -z- -wm | --y--- --db-- -po -gn -c4 -z- -wm -s0 -s3 -q0 -q3 -qreg-
    tester("LOADQ = 0110",                'bXXXX,'bXXXX,'b011011110,'b0000,'b0110,'bZZZZ,'b0,'b1,'bX,'b1,'b1,'b0,'b1,'bZ,'b0,'bX,'bX,'bX,'b0,  'b0110,'b0110,'b0,'b0,'b0,'bX,'b0,'b0,'b0,'bX,'bX,'b0110);
    tester("DIVIDE, LSS, CN=L, Z=L",      'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'b0,'bZ,'b1,'bZ,'b0,'bZ,  'b0100,'b1101,'b1,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b1,'b1101);
    tester("DIVIDE, LSS, CN=H, Z=H",      'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'b0,'bZ,'b0,'bZ,'b1,'bZ,  'b0000,'b1101,'b0,'b0,'b1,'b1,'b0,'b0,'b1,'b0,'b1,'b1010);
    tester("DIVIDE, LSS, CN=L, Z=H",      'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'b1,'bZ,'b1,'bZ,'b1,'bZ,  'b1111,'b1101,'b0,'b0,'b1,'b1,'b0,'b1,'b0,'b1,'b0,'b0101);
    tester("DIVIDE, LSS, CN=H, Z=L",      'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'b1,'bZ,'b0,'bZ,'b0,'bZ,  'b0111,'b1101,'b1,'b0,'b1,'b0,'b0,'b1,'b0,'b0,'b1,'b1010);
    tester("DIVIDE, MSS, CN=L, Z=SGNFF",  'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'b0,'bZ,'b1,'bZ,'b0,'b0,  'b0100,'b1101,'b0,'b0,'b1,'b0,'b0,'b0,'b1,'b1,'b0,'b0101);
    tester("DIVIDE, MSS, CN=H, Z=SGNFF",  'bXXXX,'bXXXX,'b110000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'b0,'bZ,'b0,'bZ,'bZ,'b0,  'b0110,'b1101,'b0,'b0,'b1,'b0,'b0,'b0,'b1,'b0,'b1,'b1010);
    tester("DIVLAST,LSS, CN=L, Z=H",      'bXXXX,'bXXXX,'b111000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b0,'b1,'bZ,'b1,'bZ,'b1,'bZ,  'b0111,'b1101,'b0,'b0,'b1,'b1,'b0,'b1,'b0,'b1,'b0,'b0101);
    tester("DIVLAST,LSS, CN=H, Z=L",      'bXXXX,'bXXXX,'b111000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b0,'b1,'bZ,'b0,'bZ,'b0,'bZ,  'b0011,'b1101,'b1,'b0,'b1,'b0,'b0,'b1,'b0,'b0,'b1,'b1010);
    tester("DIVLAST,MSS, CN=L, Z=SGNFF",  'bXXXX,'bXXXX,'b111000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b0,'b1,'b1,'b0,'b1,'b0,'bZ,'b1,'bZ,'b0,'b0,  'b0010,'b1101,'b0,'b0,'b1,'b0,'b0,'b0,'b0,'b1,'b0,'b0101);
    tester("DIVLAST,MSS, CN=H, Z=SGNFF",  'bXXXX,'bXXXX,'b111000000,'b0101,'b1101,'bZZZZ,'b0,'b1,'b1,'b1,'b1,'b0,'b1,'b0,'bZ,'b0,'bZ,'bZ,'b0,  'b0011,'b1101,'b0,'b0,'b1,'b0,'b0,'b0,'b0,'b0,'b1,'b1010);

    #10 $finish;
end

endmodule
