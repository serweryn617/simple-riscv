# Cooking recipe, checkout Cook at https://github.com/serweryn617/cook

from cook.build import RemoteBuildServer
from cook.sync import SyncDirectory, SyncFile


path_prefix = "source/"
files = [
    'alu.sv',
    'control.sv',
    'cpu.sv',
    'led_driver.sv',
    'memory_controller.sv',
    'memory.sv',
    'register_file.sv',
    'register_pc.sv',
    'register.sv',
    'rom.sv',
    'sign_extender.sv',
]

fpga_machine = RemoteBuildServer(name='fpga_machine', build_path='~/simple-riscv')

default_build_server = 'local'
default_project = 'build_and_run'

build_servers = [
    'local',
]

projects = {}

projects['clean_build'] = {
    'components': [
        'clean',
        'build',
    ],
}

projects['clean'] = (
    'rm -r obj_dir',
    'rm waveform.vcd',
)

projects['build_and_run'] = (
    f'verilator -Wall --trace --x-assign unique --x-initial unique --cc {' '.join(path_prefix + file for file in files)} --top-module cpu --exe test/cpu_test.cpp',
    'make -C obj_dir -f Vcpu.mk Vcpu',
    './obj_dir/Vcpu +verilator+rand+reset+2',
    'gtkwave --script test/config.tcl waveform.vcd',
)


projects['lint'] = (
    'verilator --lint-only -Isource cpu.sv',
)


projects['sync'] = {
    'build_servers': [
        fpga_machine,
    ],

    'send': [
        SyncDirectory('source'),
    ],
}
