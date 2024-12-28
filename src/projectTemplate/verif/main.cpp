#include "VTB.h"           // Include Verilated module
#include "verilated.h"         // Include Verilator utilities
#include "verilated_vcd_c.h"   // Include VCD tracing (optional)
#include "VTB___024root.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    // Instantiate the Verilated tesTBench
    VTB *TB = new VTB;

    // Initialize VCD tracing
    VerilatedVcdC *tfp = nullptr;
    Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        TB->trace(tfp, 99);  // Trace up to 99 levels of hierarchy
        tfp->open("waveform.vcd");  // Specify VCD file
    

    // Simulation time variables
    vluint64_t time = 0;
    const vluint64_t max_time = 2000;

    // Main simulation loop
    while (!Verilated::gotFinish() && time < max_time) {
        TB->eval();                   // Evaluate the design
        if (tfp) tfp->dump(time);     // Dump waveform at the current time
        Verilated::timeInc(1);        // Advance simulation time
        time++;
    }

    // Finalize VCD dumping
    if (tfp) {
        tfp->close();
        delete tfp;
    }

    delete TB;
    return 0;
}
