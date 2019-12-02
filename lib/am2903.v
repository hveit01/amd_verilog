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

// some standard vectors
`define ALL0  4'b0000
`define ALL1  4'b1111
`define ALLX  4'bxxxx
`define ALLZ  4'bzzzz

`define  SPECIAL   5'bX0000
`define  HIGH      5'b00001
`define  SUBR      5'b0001X
`define  SUBS      5'b0010X
`define  ADD       5'b0011X
`define  INCRS     5'b0100X
`define  INCRSNON  5'b0101X
`define  INCRR     5'b01101
`define  INCRNON   5'b01111
`define  LOW       5'b10001
`define  NOTRS     5'b1001X
`define  EXNOR     5'b1010X
`define  EXOR      5'b1011X
`define  AND       5'b1100X
`define  NOR       5'b1101X
`define  NAND      5'b1110X
`define  OR        5'b1111X

`define  MULT      4'b0000
`define  TWOMULT   4'b0010
`define  INCRMNT   4'b0100
`define  SGNTWO    4'b0101
`define  TWOLAST   4'b0110
`define  SLN       4'b1000
`define  DLN       4'b1010
`define  DIVIDE    4'b1100
`define  DIVLAST   4'b1110

// ALU Destinations
`define RAMDA      4'b0000      // F to RAM, Arith F/2 -> Y,
`define RAMDL      4'b0001      // F to RAM, Log F/2 -> Y  ,
`define RAMQDA     4'b0010      // F to RAM, Arith F/2 -> Y, Q/2 -> Q
`define RAMQDL     4'b0011      // F to RAM, Log F/2 -> Y  , Q/2 -> Q
`define RAM        4'b0100      // F to RAM, F -> Y        ,
`define QD         4'b0101      //         , F -> Y        , Q/2 -> Q
`define LOADQ      4'b0110      //         , F -> Y        , F -> Q
`define RAMQ       4'b0111      // F to RAM, F -> Y        , F -> Q
`define RAMUPA     4'b1000      // F to RAM, Arith 2F -> Y ,
`define RAMUPL     4'b1001      // F to RAM, Log 2F -> Y   ,
`define RAMQUPA    4'b1010      // F to RAM, Arith 2F -> Y , 2Q -> Q
`define RAMQUPL    4'b1011      // F to RAM, Log 2F -> Y   , 2Q -> Q
`define YBUS       4'b1100      //         , F -> Y        ,
`define QUP        4'b1101      //         , F -> Y        , 2Q -> Q
`define SIGNEXT    4'b1110      // F to RAM, SIO0 -> Y     ,
`define RAMEXT     4'b1111      // F to RAM, F -> Y        ,

// readability
`define LOGSHIFTL(src, in)    { src[2:0], in }
`define LOGSHIFTR(in, src)    { in, src[3:1] }
`define ARSHIFTL(src, in)     { src[3], src[1:0], in }
`define ARSHIFTR(in, src)     { src[3], in, src[2:1] }


