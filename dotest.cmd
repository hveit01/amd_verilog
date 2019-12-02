@echo off
rem run this out of the libtest directory with the name of a test
rem e.g. 
rem cd libtest
rem ..\dotest am2901_test
rem
iverilog -I ../lib -o %1 %1.v
vvp %1
