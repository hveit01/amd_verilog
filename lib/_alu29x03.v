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


`define ALL0  4'b0000
`define ALL1  4'b1111

// ctrl bits
`define APOL   ctrl[0]
`define BPOL   ctrl[1]
`define AEN    ctrl[2]
`define BEN    ctrl[3]
//
`define J      ctrl[4]
`define K      ctrl[5]
`define M      ctrl[6]
//
`define BCDBIN ctrl[7]
`define BINBCD ctrl[8]
`define BCDA   ctrl[9]
`define BCDS   ctrl[10]
//
`define AZRO   ctrl[11]
`define AONE   ctrl[12]

// readability
`define G0 g[0]
`define G1 g[1]
`define G2 g[2]
`define G3 g[3]
`define P0 p[0]
`define P1 p[1]
`define P2 p[2]
`define P3 p[3]

module _alu29x03(a, b, ctrl, cn, gg, gp, n, ovr, cn4, bcdc4, f);
input [3:0] a, b;
input [12:0] ctrl;
input cn;
output gg, gp, n, ovr, cn4, bcdc4;
output [3:0] f;

wire [3:0] ain, ainv, binv;
wire [3:0] r, s;
wire [3:0] g, p;
wire [3:0] fx;
wire [3:0] clb, clx, binbcd, bcdbin;

task alu_ctrl_debug;
input [12:0] ctrl;
begin
	$write ("PLA = |");
	if (`AONE) $write(" AONE");
	if (`AZRO) $write(" AZRO");
	$write(" |");
	if (`BCDS) $write(" BCDS");
	if (`BCDA) $write(" BCDA");
	if (`BINBCD) $write(" BINBCD");
	if (`BCDBIN) $write(" BCDBIN");
	$write(" |");
	if (`M) $write(" M");
	if (`K) $write(" K");
	if (`J) $write(" J");
	$write(" |");
	if (`BEN) $write(" BEN");
	if (`AEN) $write(" AEN");
	if (`BPOL) $write(" BPOL");
	if (`APOL) $write(" APOL");
	$write(" |\n");
end
endtask

// basic functions
assign ain  = `AONE ? 4'b0001 : `AZRO ? `ALL0 : a;
assign ainv = `APOL ? ~ain : ain;
assign binv = `BPOL ? ~b : b;
assign r    = `AEN ? ainv : `ALL0; 
assign s    = `BEN ? binv : `ALL0;
assign g    = r & s;
assign p    = `J ? `ALL1 : (r | s);
assign fx   = ~g & p;

//always @(fx or clx or clb or f) begin
//$display("ALU r=%4b s=%4b g=%4b p=%4b fx=%b clb=%4b clx=%4b aluf=%4b cn=%b",r,s,g,p,fx,clb, clx, f, cn);
//end

//always @(ctrl) begin
//  alu_ctrl_debug(ctrl);
//end

// binary CLA
assign clb[0] = cn;
assign clb[1] = `G0 | (`P0 & cn);
assign clb[2] = `G1 | (`P1 & `G0) | (`P1 & `P0 & cn);
assign clb[3] = `G2 | (`P2 & `G1) | (`P2 & `P1 & `G0) | (`P2 & `P1 & `P0 & cn);

// check if S >= 8 ( BCDBIN correction S-3)
assign sge8 = s[3];
assign sge5 = s[3] | (s[2] & s[1:0] != 2'b00);

// BCD correction (AM29203 only)
assign bcdbin[0] = 1'b1;
assign bcdbin[1] = s[0];
assign bcdbin[2] = ~(s[1] & s[0]);
assign bcdbin[3] = ~((s[2] | s[1]) & (s[2] | s[0]));

assign binbcd[0] = 1'b1;
assign binbcd[1] = ~s[0];
assign binbcd[2] = (s[1] | s[0]);
assign binbcd[3] = ((s[2] & s[1]) | (s[2] & s[0]));

// outgoing half adder
assign clx = (`M ? `ALL1 :
              `K ? clb : `ALL0) | 
              ((`BCDBIN & sge8) ? bcdbin :
               (`BINBCD & sge5) ? binbcd : `ALL0);
assign f = fx ^ clx;

// carry generate/propagate (bcdp/g are used for BCD addition only; BCD subtract is ordinary
// binary subtraction, and adjustment is necessary when c4 is 0
assign bcdg = `G3 | (`G0 & `G1 & `P2) | (`G0 & `G1) | (`P1 & `G2) | (`P3 & (`P1 | `P2 | `G0));
assign bcdp = (`P0 & `P3) | (`P0 & `G2) | (`P3 & `P0 & `G1);
assign bing = `G3 | (`P3 & `G2) | (`P3 & `P2 & `G1) | (`P3 & `P2 & `P1 & `G0);
assign binp = &p;
assign gg = ~(`BCDA ? bcdg : bing);
assign gp = ~(`BCDA ? bcdp : binp);

// carry out itself
assign bcdc4 = ~gg | (~gp & cn);
assign gcn4  = ~gg | (~gp & ~`J & cn);

assign cn3 = ~`BCDA & (`G2 | (`P2 & `G1) | (`P2 & `P1 & `G0) | (`P2 & `P1 & `P0 & cn));
assign cn4 = (`BCDA & bcdc4) | (~`BCDA & gcn4);

assign ovr = cn3 ^ cn4;

// sign
assign n = f[3];

endmodule