`include "_alu29x03.v"

//**************************************************************************************

module am2903(a, b, da, db, 
              i, ien_,
              lss_, wrmss_, we_, ea_, oeb_, cn,
              gn, povr, z, cn4,
              qio0, qio3, sio0, sio3,
              y, oey_, 
              cp,
			 );

// RAM addresses
input [3:0] a, b;

// direct data a and ea select
input [3:0] da;
input ea_;

// direct data b and enable outport
inout [3:0] db;
input oeb_;

// opcode and Instr enable
input [8:0] i;
input ien_;

// carry in and out
input cn;
output cn4;

// G_/N, P_/OVR outputs
output gn, povr;

// Z pin
inout z;

// bidirectional shifts
inout sio0, sio3, qio0, qio3;

// LSS select, write/mss select and we_
input lss_;
inout wrmss_;
input we_;

// Y bidir and OEy enable
inout [3:0] y;
input oey_;

// cp low to high, Ram write on low
input cp;

reg [3:0] ram[0:15];
reg [3:0] qreg;
reg [3:0] alatch;
reg [3:0] blatch;

// ALU conections
wire [3:0] rmux, smux;
wire galu, palu, nalu, oalu;
wire [3:0] aluf, ashift, qshift, f;
wire parity, intcn4, bcdc4, intwr;
wire lss, mss, notspec, issln, isdln;

reg sgnff;

// decode ALU operations
function [12:0] alu_decoder(input [8:0] i, input z, input lss);
begin
//$display("alu_decoder: %9b %b %b", i, z, lss);
	casex ({lss, z, i})
	'bXX_XXXX00001: alu_decoder = 'b00_0000_100_00XX; // HIGH
	'bXX_XXXX0001X: alu_decoder = 'b00_0000_010_1101; // SUBR
	'bXX_XXXX0010X: alu_decoder = 'b00_0000_010_1110; // SUBS
	'bXX_XXXX0011X: alu_decoder = 'b00_0000_010_1100; // ADD
	'bXX_XXXX0100X: alu_decoder = 'b00_0000_010_100X; // INCRS
	'bXX_XXXX0101X: alu_decoder = 'b00_0000_010_101X; // INCRSNON
	'bXX_XXXX01101: alu_decoder = 'b00_0000_010_01X0; // INCRR
	'bXX_XXXX01111: alu_decoder = 'b00_0000_010_01X1; // INCRNON
	'bXX_XXXX10001: alu_decoder = 'b00_0000_000_00XX; // LOW
	'bXX_XXXX1001X: alu_decoder = 'b00_0000_101_1101; // NOTRS
	'bXX_XXXX1010X: alu_decoder = 'b00_0000_000_1101; // EXNOR
	'bXX_XXXX1011X: alu_decoder = 'b00_0000_000_1100; // EXOR
	'bXX_XXXX1100X: alu_decoder = 'b00_0000_101_1100; // AND
	'bXX_XXXX1101X: alu_decoder = 'b00_0000_101_1111; // NOR
	'bXX_XXXX1110X: alu_decoder = 'b00_0000_001_1100; // NAND
	'bXX_XXXX1111X: alu_decoder = 'b00_0000_001_1111; // OR
	'bX0_00X000000: alu_decoder = 'b00_0000_010_1000; // MULT/TWOMULT, Z=0
	'bX1_00X000000: alu_decoder = 'b00_0000_010_1100; // MULT/TWOMULT, Z=1
	'b0X_010000000: alu_decoder = 'b01_0000_010_1100; // INCRMNT, LSS=0
	'b1X_010000000: alu_decoder = 'b10_0000_010_1100; // INCRMNT, LSS=1
	'bX0_010100000: alu_decoder = 'b00_0000_010_100X; // SGNTWO, Z=0
	'bX1_010100000: alu_decoder = 'b00_0000_010_101X; // SGNTWO, Z=1
    'bX0_011000000: alu_decoder = 'b00_0000_010_100X; // TWOLAST, Z=0
    'bX1_011000000: alu_decoder = 'b00_0000_010_1101; // TWOLAST, Z=1
	'bXX_10X000000: alu_decoder = 'b00_0000_010_100X; // SLN, DLN
    'bX0_11X000000: alu_decoder = 'b00_0000_010_1100; // DIVIDE/DIVLAST, Z=0
    'bX1_11X000000: alu_decoder = 'b00_0000_010_1101; // DIVIDE/DIVLAST, Z=1
    default:        alu_decoder = 'b00_0000_100_00XX; // HIGH
	endcase
end
endfunction

// SIO0 function decoder
function fsio0(input [8:0] i, input notspec, aluf0, parity);
	if (notspec) begin
		casex (i[8:7])
		'b00: 	 fsio0 = aluf0;
		'b01:	 fsio0 = parity;
		default: fsio0 = 'bZ;
		endcase
	end else begin
		casex (i[8:5])
		'b00X0, 'b0110:  fsio0 = aluf0;
		'b010X:          fsio0 = parity;
		default:         fsio0 = 'bZ;
		endcase
	end
endfunction

// SIO3 function decoder
function fsio3(input [8:0] i, input notspec, mss, input aluf3, aluf2, ra3, sio0);
	if (notspec) begin
		casex ( { mss, i[8:5] } )
		'bX_1110: 			fsio3 = sio0;
		'b1_10X0: 			fsio3 = aluf2;
		'b0_10X0, 'bX_10X1,
		'bX_110X, 'bX_1111: fsio3 = aluf3;
		default:  			fsio3 = 'bZ;
        endcase
    end else begin
		casex ( { mss, i[8:5] } )
		'bX_1000, 'b0_1010,
		'b0_1100, 'bX_1110: fsio3 = aluf3;
		'b1_1010:			fsio3 = ra3;
		'b1_1100:			fsio3 = ~ra3;
		default:			fsio3 = 'bZ;
		endcase
    end	
endfunction

// ALUSHIFTER function decoder
function [3:0] fashifter(input [8:0] i, input notspec, mss, input [3:0] aluf, input sio0, sio3);
	if (notspec) begin
		casex ( { mss, i[8:5]} )
		'b1_00X0:		    fashifter = `ARSHIFTR(sio3, aluf);
		'bX_00X1, 'b0_00X0:	fashifter = `LOGSHIFTR(sio3, aluf);
		'b1_10X0:		    fashifter = `ARSHIFTL(aluf, sio0);
		'bX_10X1, 'b0_10X0:	fashifter = `LOGSHIFTL(aluf, sio0);
		'bX_1110:		    fashifter = { sio0, sio0, sio0, sio0 };
		default:  	        fashifter = aluf;
        endcase
    end else begin
		casex (i[8:5])
		'b00X0, 'b0110:		fashifter = `LOGSHIFTR(sio3, aluf);
		'b1010, 'b1100:		fashifter = `LOGSHIFTL(aluf, sio0);
		default:			fashifter = aluf;
		endcase
    end
endfunction	

// QIO0 function decoder
function fqio0(input [8:0] i, input notspec, qreg0);
	if (notspec) begin
		casex (i[8:5])
		'b001X, 'b0101:	fqio0 = qreg0;
		default:		fqio0 = 'bZ;
		endcase
	end else begin
		casex (i[8:5])
		'b00X0, 'b0110:	fqio0 = qreg0;
		default:		fqio0 = 'bZ;
		endcase
	end
endfunction

// QIO3 function decoder
function fqio3(input [8:0] i, input notspec, qreg3);
	if (notspec) begin
		casex (i[8:5])
		'b101X, 'b1101:	fqio3 = qreg3;
		default:		fqio3 = 'bZ;
		endcase
	end else begin
		casex (i[8:5])
		'b10X0, 'b11X0:	fqio3 = qreg3;
		default:		fqio3 = 'bZ;
		endcase
	end
endfunction

function [3:0] fqshifter(input [8:0] i, input notspec, input [3:0] aluf, qreg, input qio0, qio3);
	if (notspec) begin
		casex (i[8:5])
		'b001X,	'b0101:	fqshifter = `LOGSHIFTR(qio3, qreg);
		'b101X, 'b1101:	fqshifter = `LOGSHIFTL(qreg, qio0);
		'b011X:			fqshifter = aluf; // QLOAD
		default:		fqshifter = qreg; // QHOLD
		endcase
	end else begin
		casex (i[8:5])
		'b00X0, 'b0110:	fqshifter = `LOGSHIFTR(qio3, qreg);
		'b10X0, 'b11X0:	fqshifter = `LOGSHIFTL(qreg, qio0);
		default:		fqshifter = qreg;
		endcase
	end
endfunction

// adjustment for Y3 in special ops
function [3:0] fy3(input [8:0] i, input notspec, mss, input [3:0] ashift, input cn4, fovr, sf);
	if (notspec || ~mss)
		fy3 = ashift;
	else begin
		casex ({ mss, i[8:5] } )
		'b1_0000:		fy3 = { cn4,  ashift[2:0] };
		'b1_0X10:		fy3 = { fovr, ashift[2:0] };
		'b1_0101:		fy3 = { sf,   ashift[2:0] };
		default:		fy3 = ashift;
		endcase
	end
endfunction

// Z output decoder
function fz(input [8:0] i, input notspec, mss, lss, input [3:0] y, qreg, input sgnff, smux3);
	if (notspec)
		fz = ~(|y);
	else begin
		casex ( { mss, lss, i[8:5] } )
		'b01_00X0, 'b01_0110:	fz = qreg[0];
		'bXX_0100:				fz = ~(|y);
		'b10_0101:				fz = smux3;
		'bXX_1000:				fz = ~(|qreg);
		'bXX_1010:				fz = ~((|qreg) | (|y));
		'b10_11X0:				fz = sgnff;
		default:		fz = 'bZ;
		endcase
	end
endfunction

// cn4 output decoder
function fcn4(input [8:0] i, input issln, isdln, mss, input [3:0] aluf, qreg, intcn4);
	if (i[4])
		fcn4 = 'b0;
	else if (mss) begin
		if (issln)
			fcn4 = qreg[3] ^ qreg[2];
		else if (isdln)
			fcn4 = aluf[3] ^ aluf[2];
		else
			fcn4 = intcn4;
	end else
		fcn4 = intcn4;
endfunction

// p/ovr output decoder
function fpovr(input [8:0] i, input issln, isdln, mss, input [3:0] aluf, qreg, input oalu, palu);
	if (mss) begin
		if (issln)
			fpovr = qreg[2] ^ qreg[1];
		else if (isdln)
			fpovr = aluf[2] ^ aluf[1];
		else
			fpovr = oalu;
	end else
		fpovr = palu;
endfunction

// g/n output decoder
function fgn(input [8:0] i, input issln, mss, qreg3, f3, sf3, galu);
	if (mss) begin
		if (issln)
			fgn = qreg3;
		else if (i=='b010100000)
            fgn = sf3;
        else
			fgn = f3;
	end else
		fgn = galu;
endfunction

// WRITE decoder
function fwrite(input [8:0] i, input notspec, lss_, ien_);
	if (lss_)
		fwrite = 'bZ;
	else if (notspec) begin
		casex (i[8:5])
		'b0101, 'b0110,
		'b110X:			fwrite = 'b1;
		default:		fwrite = ien_;
		endcase
	end else
		fwrite = ien_;
endfunction

// check when to store SGNFF
function fsgnff(input [8:0] i, input notspec);
	if (notspec)
		fsgnff = 'b0;
	else if (i[8:5] == `DLN || i[8:5]==`DIVIDE)
		fsgnff = 'b1;
	else
		fsgnff = 'b0;
endfunction

// helpers for instruction decoder
assign lss = ~lss_;
assign mss = lss_ & ~wrmss_;
assign notspec = |i[4:0]; // not special op
assign issln = i == 'b100000000;
assign isdln = i == 'b101000000;

// use db as output
assign db = oeb_ ? `ALLZ : blatch;

