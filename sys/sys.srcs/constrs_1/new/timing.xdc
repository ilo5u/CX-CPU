create_clock -period 10 -name sysclk [get_ports clk]
set_input_delay 2 -clock sysclk [get_ports clk]