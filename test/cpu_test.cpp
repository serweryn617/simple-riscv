#include <cstdlib>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu.h"


#define MAX_SIM_TIME 300
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;


int main(int argc, char** argv, char** env) {
    srand(time(NULL));

    Verilated::commandArgs(argc, argv);
    Vcpu *dut = new Vcpu;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
