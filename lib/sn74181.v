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

// 74181 ALU

module sn74181 (a, b, s, m, cn_,
	f, cn4_, g, p, aeqb);
input [3:0] a, b;
input [3:0] s;
input m, cn_;
output [3:0] f;
output cn4_, g, p, aeqb;

wand aeqb;

genvar i;

wire m_;
not u00(m_, m);

wire [3:0] n1, n2, x1, n3;

for (i=0; i<4; i=i+1) begin:stage1
	wire b_, a0, a1, a2, a3, a4;
	not u10(b_,    b[i]);
	and u11(a0,    a[i]);
	and u12(a1,    b[i],s[0]);
	and u13(a2,         s[1],b_);
	and u14(a3,    b_,  s[2],a[i]);
	and u15(a4,    a[i],s[3],b[i]);
	nor u16(n1[i], a0,a1,a2);
	nor u17(n2[i], a3,a4);
	xor u20(x1[i], n1[i], n2[i]);
	xor u40(f[i],  n3[i], x1[i]);
end

wire a311,a312;
and  u311(a311, m_,n1[0]);
and  u312(a312, m_,n2[0],cn_);

wire a321,a322,a323;
and  u321(a321, m_,n1[1]);
and  u322(a322, m_,n1[0],n2[1]);
and  u323(a323, m_,      n2[1],n2[0],cn_);

wire a331,a332,a333,a334;
and  u331(a331, m_,n1[2]);
and  u332(a332, m_,n1[1],n2[2]);
and  u333(a333, m_,n1[0],n2[2],n2[1]);
and  u334(a334, m_,      n2[2],n2[1],n2[0],cn_);

nand u305(n3[0], m_, cn_);
nor  u315(n3[1], a311,a312);
nor  u325(n3[2], a321,a322,a323);
nor  u335(n3[3], a331,a332,a333,a334);

wire n342;
nand u341(p,        n2[0],n2[1],n2[2],n2[3]);
nand u342(n342, cn_,n2[0],n2[1],n2[2],n2[3]);

wire a351,a352,a353,n354;
and  u351(a351, n1[0],n2[1],n2[2],n2[3]);
and  u352(a352, n1[1],n2[2],n2[3]);
and  u353(a353, n1[2],n2[3]);
and  u354(a354, n1[3]);
nor  u355(g, a351, a352, a353, a354);

nand u401(cn4_, n342,g);
and  u402(aeqb, f[0], f[1], f[2], f[3]);

endmodule
