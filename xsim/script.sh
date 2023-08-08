echo "### SOURCING VIVADO ENV ###"
source /home/xadmin/Xilinx/Vitis/Vivado/2020.2/settings64.sh 
if [ $? -ne 0 ]; then
    echo "### SOURCING ENV FAILED, CHECK PATH IN SCRIPT ###"
    exit 10
fi

echo "### COMPILING SYSTEMVERILOG ###"
xvlog --sv src/elastic_buffer.sv src/tb_elastic_buffer.sv
if [ $? -ne 0 ]; then
    echo "### SYSTEMVERILOG COMPILATION FAILED ###"
    exit 10
fi

echo
echo "### ELABORATING ###"
xelab -incr --debug typical -top tb_elastic_buffer --snapshot elastic_snapshot
if [ $? -ne 0 ]; then
    echo "### ELABORATION FAILED ###"
    exit 12
fi

echo
echo "### RUNNING SIMULATION AND OPENING WAVEFORM###"
xsim elastic_snapshot -tclbatch xsim_cfg.tcl -view tb_elastic_buffer_behav.wcfg -gui
if [ $? -ne 0 ]; then
    echo "### SIMULATION FAILED TO RUN ###"
    exit 12
fi