// alu source mux
assign rmux = ea_ ? da : alatch;
assign smux = i[0] ? qreg :
              oeb_ ? db : blatch;
              
// ALU
_alu29x03 alu(
    .a(rmux), .b(smux), 
    .ctrl(alu_decoder(i, z, lss)), .cn(cn), 
    .gg(galu), .gp(palu), 
    .n(nalu), .ovr(oalu), 
    .cn4(intcn4), .bcdc4(bcdc4),
    .f(aluf));

//always @(rmux or smux or aluf or ram[0]) begin
//$display("%b %b%b: r=%4b s=%4b aluf=%4b f=%4b y=%4b ashift=%4b", we_, mss, lss, rmux, smux, aluf, f, y, ashift);
//end

// calculate parity
assign parity = (^aluf) ^ sio3;

// alu shifter
assign ashift = fashifter(i, notspec, mss, aluf, sio0, sio3);
assign sio0 = fsio0(i, notspec, aluf[0], parity);
assign sio3 = fsio3(i, notspec, mss, aluf[3], aluf[2], rmux[3] ^ aluf[3], sio0);
                 
// q shifter
assign qshift = fqshifter(i, notspec, aluf, qreg, qio0, qio3);
assign qio0   = fqio0(i, notspec, qreg[0]);
assign qio3   = fqio3(i, notspec, qreg[3]);

