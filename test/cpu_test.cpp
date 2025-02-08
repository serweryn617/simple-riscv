#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu.h"
#include <cstdlib>

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
        // dut_reset(dut, sim_time);

        dut->clk ^= 1;
        dut->eval();

        // if (dut->clk == 1){
        //     dut->in_valid = 0;
        //     posedge_cnt++;
        //     switch (posedge_cnt){
        //         case 10:
        //             dut->in_valid = 1;
        //             dut->a_in = 5;
        //             dut->b_in = 3;
        //             dut->op_in = Vcpu___024unit::operation_t::add;
        //             break;
        //         case 12:
        //             if (dut->out != 8)
        //                 std::cout << "Addition failed @ " << sim_time << std::endl;
        //             break;
        //         case 20:
        //             dut->in_valid = 1;
        //             dut->a_in = 5;
        //             dut->b_in = 3;
        //             dut->op_in = Vcpu___024unit::operation_t::sub;
        //             break;
        //         case 22:
        //             if (dut->out != 2)
        //                 std::cout << "Subtraction failed @ " << sim_time << std::endl;
        //             break;
        //     }
        //     check_out_valid(dut, sim_time);
        // }

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

