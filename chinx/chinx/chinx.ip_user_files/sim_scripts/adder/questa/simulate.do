onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib adder_opt

do {wave.do}

view wave
view structure
view signals

do {adder.udo}

run -all

quit -force
