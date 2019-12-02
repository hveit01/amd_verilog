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

// am2910 microprogram sequencer

`timescale 1ns /100ps

`define JZ		6'bxx0000
`define CJS_F	6'bx00001
`define CJS_P	6'bx10001
`define JMAP	6'bxx0010
`define CJP_F	6'bx00011
`define CJP_P	6'bx10011
`define PUSH_F	6'bx00100
`define PUSH_P	6'bx10100
`define JSRP_F	6'bx00101
`define JSRP_P	6'bx10101
`define CJV_F	6'bx00110
`define CJV_P	6'bx10110
`define JRP_F	6'bx00111
`define JRP_P	6'bx10111
`define RFCT0	6'b0x1000
`define RFCT1	6'b1x1000
`define RPCT0	6'b0x1001
`define RPCT1	6'b1x1001
`define CRTN_F	6'bx01010
`define CRTN_P	6'bx11010
`define CJPP_F	6'bx01011
`define CJPP_P	6'bx11011
`define LDCT	6'bxx1100
`define LOOP_F	6'bx01101
`define LOOP_P	6'bx11101
`define CONT	6'bxx1110
`define TWB_F0	6'b001111
`define TWB_F1	6'b101111
`define TWB_P0	6'b011111
`define TWB_P1	6'b111111

module am2910(din,
	cp, rld_, cc_, ccen_, i, cin, oe_,
	full_, pl_, map_, vect_, y);
  
input [11:0] din;
input cp, rld_, cc_, ccen_;
input [3:0] i;
input cin, oe_;
output full_, pl_, map_, vect_;
output [11:0] y;

reg [11:0] ctreg;
reg [11:0] upc;
reg [11:0] stack[0:5];
reg [2:0] sp;

reg [11:0] incin;
reg [11:0] f;

reg [2:0] muxop;
reg [1:0] regop;
reg [1:0] stkop;
reg [2:0] enaop;

wire cc;
wire rzero;

initial begin
	sp <= 3'b010;
	enaop <= 3'b011;
end

assign cc = ccen_ | ~cc_;
assign rzero = |ctreg;  // is 0 if zero

`define MUXD		3'b000
`define MUXPC		3'b001
`define MUXR		3'b010
`define MUXF		3'b011
`define MUX0		3'b100
`define STKCLR		2'b00
`define STKHOLD		2'b01
`define STKPUSH		2'b10
`define STKPOP		2'b11
`define REGHOLD 	2'b00
`define REGLOAD 	2'b01
`define REGDEC  	2'b10
`define ENAPL		3'b011
`define ENAMAP		3'b101
`define ENAVECT		3'b110

always @(i or cc or rzero) begin
	muxop = `MUXPC;
	stkop = `STKHOLD;
	regop = `REGHOLD;
	enaop = `ENAPL;

	casex ( {rzero, cc, i} )
	`JZ: 		begin
					muxop = `MUX0;
					stkop = `STKCLR;
				end
	`JMAP:		begin
					muxop = `MUXD;
					enaop = `ENAMAP;
				end
	`CJP_P, `JRP_P:
				begin
					muxop = `MUXD;
				end
	`PUSH_F:	begin
					stkop = `STKPUSH;
				end
	`PUSH_P:	begin
					stkop = `STKPUSH;
					regop = `REGLOAD; 
				end
	`JSRP_F:	begin
					muxop = `MUXR;
					stkop = `STKPUSH;
				end
	`JSRP_P, `CJS_P:
				begin
					muxop = `MUXD;
					stkop = `STKPUSH;
				end
	`CJV_P:		begin
					muxop = `MUXD;
					enaop = `ENAVECT;
				end
	`JRP_F:		begin
					muxop = `MUXR;
				end
	`RFCT1, `TWB_F1:
				begin
					muxop = `MUXF;
					regop = `REGDEC;					
				end
	`RPCT1:		begin
					muxop = `MUXD;
					regop = `REGDEC;
				end
	`CRTN_P:	begin
					muxop = `MUXF;
					stkop = `STKPOP;					
				end
	`LOOP_F:	begin
					muxop = `MUXF;
				end
	`TWB_F0:
				begin
					muxop = `MUXD;
					stkop = `STKPOP;
				end
	`CJPP_P:
				begin
					muxop = `MUXD;
					stkop = `STKPOP;
				end
	`LDCT:		begin
					regop = `REGLOAD;
				end
	`LOOP_P, `RFCT0, `TWB_P0:
				begin
					stkop = `STKPOP;
				end
	`TWB_P1:
				begin
					stkop = `STKPOP;
					regop = `REGDEC;
				end
//	`CJV_F, `CJS_F, `CJP_F, `CRTN_F, `CJPP_F, `CONT, `RPCT0
	default:	;
	endcase
end

assign pl_   = enaop[2];
assign map_  = enaop[1];
assign vect_ = enaop[0];
assign full_ = (sp==3'b101) ? 1'b0 : 1'b1;

always @(posedge cp) begin
//$display("cp^ edge, muxop=%b incin = %12b", muxop, incin);
	if (cp==1'b1) begin
		if (regop==`REGLOAD || rld_==1'b0) begin
			ctreg = din;
		end else if (regop==`REGDEC) begin
			ctreg = ctreg - 1;
		end;

		case (muxop) // mux latch!
		`MUXD:   incin = din;
		`MUXPC:  incin = upc;
		`MUXR:   incin = ctreg;
		`MUXF:   incin = stack[sp];
		default: incin = 12'b0000_0000_0000;
		endcase;

//		$display("upc loaded : %12b", incin + { 11'b000_0000_0000, cin });
		case (stkop)
		`STKPUSH: 	begin
						sp = (full_==1'b0) ? sp : (sp+3'b001);
						stack[sp] = upc;
					end
		`STKPOP:	begin
						f = stack[sp];
						sp = (sp==3'b000) ? sp : (sp-3'b001);
					end
		`STKCLR:	begin
						sp = 3'b000;
					end
		default		;			
		endcase;
		upc =  incin + { 11'b000_0000_0000, cin };
	end
end

assign y = (oe_==1'b0) ? incin : 12'bzzzz_zzzz_zzzz;					

endmodule
