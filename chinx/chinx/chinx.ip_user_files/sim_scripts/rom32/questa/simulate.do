onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib rom32_opt

do {wave.do}

view wave
view structure
view signals

do {rom32.udo}

run -all

quit -force
