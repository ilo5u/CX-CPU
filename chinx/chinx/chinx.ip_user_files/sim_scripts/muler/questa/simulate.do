onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib muler_opt

do {wave.do}

view wave
view structure
view signals

do {muler.udo}

run -all

quit -force