// RAM latches
always @(negedge cp) begin
    if (cp == 1'b0) begin
//    $display("latches = %b %b mux=%b %b", ram[a], ram[b], rmux, smux);
        alatch <= ram[a];
        blatch <= ram[b];
    end
end

// calculate real output (adjust bit 3)
assign f    = fy3(i, notspec, mss, ashift, cn4, aluf[3] ^ oalu, smux[3] ^ aluf[3]);

// calculate y
assign y    = oey_ ? `ALLZ : f;

// calculate Z, cn4, p_/ovr, q_/n
assign z    = fz(i, notspec, mss, lss, y, qreg, sgnff, smux[3]);
assign cn4  = fcn4(i, issln, isdln, mss, aluf, qreg, intcn4);
assign povr = fpovr(i, issln, isdln, mss, aluf, qreg, oalu, palu);
assign gn   = fgn(i, issln, mss, qreg[3], f[3], smux[3] ^ f[3], galu);

// calculate write from internal write
assign wrmss_ = fwrite(i, notspec, lss_, ien_);

// ram and Q load
always @(posedge cp) begin
    if (cp == 1'b1) begin
        if (~we_)
            ram[b] = y;
        if (~ien_) begin
            qreg <= qshift;
            if (fsgnff(i, notspec))
                sgnff <= rmux[3] ^ aluf[3];
        end
    end
end

endmodule
