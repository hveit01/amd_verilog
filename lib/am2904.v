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

`define I50 i[5:0]
`define I51 i[5:1]
`define I10 i[10:6]


module am2904(i, iz, ic, in, iovr,
              cem_, ez_, ec_, en_, eovr_, ceu_,
              yz, yc, yn, yovr, oey_,
              ct, oect_,
              sio0, sion, qio0, qion,
              se_, c0, cx, cp);
input [12:0] i;
input iz, ic, in, iovr;
input cem_, ez_, ec_, en_, eovr_, ceu_;
inout yz, yc, yn, yovr;
input oey_;
output ct;
input oect_;
inout sio0, sion, qio0, qion;
input se_;
output c0;
input cx;
input cp;

reg usr_z, usr_c, usr_n, usr_ovr;
reg msr_z, msr_c, msr_n, msr_ovr;
wire ctres;

// decode the USR mux
function fumux_z(input [5:0] i50, input uz, mz, iz);
begin
    casex (i50)
    'b001_X1X, 'b001_10X: fumux_z = uz;         // 12-17
    'b000_0X0:            fumux_z = mz;         // 00, 02
    'b000_001, 'b001_001: fumux_z = 'b1;        // 01, 11
    'b000_011, 'b001_000: fumux_z = 'b0;        // 03, 10
    default:              fumux_z = iz;         // 04-07, 20-77
    endcase
//    $display("fumux_z=%5b -> %b", i50, fumux_z);
end
endfunction
function fumux_c(input [5:0] i50, input uc, mc, ic);
begin
    casex (i50)
    'b001_X0X, 'b001_11X: fumux_c = uc;         // 10-11, 14-17
    'b000_0X0:            fumux_c = mc;         // 00, 02
    'b000_001, 'b001_011: fumux_c = 'b1;        // 01, 13
    'b000_011, 'b001_010: fumux_c = 'b0;        // 03, 12
    'b011_00X, 'b101_00X,
    'b111_00X:            fumux_c = ~ic;        // 30-31, 50-51, 70-71
    default:              fumux_c = ic;         // 04-07, 20-67, 72-77
    endcase
//    $display("fumux_c=%5b -> %b", i50, fumux_c);
end
endfunction
function fumux_n(input [5:0] i50, input un, mn, in);
begin
    casex (i50)
    'b001_0XX, 'b001_11X: fumux_n = un;         // 10-13, 16-17
    'b000_0X0:            fumux_n = mn;         // 00, 02
    'b000_001, 'b001_101: fumux_n = 'b1;        // 01, 15
    'b000_011, 'b001_100: fumux_n = 'b0;        // 03, 14
    default:              fumux_n = in;         // 04-07, 20-77
    endcase
//    $display("fumux_n=%5b -> %b", i50, fumux_n);
end
endfunction
function fumux_ovr(input [5:0] i50, input uo, mo, io);
begin
    casex (i50)
    'b001_0XX, 'b001_10X: fumux_ovr = uo;       // 10-15
    'b000_0X0:            fumux_ovr = mo;       // 00, 02
    'b000_001, 'b001_111: fumux_ovr = 'b1;      // 01, 17
    'b000_011, 'b001_110: fumux_ovr = 'b0;      // 03, 16
    'b000_11X: fumux_ovr = io | uo;             // 06, 07
    default:              fumux_ovr = io;       // 04-05, 20-77
    endcase
//    $display("fumux_o=%5b -> %b", i50, fumux_ovr);
end
endfunction

// decode the MSR mux
function fmmux_z(input [5:0] i50, input z, uz, mz, iz);
begin
    casex (i50)
    'b000_000:            fmmux_z = yz;         // 00
    'b000_001:            fmmux_z = 'b1;        // 01
    'b000_010:            fmmux_z = uz;         // 02
    'b000_011:            fmmux_z = 'b0;        // 03
    'b000_101:            fmmux_z = ~mz;        // 05
    default:              fmmux_z = iz;         // 04, 06-77
    endcase
//    $display("fmmux_z=%5b -> %b", i50, fmmux_z);
end
endfunction
function fmmux_c(input [5:0] i50, input c, uc, mc, ic, mo);
begin
    casex (i50)
    'b000_000:            fmmux_c = c;          // 00
    'b000_001:            fmmux_c = 'b1;        // 01
    'b000_010:            fmmux_c = uc;         // 02
    'b000_011:            fmmux_c = 'b0;        // 03
    'b000_100:            fmmux_c = mo;         // 04
    'b000_101:            fmmux_c = ~mc;        // 05
    'b0X1_00X, 'b1X1_00X: fmmux_c = ~ic;        // 10-11, 30-31, 50-51, 70-71
    default:              fmmux_c = ic;         // 06-07, 12-27, 32-47, 52-67, 72-77
    endcase
//    $display("fmmux_c=%5b -> %b", i50, fmmux_c);
end
endfunction
function fmmux_n(input [5:0] i50, input n, un, mn, in);
begin
    casex (i50)
    'b000_000:            fmmux_n = yn;         // 00
    'b000_001:            fmmux_n = 'b1;        // 01
    'b000_010:            fmmux_n = un;         // 02
    'b000_011:            fmmux_n = 'b0;        // 03
    'b000_101:            fmmux_n = ~mn;        // 05
    default:              fmmux_n = in;         // 04, 06-77
    endcase
//    $display("fmmux_n=%5b -> %b", i50, fmmux_n);
end
endfunction
function fmmux_ovr(input [5:0] i50, input o, uo, mo, io, mc);
begin
    casex (i50)
    'b000_000:            fmmux_ovr = o;        // 00
    'b000_001:            fmmux_ovr = 'b1;      // 01
    'b000_010:            fmmux_ovr = uo;       // 02
    'b000_011:            fmmux_ovr = 'b0;      // 03
    'b000_100:            fmmux_ovr = mc;       // 04
    'b000_101:            fmmux_ovr = ~mo;      // 05
    default:              fmmux_ovr = io;       // 06-77
    endcase
//    $display("fmmux_o=%5b -> %b", i50, fmmux_ovr);
end
endfunction

// decode the four shifters
function fsio0(input [4:0] i40, input qn, mc, sn);
begin
    casex (i40)
    'b100X0: fsio0 = 'b0;
    'b100X1: fsio0 = 'b1;
    'b1X1XX: fsio0 = qn;
    'b110X1: fsio0 = mc;
    'b110X0: fsio0 = sn;
    default: fsio0 = 'bZ;
    endcase
//    $display("i40=%5b fsio0=%b", i40, fsio0);
end
endfunction 
function fsion(input [4:0] i40, input mc, mn, s0, ic, q0, in, io);
begin
    casex (i40)
    'b000X0, 'b0011X: fsion = 'b0;
    'b000X1:          fsion = 'b1;
    'b00100, 'b01001,
    'b01100:          fsion = mc;
    'b00101:          fsion = mn;
    'b010X0:          fsion = s0;
    'b01011:          fsion = ic;
    'b011X1:          fsion = q0;
    'b01110:          fsion = in ^ io;
    default:          fsion = 'bZ;
    endcase
//    $display("i40=%5b mc=%b fsion=%b", i40, mc, fsion);
end
endfunction
function fqio0(input [4:0] i40, input qn, mc, sn);
begin
    casex (i40)
    'b10XXX:          fqio0 = i40[0];
    'b11011:          fqio0 = 'b0;
    'b1100X, 'b11010: fqio0 = qn;
    'b111X0:          fqio0 = mc;
    'b111X1:          fqio0 = sn;
    default:          fqio0 = 'bZ;
    endcase
//    $display("i40=%5b fqio0=%b", i40, fqio0);
end
endfunction
function fqion(input [4:0] i40, input mn, s0, q0);
begin
    casex (i40)
    'b0000X:          fqion = i40[0];
    'b00010:          fqion = msr_n;
    'b0X011, 'b0X1XX: fqion = sio0;
    'b0100X, 'b01010: fqion = qio0;
    default:          fqion = 'bZ;
    endcase
//    $display("i40=%5b fqion=%b", i40, fqion);
end
endfunction

// decode the MC load override logic
function floadmc(input [4:0] i10);
begin
    casex (i10)
    'b00010,
    'b00111,
    'b0100X,
    'b0110X,
    'b1XX0X: floadmc = 'b1;
    default: floadmc = 'b0;
    endcase
//    $display("i10=%5b floadmc=%b", i10, floadmc);
end    
endfunction

function floadwhat(input [4:0] i10);
    casex (i10)
    'b00010, 'b0100X: floadwhat = sio0;
    'b00111, 'b0110X: floadwhat = qio0;
    'b1XX0X:    floadwhat = sion;
    default:    floadwhat = 'bz;
    endcase
endfunction

// decode the carry in logic
function fcmux(input [13:0] i, input c, uc, mc);
begin
    casex ( { i[12], i[11], i[5], i[3:1] })
    'b0XXXXX:           fcmux = i[11];
    'b10XXXX:           fcmux = c;
    'b1100XX, 'b110X1X,
    'b110XX1:           fcmux = uc;
    'b110100:           fcmux = ~uc;
    'b111100:           fcmux = ~mc;
    default:            fcmux = mc;
    endcase
//    $display("ix=%b%b%b%3b fcmux=%b", i[12], i[11], i[5], i[3:1], fcmux);
end
endfunction

// decode the CT output
function fct(input [3:1] i31, input[7:0] src, input z, c, n, o);
    // note i[0] is polarity = 0 non-invert, =1 invert; this is decoded outside
begin
    casex (i31)
    'b000: fct = (n ^ o) | z;
    'b001: fct = n ^ o;
    'b010: fct = z;
    'b011: fct = o;
    'b100: fct = c | z;
    'b101: fct = c;
    'b110: fct = ~c | z;
    default: fct = n;
    endcase
//    $display("src=%s i=%3b fct=%b", src, i31, fct);
end
endfunction

//always @(se_ or oey_ or yz) begin
//    $display("DUT: se=%b oey=%b y=%b%b%b%b ct=%b", se_, oey_, yz,yc,yn,yovr, ct);
//end

// shift I/O
assign sio0 = (se_=='b1) ? 'bZ : fsio0(`I10, qion, msr_c, sion);
assign sion = (se_=='b1) ? 'bZ : fsion(`I10, msr_c, msr_n, sio0, ic, qio0, in, iovr);
assign qio0 = (se_=='b1) ? 'bZ : fqio0(`I10, qion, msr_c, sion);
assign qion = (se_=='b1) ? 'bZ : fqion(`I10, msr_n, sio0, qio0);

// carry in logic
assign c0 = fcmux(i, cx, usr_c, msr_c);

// output enable
assign yz   = (oey_=='b1 || i[5:0]=='b000000) ? 'bZ :
              (i[5]=='b0) ? usr_z :
              (i[4]=='b0) ? msr_z : iz;
assign yc   = (oey_=='b1 || i[5:0]=='b000000) ? 'bZ :
              (i[5]=='b0) ? usr_c :
              (i[4]=='b0) ? msr_c : ic;
assign yn   = (oey_=='b1 || i[5:0]=='b000000) ? 'bZ :
              (i[5]=='b0) ? usr_n :
              (i[4]=='b0) ? msr_n : in;
assign yovr = (oey_=='b1 || i[5:0]=='b000000) ? 'bZ :
              (i[5]=='b0) ? usr_ovr :
              (i[4]=='b0) ? msr_ovr : iovr;
            
// CT output
assign ctres = (i[5:1] == 'b00111) ? (in ^ msr_n) :
               (i[5:1] == 'b11100) ? (~ic | iz) :
               (i[5] == 'b0) ? fct(i[3:1], "u", usr_z, usr_c, usr_n, usr_ovr) :
               (i[5:4] == 'b10) ? fct(i[3:1], "m", msr_z, msr_c, msr_n, msr_ovr) :
                                  fct(i[3:1], "i", iz, ic, in, iovr);
assign ct = oect_ ? 'bZ : i[0] ? ~ctres : ctres;           
            
// load the MSR USR regs
always @(posedge cp) begin
    if (ceu_ == 'b0) begin
        usr_z   <= fumux_z(`I50, usr_z, msr_z, iz);
        usr_c   <= fumux_c(`I50, usr_c, msr_c, ic);
        usr_n   <= fumux_n(`I50, usr_n, msr_n, in);
        usr_ovr <= fumux_ovr(`I50, usr_ovr, msr_ovr, iovr);
    end;
    
    // override load of MC for shifts
    if (floadmc(`I10))
        msr_c <= floadwhat(`I10);
    else if (cem_ == 'b0 && ec_ == 'b0)
        msr_c <= fmmux_c(`I50, yc, usr_c, msr_c, ic, msr_ovr);
        
    if (cem_ == 'b0) begin
        if (ez_ == 'b0)
            msr_z <= fmmux_z(`I50, yz, usr_z, msr_z, iz);
        if (en_ == 'b0)
            msr_n <= fmmux_n(`I50, yn, usr_n, msr_n, in);
        if (eovr_ == 'b0)
            msr_ovr <= fmmux_ovr(`I50, yovr, usr_ovr, msr_ovr, iovr, msr_c);
    end
end
endmodule
