This is the verilog function model collection for the AMD am29xx bitslice devices.
You can find datasheets for all these devices at
	http://www.bitsavers.org/components/amd/Am2900/
and
	http://www.bitsavers.org/components/amd/_dataBooks/1983_AMD_Bipolar_Microprocessor_Logic_and_Interface.pdf	

The source files and test benches were written from scratch by and are thus copyrighted by Holger Veit (hveit01@web.de), and
underlie the GNU Public License V3. See the accompanying file gnu_public_license_v3.txt for details.

This collection was done in the hope that someone might find it useful.

Note these are *functional* models, i.e. they try to describe the functional behaviour of the corresponding chips as best as
possible, according to the textual descriptions in the databooks mentioned above.

They are NOT synthesis models - although some of them might be synthesizable - and they are NOT timing models (in that they describe
the exact timing of the corresponding circuits. But as they are single components they may be included in a component description
of a larger system.

How to use the models

You need an understanding of the Verilog Hardware description language - I do not explain what it is and how it works.

The directory layout is
--- here
     |
     +--- lib
     |     +---- model.v
     |     .....
     +--- libtest
     |     +---- model_test.v
     |     .....
     +--- README_1ST.txt
     +--- dotest.cmd
     +--- gnu_public_license_v3.txt

The lib directory contains the actual source code of the various circuit models. A few of them include some other model (usually the ROM
devices), but most of them are standalone.

The libtest directory contains testbenches for each circuit which will exercise all described circuit's functions.

The models were developed with Icarus Verilog which can be downloaded from http://iverilog.icarus.com/
Read the appropriate documentation on how to install and run it.

A single (DOS-style) command file is provided to try out the testbenches (dotest.cmd).
Enter the libtest directory and execute, from a CMD window,
  ..\dotest model_test
where "model" is some name of a model, e.g. "am2901"

The script will compile the test bench and run it. It will produce textual output of the tests executed (no "Error" line should occur), 
and will produce a model_test.vcd file which can be displayed in an appropriate waveform viewer. Icarus verilog comes with a viewer named gtkwave.

The Verilog version uses is plain 2005 standard - no Systemverilog extensions are needed. However, no effort has been spent to port the
sources to other development environments, but I am interested in your experiences.


Disclaimer

Note that GPL comes with certain restrictions to use the code commercially - my intent is to use them in education and hobby activities, not in
commercial systems. But if someone wants to do this - contact me.
Note also that although I have spent considerable work to find and correct bugs and deviations from the behaviour as described in the datasheets
there is no warranty at all that they behave exactly as the original hardware counterparts in all situations.


Have fun with it

Holger Veit, in December 2019
