# Cooking recipe, checkout Cook at https://github.com/serweryn617/cook


path_prefix = "../"
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
]


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
    f'verilator -Wall --trace --x-assign unique --x-initial unique --cc {' '.join(path_prefix + file for file in files)} --top-module cpu --exe cpu_test.cpp',
    'make -C obj_dir -f Vcpu.mk Vcpu',
    './obj_dir/Vcpu +verilator+rand+reset+2',
    'gtkwave waveform.vcd',
)


projects['lint'] = (
    'verilator --lint-only cpu.sv',
)