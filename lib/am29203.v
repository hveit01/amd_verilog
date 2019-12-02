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

`define  MULT      5'b00000
`define  BCD2BIN   5'b00010     // am29203
`define  MULTIBCD  5'b00011     // am29203
`define  TWOMULT   5'b00100
`define  DECRMNT   5'b00110     // am29203
`define  INCRMNT   5'b01000
`define  SGNTWO    5'b01010
`define  TWOLAST   5'b01100
`define  BCDDIV2   5'b01110
`define  SLN       5'b10000
`define  BIN2BCD   5'b10010     // am29203
`define  MULTIBIN  5'b10011     // am29203
`define  DLN       5'b10100
`define  BCDADD    5'b10110     // am29203
`define  DIVIDE    5'b11000
`define  BCDSUBS   5'b11010     // am29203
`define  DIVLAST   5'b11100
`define  BCDSUBR   5'b11110     // am29203


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

module am29203(a, b, da, db, 
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
inout [3:0] da;
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
wire [3:0] aluf, ashift, bcdca, bcdcs, qshift, f;
wire parity, intcn4, bcdc4, intwr;
wire lss, mss, notspec, issln, isdln;
wire [12:0] aluops;

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
    'bXX_0001X0000: alu_decoder = 'b00_0001_000_100X; // BCD2BIN/MULTIBCD
    'b0X_001100000: alu_decoder = 'b01_0000_010_1101; // DECRMNT, LSS=0
    'b1X_001100000: alu_decoder = 'b10_0000_010_1101; // DECRMNT, LSS=1
	'b0X_010000000: alu_decoder = 'b01_0000_010_1100; // INCRMNT, LSS=0
	'b1X_010000000: alu_decoder = 'b10_0000_010_1100; // INCRMNT, LSS=1
	'bX0_010100000: alu_decoder = 'b00_0000_010_100X; // SGNTWO, Z=0
	'bX1_010100000: alu_decoder = 'b00_0000_010_101X; // SGNTWO, Z=1
    'bX0_011000000: alu_decoder = 'b00_0000_010_100X; // TWOLAST, Z=0
    'bX1_011000000: alu_decoder = 'b00_0000_010_1101; // TWOLAST, Z=1
    'bXX_011100000: alu_decoder = 'b00_0001_000_100X; // BCDDIV2
	'bXX_10X000000: alu_decoder = 'b00_0000_010_100X; // SLN, DLN
    'bXX_1001X0000: alu_decoder = 'b00_0010_000_100X; // BIN2BCD/MULTIBIN
    'bXX_101100000: alu_decoder = 'b00_0100_010_1100; // BCDADD
    'bX0_11X000000: alu_decoder = 'b00_0000_010_1100; // DIVIDE/DIVLAST, Z=0
    'bX1_11X000000: alu_decoder = 'b00_0000_010_1101; // DIVIDE/DIVLAST, Z=1
    'bXX_110100000: alu_decoder = 'b00_1000_010_1110; // BCDSUBS
    'bXX_111100000: alu_decoder = 'b00_1000_010_1101; // BCDSUBR
    default:        alu_decoder = 'b00_0000_100_00XX; // HIGH
	endcase
end
endfunction

// SIO0 function decoder
function fsio0(input [8:0] i, input notspec, aluf0, parity);
	if (notspec) begin
		casex (i[8:7])
		'b00: 	 fsio0 = aluf0;  // RAMDA/L, RAMQDA/L
		'b01:	 fsio0 = parity; // RAM, QD, LOADQ, RAMQ
		default: fsio0 = 'bZ;    // all others
		endcase
	end else begin
		casex (i[8:4])
		'b00X00, 'b0001X,
        'b01100:          fsio0 = aluf0;  // MULT/TWOMULT, BCD2BIN/MULTIBCD
		'b0X110, 'b010X0: fsio0 = parity; // DECRMNT, INCRMNT, SGNTWO, BCDDIV2
		default:          fsio0 = 'bZ;    // all others
		endcase
	end
endfunction

// SIO3 function decoder
function fsio3(input [8:0] i, input notspec, mss, input aluf3, aluf2, ra3, sio0);
	if (notspec) begin
		casex ( { mss, i[8:5] } )
		'bX_1110: 			fsio3 = sio0;  // SIGNEXT
		'b1_10X0: 			fsio3 = aluf2; // RAMUPA/RAMQUPA MSS
		'b0_10X0, 'bX_10X1,                // RAMUPA/RAMQUPA xSS, RAMUPL/RAMQUPL
		'bX_110X, 'bX_1111: fsio3 = aluf3; // YBUS, QUP, RAMEXT
		default:  			fsio3 = 'bZ;   // all others
        endcase
    end else begin
		casex ( { mss, i[8:4] } )
		'bX_10000, 'b0_10100,                // SLN, DLN xSS
		'b0_11000, 'bX_11100,                // DIVIDE xSS, DIVLAST
        'bX_1001X:            fsio3 = aluf3; // BIN2BCD/MULTIBCD
		'b1_10100:			  fsio3 = ra3;   // DLN MSS
		'b1_11000:			  fsio3 = ~ra3;  // DIVIDE MSS
        'bX_10110, 'bX_11X10: fsio3 = 'b0;   // BCDADD, BCDSUBS/BCDSUBR
		default:			  fsio3 = 'bZ;   // all others
		endcase
    end	
endfunction

// ALUSHIFTER function decoder
function [3:0] fashifter(input [8:0] i, input notspec, mss, input [3:0] aluf, input sio0, sio3);
	if (notspec) begin
		casex ( { mss, i[8:5]} )
		'b1_00X0:		    fashifter = `ARSHIFTR(sio3, aluf);      // RAMDA/RAMQDA MSS
		'bX_00X1, 'b0_00X0:	fashifter = `LOGSHIFTR(sio3, aluf);     // RAMDL/RAMQDL, RAMDA/RAMQDA xSS
		'b1_10X0:		    fashifter = `ARSHIFTL(aluf, sio0);      // RAMUPA/RAMQUPA MSS
		'bX_10X1, 'b0_10X0:	fashifter = `LOGSHIFTL(aluf, sio0);     // RAMUPL/RAMQUPL, RAMUPA/RAMQUPA xSS
		'bX_1110:		    fashifter = { sio0, sio0, sio0, sio0 }; // SIGNEXT
		default:  	        fashifter = aluf;                       // all others
        endcase
    end else begin
		casex (i[8:4])
        'b0001X,                                                    // BCD2BIN/MULTIBIN
		'b00X00, 'b01100:	fashifter = `LOGSHIFTR(sio3, aluf);     // MULT/TWOMULT, TWOLAST
        'b1001X,                                                    // BIN2BCD/MULTIBCD
		'b10100, 'b11000:	fashifter = `LOGSHIFTL(aluf, sio0);     // DLN, DIVIDE
		default:			fashifter = aluf;                       // all others
		endcase
    end
endfunction	

// QIO0 function decoder
function fqio0(input [8:0] i, input notspec, qreg0);
	if (notspec) begin
		casex (i[8:5])
		'b001X, 'b0101:	    fqio0 = qreg0;  // RAMQDA/RAMQDL, QD
		default:		    fqio0 = 'bZ;    // all others
		endcase
	end else begin
		casex (i[8:4])
        'b0001X,                            // BCD2BIN/MULTIBIN
		'b00X00, 'b01100:	fqio0 = qreg0;  // MULT/TWOMULT, TWOLAST
		default:		    fqio0 = 'bZ;    // all others
		endcase
	end
endfunction

// QIO3 function decoder
function fqio3(input [8:0] i, input notspec, qreg3);
	if (notspec) begin
		casex (i[8:5])
		'b101X, 'b1101:	    fqio3 = qreg3;      // RAMQUPA/RAMQUPL, QUP
		default:		    fqio3 = 'bZ;        // all others
		endcase
	end else begin
		casex (i[8:4])
        'b10010,                                // BIN2BCD
		'b10X00, 'b11X00:	fqio3 = qreg3;      // SLN/DLN, DIVIDE/DIVLAST
		default:		    fqio3 = 'bZ;        // all others
		endcase
	end
endfunction

function [3:0] fqshifter(input [8:0] i, input notspec, input [3:0] aluf, qreg, input qio0, qio3);
	if (notspec) begin
		casex (i[8:5])
		'b001X,	'b0101:	    fqshifter = `LOGSHIFTR(qio3, qreg); // RAMQDA/RAMQDL, QD
		'b101X, 'b1101:	    fqshifter = `LOGSHIFTL(qreg, qio0); // RAMQUPA/RAMQUPL, QUP
		'b011X:			    fqshifter = aluf;                   // LOADQ/RAMQ
		default:		    fqshifter = qreg;                   // all others, hold
		endcase
	end else begin
		casex (i[8:4])
        'b00010,                                                // BCD2BIN
		'b00X00, 'b01100:	fqshifter = `LOGSHIFTR(qio3, qreg); // MULT/TWOMULT, TWOLAST
        'b10010,                                                // BIN2BCD
		'b10X00, 'b11X00:	fqshifter = `LOGSHIFTL(qreg, qio0); // SLN/DLN, DIVIDE/DIVLAST
		default:		    fqshifter = qreg;
		endcase
	end
endfunction

// adjustment for Y3 in special ops
function [3:0] fy3(input [8:0] i, input notspec, mss, input [3:0] ashift, input cn4, fovr, sf);
	if (notspec || ~mss)
		fy3 = ashift;                                   // all normal ALU ops
	else begin
		casex ({ mss, i[8:5] } )
		'b1_0000:		fy3 = { cn4,  ashift[2:0] };    // MULT MSS
		'b1_0X10:		fy3 = { fovr, ashift[2:0] };    // TWOMULT/TWOLAST MSS
		'b1_0101:		fy3 = { sf,   ashift[2:0] };    // SGNTWO MSS
		default:		fy3 = ashift;                   // all others
		endcase
	end
endfunction

// Z output decoder
function fz(input [8:0] i, input notspec, mss, lss, input [3:0] y, qreg, input sgnff, smux3);
	if (notspec)
		fz = ~(|y);                                     // all normal ALU ops
	else begin
		casex ( { mss, lss, i[8:4] } )
		'b01_00X00, 'b01_01100:	fz = qreg[0];           // MULT/TWOMULT LSS, TWOLAST LSS
		'bXX_01000, 'bXX_0001X,                         // INCRMNT, BCD2BIN/MULTIBIN
        'bXX_0X110, 'bXX_1X11X,	                        // DECRMNT/BCDDIV2, BCDADD/BCDSUBR
        'bXX_11010:             fz = ~(|y);             // BCDSUBS
		'b10_01010:				fz = smux3;             // SGNTWO MSS
		'bXX_10000:				fz = ~(|qreg);          // SLN
		'bXX_10100:				fz = ~((|qreg) | (|y)); // DLN
		'b10_11X00:				fz = sgnff;             // DIVIDE/DIVLAST
		default:		        fz = 'bZ;
		endcase
	end
endfunction

// cn4 output decoder
function fcn4(input [8:0] i, input issln, isdln, mss, input [3:0] aluf, qreg, intcn4);
	if (i[4])
		fcn4 = 'b0;                                     // all normal ALU ops and MULTIBIN/MULTIBCD
	else if (mss) begin
		if (issln)
			fcn4 = qreg[3] ^ qreg[2];                   // SLN MSS
		else if (isdln)
			fcn4 = aluf[3] ^ aluf[2];                   // DLN MSS
		else
			fcn4 = intcn4;                              // all others
	end else
		fcn4 = intcn4;                                  // others
endfunction

// p/ovr output decoder
function fpovr(input [8:0] i, input issln, isdln, mss, input [3:0] aluf, qreg, input oalu, palu);
	if (mss) begin
		if (issln)
			fpovr = qreg[2] ^ qreg[1];                  // SLN MSS
		else if (isdln)
			fpovr = aluf[2] ^ aluf[1];                  // DLN MSS
		else
			fpovr = oalu;                               // all other MSS
	end else
		fpovr = palu;                                   // all others
endfunction

// g/n output decoder
function fgn(input [8:0] i, input issln, mss, qreg3, f3, sf3, galu);
	if (mss) begin
		if (issln)
			fgn = qreg3;                                // SLN MSS
		else if (i=='b010100000)
            fgn = sf3;                                  // SGNTWO MSS
        else
			fgn = f3;                                   // all other MSS
	end else
		fgn = galu;                                     // all others
endfunction

// WRITE decoder
function fwrite(input [8:0] i, input notspec, lss_, ien_);
	if (lss_)
		fwrite = 'bZ;                                   // not LSS: is input
	else if (notspec) begin
		casex (i[8:5])
		'b0101, 'b0110,                                 // QD, LOADQ
		'b110X:			fwrite = 'b1;                   // YBUS, QUP
		default:		fwrite = ien_;                  // otherwise follow IEN_
		endcase
	end else
		fwrite = ien_;                                  // all special ops follow IEN_
endfunction

// check when to store SGNFF
function fsgnff(input [8:0] i, input notspec);
	if (notspec)
		fsgnff = 'b0;                                   // all normal ops
	else if (i[8:4]==`DLN || i[8:4]==`DIVIDE)           // DLN and DIVIDE set SGNFF
		fsgnff = 'b1;                                   
	else
		fsgnff = 'b0;                                   // all other specials do not
endfunction

// helpers for instruction decoder
assign lss = ~lss_;
assign mss = lss_ & ~wrmss_;
assign notspec = |i[3:0]; // not special op
assign issln = i=='b100000000;
assign isdln = i=='b101000000;

`define BCDA aluops[9]
`define BCDS aluops[10]
assign aluops = alu_decoder(i, z, lss);

// da, db as outputs
assign da = ea_ ? `ALLZ : alatch ;
assign db = oeb_ ? `ALLZ : blatch;
    
// alu source mux, da, db are inputs
assign rmux = ea_ ? da : alatch;
assign smux = i[0] ? qreg : oeb_ ? db : blatch;
              
// ALU
_alu29x03 alu(
    .a(rmux), .b(smux), 
    .ctrl(aluops), .cn(cn), 
    .gg(galu), .gp(palu), 
    .n(nalu), .ovr(oalu), 
    .cn4(intcn4), .bcdc4(bcdc4),
    .f(aluf));

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

// correction for BCD add
assign bcdca[0] = aluf[0]; 
assign bcdca[1] = aluf[1] ^ bcdc4; 
assign bcdca[2] = aluf[2] ^ (~aluf[1] & bcdc4);
assign bcdca[3] = aluf[3] ^ ((aluf[1] | aluf[2]) & bcdc4);

// correction for BCD sub
assign bcdcs[0] = aluf[0];
assign bcdcs[1] = aluf[1] ^ ~bcdc4;
assign bcdcs[2] = aluf[2] ^ (aluf[1] & ~bcdc4);
assign bcdcs[3] = aluf[3] ^ ((~aluf[1] | ~aluf[2]) & ~bcdc4);

//always @(aluf or bcdcs or bcdc4) begin
//$display("r=%4b s=%4b aluf=%4b bcdca=%4b bcdc4=%b", rmux,smux, aluf, bcdca, bcdc4);
//end

// calculate real output (adjust bit 3)
assign f    = fy3(i, notspec, mss, ashift, cn4, aluf[3] ^ oalu, smux[3] ^ aluf[3]);

// calculate y
assign y = (oey_==1'b1) ? `ALLZ :
           `BCDS ? bcdcs :
           `BCDA ? bcdca : f;

// calculate Z, cn4, p_/ovr, q_/n, am29203: Z is controlled by oey_
assign z    = oey_ ? 'bz : fz(i, notspec, mss, lss, y, qreg, sgnff, smux[3]);
assign cn4  = fcn4(i, issln, isdln, mss, aluf, qreg, intcn4);
assign povr = fpovr(i, issln, isdln, mss, aluf, qreg, oalu, palu);
assign gn   = fgn(i, issln, mss, qreg[3], f[3], smux[3] ^ f[3], galu);
              
// calculate write from internal write
assign wrmss_ = fwrite(i, notspec, lss_, ien_);

// ram and Q load
always @(posedge cp) begin
    if (cp == 1'b1) begin
        if (we_ == 1'b0)
            ram[b] = y;
        if (ien_ == 1'b0) begin
            qreg <= qshift;
            if (fsgnff(i, notspec))
                sgnff <= rmux[3] ^ aluf[3];
        end
    end
end

endmodule
