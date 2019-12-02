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

// AM2930 program control unit

`define PRST 'b00000
`define FPC  'b00001
`define FR   'b00010        
`define FD   'b00011
`define FRD  'b00100
`define FPD  'b00101
`define FPR  'b00110
`define FSD  'b00111
`define FPLR 'b01000
`define FRDR 'b01001
`define PLDR 'b01010
`define PSHP 'b01011
`define PSHD 'b01100
`define POPS 'b01101
`define POPP 'b01110
`define PHLD 'b01111
`define JMPR 'b10000
`define JMPD 'b10001
`define JMPZ 'b10010
`define JPRD 'b10011
`define JPPD 'b10100
`define JPPR 'b10101
`define JSBR 'b10110
`define JSBD 'b10111
`define JSBZ 'b11000
`define JSRD 'b11001
`define JSPD 'b11010
`define JSPR 'b11011
`define RTS  'b11100
`define RTSD 'b11101
`define CHLD 'b11110
`define PSUS 'b11111

module am2930(i, ien_, cc_, d, re_, cn, ci, oe_, cp, p_, g_, cn4, ci4, full_, empty_, y);
input [4:0] i;
input ien_, cc_;
input [3:0] d;
input re_, cn, ci, oe_;
input cp;
output p_, g_, cn4, ci4;
output full_, empty_;
output [3:0] y;

reg [3:0] r;
reg [4:0] sp;
reg [3:0] stack[0:16];
reg [3:0] pc;

wire rce, oen;
wire push, pop;
wire [4:0] addout, incrout;
wire [3:0] rmux, amux, bmux, pcmux, stackmux;
wire [3:0] g, p;

genvar n;

function frsel(input [4:0] i, input rei);
begin
  if (rei=='b0)
    frsel = 'b1; // select d
  else 
    case (i)
    `FPLR:   frsel = 'b0; // PC via adder
    `FRDR:   frsel = 'b0; // R+D+Cn
    default: frsel = 'b1; // D input
    endcase
end
endfunction

function frce(input [4:0] i);
begin
  case (i)
  `FPLR:   frce = 'b1; // load PC
  `FRDR:   frce = 'b1; // load R+D+Cn
  `PLDR:   frce = 'b1; // load D
  default: frce = 'b0; // no load
  endcase
end
endfunction

function [3:0] famux(input [4:0] i, input [3:0] di, ri);
begin
    case (i)
    `FR,   `FPR,  `JMPR, `JPPR, 
    `JSBR, `JSPR:               famux = ri;
    `FD,   `FRD,  `FPD,  `FSD,
    `FRDR, `JMPD, `JPRD, `JPPD,
    `JSBD, `JSRD, `JSPD, `RTSD: famux = di;
    default:                    famux = 'b0000;
    endcase
//$display("famux=%b", famux);
end
endfunction

function [3:0] fbmux(input [4:0] i, input [3:0] ri, stki, pci);
begin
    case (i)
    `PRST, `FR,   `FD,   `JMPR, 
    `JMPD, `JMPZ, `JSBR, `JSBD,
    `JSBZ:                      fbmux = 'b0000;
    `FRD,  `FRDR, `JPRD, `JSRD: fbmux = ri;
    `FSD,  `POPS, `RTS,  `RTSD: fbmux = stki; 
    default:                    fbmux = pci;
    endcase
//$display("fbmux=%b", fbmux);
end
endfunction

function fcen(input [4:0] i, input cni);
begin
    case (i)
    `FRD,  `FPD,  `FPR,  `FSD,
    `FRDR, `JPRD, `JPPD, `JPPR,
    `JSRD, `JSPD, `JSPR, `RTSD: fcen = cni;
    default:                    fcen = 'b0;
    endcase
end
endfunction

function foen(input [4:0] i, input oe);
begin
    if (i==`PSUS || oe=='b1)
        foen = 'b1;
    else
        foen = 'b0;
end
endfunction

function fpcmux(input [4:0] i);
begin
    if (i==`PRST || i[4] == 'b1)
        fpcmux = 'b1;
    else
        fpcmux = 'b0;
end
endfunction


function fpush(input [4:0] i);
begin
    case (i)
    `PSHP, `PSHD, `JSBR, `JSBD, 
    `JSBZ, `JSRD, `JSPD, `JSPR: fpush = 'b1;
    default:                    fpush = 'b0;
    endcase
end
endfunction

function fpop(input [4:0] i);
begin
    case (i)
    `POPS, `POPP, `RTS,  `RTSD: fpop = 'b1;
    default:                    fpop = 'b0;
    endcase
end
endfunction

function fsmux(input [4:0] i);
begin
    if (i==`PSHD)
        fsmux = 'b1;
    else
        fsmux = 'b0;
end
endfunction

function [4:0] finc(input [4:0] i, input cii);
begin
    case (i)
    `PHLD, `CHLD, `PSUS: finc = 5'b00000;
    default:             finc = { 4'b0000, cii };
    endcase
end
endfunction

// handle rmux
assign rmux = (frsel(i, re_)) ? d : addout[3:0];
assign rce = frce(i) | ~re_;

// stack full/empty outputs
assign full_ = (sp != 'b10001) ? 'b1 : 'b0;
assign empty_= (sp != 'b00000) ? 'b1 : 'b0;

// amux and bmux
assign amux = { 1'b0, (i[4]=='b0 || cc_=='b0) ? famux(i, d, r) : pc };
assign bmux = { 1'b0, (i[4]=='b0 || cc_=='b0) ? fbmux(i, r, stack[sp], pc) : 4'b0000 };

// adder
assign addout = amux + bmux + { 4'b0000, fcen(i, cn) };
//always @(addout) begin
//$display("time=%5d: amux=%b bmux=%b addout=%b", $time, amux, bmux, addout);
//end

for (n=0; n<4; n=n+1) begin:adder
   and gx(g[n], amux[n], bmux[n]);
   or  px(p[n], amux[n], bmux[n]);
end

assign g_ = ~(g[3] + (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]));
assign p_ = ~(& p);
assign cn4 = addout[4];

// output
assign y = (foen(i, oe_)) ? 4'bZZZZ : addout[3:0];

// stack push/pop, stackmux
assign push = fpush(i);
assign pop  = fpop(i);
assign stackmux = fsmux(i) ? d : pc;

// pcmux, incrementer
assign pcmux = (fpcmux(i)) ? addout[3:0] : pc;
assign incrout = { 1'b0, pcmux } + finc(i, ci);
assign ci4 = incrout[4];

// handle registers
always @(posedge(cp)) begin
    if (cp == 'b1) begin
        if (rce)
            r <= rmux;
        if (ien_ == 'b0) begin
            if (i==`PRST) begin 
                sp <= 'b00000;
            end
            if (push)
                stack[sp+1] <= stackmux;
//            $display("rce=%b incrout=%5b pcmux=%5b addout=%5b", rce, incrout, pcmux, addout);
            pc <= incrout[3:0];
        end
    end
end

// end of cycle, adjust SP, if necessary
always @(negedge(cp)) begin
    if (cp == 'b0) begin
        if (push && full_)              // actually: not full
            sp <= sp + 1;
        else if (pop && empty_) // actually: not empty
            sp <= sp - 1;
    end
end

endmodule
