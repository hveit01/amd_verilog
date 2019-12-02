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

// AM2932 program control unit
// Note this is almost the same as the AM2930,
// with the exceptions:
// - no EMPTY_ output
// - no G_, P_ outputs
// - no RE_ input
// - no IEN_ input
// - no CC_ input
// - simplified instruction set


`define PRST 'b0000
`define PSUS 'b0001
`define PSHD 'b0010
`define POPS 'b0011
`define FPC  'b0100
`define JMPD 'b0101
`define PSHP 'b0110
`define RTS  'b0111
`define FR   'b1000
`define FPR  'b1001
`define FPLR 'b1010
`define JMPR 'b1011
`define JPPR 'b1100
`define JSBR 'b1101
`define JSPR 'b1110
`define PLDR 'b1111

module am2932(i, d, cn, ci, oe_, cp, cn4, ci4, full_, y);
input [3:0] i;
input [3:0] d;
input cn, ci, oe_;
input cp;
output cn4, ci4;
output full_;
output [3:0] y;

reg [3:0] r;
reg [4:0] sp;
reg [3:0] stack[0:16];
reg [3:0] pc;

wire rce, oen;
wire push, pop;
wire [4:0] addout, incrout;
wire [3:0] rmux, amux, bmux, pcmux, stackmux;
wire empty_; // this is no external output

genvar n;

function frsel(input [3:0] i);
begin
  case (i)
  `FPLR:   frsel = 'b0; // PC via adder
  default: frsel = 'b1; // D input
  endcase
end
endfunction

function frce(input [3:0] i);
begin
  case (i)
  `FPLR:   frce = 'b1; // load PC
  `PLDR:   frce = 'b1; // load D
  default: frce = 'b0; // no load
  endcase
end
endfunction

function [3:0] famux(input [3:0] i, input [3:0] di, ri);
begin
    case (i)
    `FR,   `FPR,  `JMPR, 
    `JPPR, `JSBR, `JSPR:  famux = ri;
    `JMPD:                famux = di;
    default:              famux = 'b0000;
    endcase
//$display("famux=%b", famux);
end
endfunction

function [3:0] fbmux(input [3:0] i, input [3:0] ri, stki, pci);
begin
    case (i)
    `PRST, `FR,  `JMPR, 
    `JMPD, `JSBR:         fbmux = 'b0000;
    `POPS, `RTS:          fbmux = stki;
    default:              fbmux = pci;
    endcase
//$display("fbmux=%b", fbmux);
end
endfunction

function fcen(input [3:0] i, input cni);
begin
    case (i)
    `FPR, `JPPR,`JSPR:    fcen = cni;
    default:              fcen = 'b0;
    endcase
end
endfunction

function foen(input [3:0] i, input oe);
begin
    if (i==`PSUS || oe=='b1)
        foen = 'b1;
    else
        foen = 'b0;
end
endfunction

function fpcmux(input [3:0] i);
begin
    case (i)
    `PRST, `JMPD, `RTS,  `JMPR,
    `JPPR, `JSBR, `JSPR:        fpcmux = 'b1;
    default:                    fpcmux = 'b0;
    endcase
end
endfunction


function fpush(input [3:0] i);
begin
    case (i)
    `PSHP, `PSHD, `JSBR, 
    `JSPR:                fpush = 'b1;
    default:              fpush = 'b0;
    endcase
end
endfunction

function fpop(input [3:0] i);
begin
    fpop = ~i[3] & i[1] & i[0]; // `POPS or `RTS
end
endfunction

function fsmux(input [3:0] i);
begin
    fsmux = (i==`PSHD) ? 'b1 : 'b0;
end
endfunction

function [4:0] finc(input [4:0] i, input cii);
begin
    finc = (i==`PSUS) ? 5'b00000 : { 4'b0000, cii };
end
endfunction

// handle rmux
assign rmux = (frsel(i)) ? d : addout[3:0];
assign rce = frce(i);

// stack full/empty outputs
assign full_ = (sp != 'b10001) ? 'b1 : 'b0;
assign empty_= (sp != 'b00000) ? 'b1 : 'b0;

// amux and bmux
assign amux = { 1'b0, famux(i, d, r) };
assign bmux = { 1'b0, fbmux(i, r, stack[sp-1], pc) };

// adder
assign addout = amux + bmux + { 4'b0000, fcen(i, cn) };
//always @(addout) begin
//$display("time=%5d: amux=%b bmux=%b addout=%b", $time, amux, bmux, addout);
//end

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
        if (i==`PRST) begin 
            sp <= 'b00000;
        end
        if (push)
            stack[sp] <= stackmux;
//            $display("rce=%b incrout=%5b pcmux=%5b addout=%5b", rce, incrout, pcmux, addout);
        pc <= incrout[3:0];
    end
end

// end of cycle, adjust SP, if necessary
always @(negedge(cp)) begin
    if (cp == 'b0) begin
        if (push && full_)      // actually: not full
            sp <= sp + 1;
        else if (pop && empty_) // actually: not empty
            sp <= sp - 1;
    end
end

endmodule
