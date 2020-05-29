#!/bin/bash
 
if [ -z $1 ]
then
   SEED=1
else
   SEED=$1
fi

export UVM_HOME=/mux/platform/tools/dsim/20200316.8.1u/uvm-1.1d

echo $SEED

dsim -linebuf -work dsim_work -image image +acc+b -sv_lib $UVM_HOME/src/dpi/libuvm_dpi.so +UVM_TESTNAME=ahb2apb_test -sv_seed $SEED
