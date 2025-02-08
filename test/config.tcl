set sig_list [list]

lappend sig_list "TOP.clk"
lappend sig_list "TOP.cpu.pc_inst.pc"

gtkwave::addSignalsFromList $sig_list

gtkwave::setZoomFactor -3
