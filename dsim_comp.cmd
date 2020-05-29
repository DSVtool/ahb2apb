#!/bin/bash

export UVM_HOME=/mux/platform/tools/dsim/20200316.8.1u/uvm-1.1d
export WORK_LOCAL=/home/dimitrijes/ahb2apb

dsim -linebuf -sv -work dsim_work -genimage image +acc+rwcb +incdir+${UVM_HOME}/src +incdir+${WORK_LOCAL}/design  ${UVM_HOME}/src/uvm_pkg.sv ${WORK_LOCAL}/bridge_macros.sv ${WORK_LOCAL}/design/*.v -f env_files.f ahb2apb_testbench.sv 
