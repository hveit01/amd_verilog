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

// am2925 clock generator
//
// Note: this is a circuit which generates several waveforms based on a crystal clock connected to two pins X1, X2.
// In this implementation, we assume the clock is fed into the circuit through a CLKIN input.
// This corresponds to the internally generated F0 clock, which is in pin 14 of the circuit.
// 

module am2925(clkin, l1, l2, l3, firstlast_, halt_, run_, ssnc, ssno, init_, waitreq_, ready_, cx,
              f0, c1, c2, c3, c4, waitack_);
input clkin;
input l1, l2, l3;
input firstlast_;
input halt_, run_, ssnc, ssno, init_;
input waitreq_, ready_, cx;
output f0;
output c1, c2, c3, c4;
output waitack_;

// C output patterns
`define FIRST   'b1110  // f3(1), f4(1), f5(1), f6(1),   f7(1),   f8(1),     f9(1),     f10(1)
`define LAST    'b0001  // f3(3), f4(4), f5(5), f6(6),   f7(7),   f8(8),     f9(9),     f10(10)
`define STATE2  'b1111  //        f4(2), f5(2), f6(2,3), f7(2,3), f8(2,3,4), f9(2,3,4), f10(2,3,4,5)
`define STATE3  'b1101  //               f5(3), f6(4),   f7(4,5), f8(5,6),   f9(5,6,7), f10(6,7,8)
`define STATE4  'b1001  // f3(2), f4(3), f5(4), f6(5),   f7(6),   f8(7),     f9(8),     f10(9)

// input codes
`define F3      'b000
`define F4      'b001
`define F5      'b101
`define F6      'b111
`define F7      'b011
`define F8      'b010
`define F9      'b110
`define F10     'b100

// halt, sst, wait flags
reg haltflg, sstflg, waitflg;

// latch for sampling L inputs
reg [2:0] elatch;

// finite state machine for clock generation
reg [3:0] fsmcnt;
reg firstcycle, lastcycle;
reg [3:0] creg; // for synchronizing c outputs

// set or reset haltflag, init
always @(halt_ or run_ or init_) begin
  if (init_ == 'b0 || run_ == 'b0)    // init overrides halt
    haltflg <= 'b0;
  else if (halt_ == 'b0)
    haltflg <= 'b1;
end

// set or reset singlestep flag
always @(ssnc or ssno or init_) begin
  if (init_=='b0)
    sstflg <= 'b0;
  else if (halt_=='b0) begin    // applies only when halt
    if (ssnc=='b1 && ssno=='b0)  // switch pushed: normally_closed=1 and normally_open=0
      sstflg <= 'b1;
  end
end

// set or reset the wait flag
always @(waitreq_ or ready_ or init_) begin
  if (init_=='b0 || ready_=='b0)
    waitflg <= 'b0;
  else if (waitreq_=='b0)
    waitflg <= 'b1;
end

// do wait acknowledge
assign waitack_ = ~(waitflg & ~cx);

// finite state machine for clock generation
always @(posedge(clkin) or init_) begin
  if (clkin=='b1) begin
//$display("waitreq=%b waitack=%b", waitreq_, waitack_);
    if (waitack_=='b1) begin
//      $display("my state is %d el=%3b", fsmcnt, elatch);
      firstcycle = 'b0;
      lastcycle  = 'b0;
      case (fsmcnt)
      1:  firstcycle = 'b1;
      2:  creg <= (elatch==`F3) ? `STATE4 : `STATE2;
      3:  case (elatch)
          `F3:           lastcycle = 'b1;
          `F4:           creg <= `STATE4;
          `F5:           creg <= `STATE3;
          default:       creg <= `STATE2;
          endcase
      4:  case (elatch)
          `F4:           lastcycle = 'b1;
          `F5:           creg <= `STATE4;
          `F6, `F7:      creg <= `STATE3;
          default:       creg <= `STATE2; 
          endcase
      5:  case (elatch)
          `F5:           lastcycle = 'b1;
          `F6:           creg <= `STATE4;
          `F7, `F8, `F9: creg <= `STATE3;
          default:       creg <= `STATE2;
          endcase
      6:  case (elatch)
          `F6:           lastcycle = 'b1;
          `F7:           creg <= `STATE4;
          default:       creg <= `STATE3;
          endcase
      7:  case (elatch)
          `F7:           lastcycle = 'b1;
          `F8:           creg <= `STATE4;
          default:       creg <= `STATE3;
          endcase
      8:  case (elatch)
          `F8:           lastcycle = 'b1;
          `F9:           creg <= `STATE4;
          default:       creg <= `STATE3;
          endcase
      9:  if (elatch==`F9)
                         lastcycle = 'b1;
          else
                         creg <= `STATE4;
      default:           lastcycle = 'b1;
      endcase
            
//      $display("fc=%b lc=%b", firstcycle, lastcycle);
        
            // do halt/sst logic when in first or last state
      if (firstcycle) begin
        if (~firstlast_ | ~haltflg | sstflg) begin
//          $display ("increment at firstcycle");
          fsmcnt <= fsmcnt + 1;
          sstflg <= 'b0;
        end
        creg <= `FIRST;
      end else if (lastcycle) begin
        if (firstlast_ | ~haltflg | sstflg) begin
//          $display ("increment at lastcycle");
          fsmcnt <= 1;
          sstflg <= 'b0;
        end
        creg <= `LAST;
        elatch <= { l3, l2, l1 };   // sample L inputs
      end else begin
//        $display ("increment");
        fsmcnt = fsmcnt + 1;
      end
    end
  end
//  $display("fsm=%d: creg=%4b", fsmcnt, creg);
end

// f0 master clock
assign f0 = clkin;

// c outputs
assign c1 = creg[3];
assign c2 = creg[2];
assign c3 = creg[1];
assign c4 = creg[0];

// we assume that the flipflops are in invalid state
initial begin
  fsmcnt <= 10;
  waitflg <= 'b1;
  haltflg <= 'b1;
end

endmodule
