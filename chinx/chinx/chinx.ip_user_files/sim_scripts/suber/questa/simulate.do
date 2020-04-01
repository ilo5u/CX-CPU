onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib suber_opt

do {wave.do}

view wave
view structure
view signals

do {suber.udo}

run -all

quit -force
