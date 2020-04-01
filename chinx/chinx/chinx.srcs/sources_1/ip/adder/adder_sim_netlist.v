// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:44:06 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top adder -prefix
//               adder_ ADD_sim_netlist.v
// Design      : ADD
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ADD,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module adder
   (A,
    B,
    S);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 s_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_intf, LAYERED_METADATA undef" *) output [31:0]S;

  wire [31:0]A;
  wire [31:0]B;
  wire [31:0]S;
  wire NLW_U0_C_OUT_UNCONNECTED;

  (* C_ADD_MODE = "0" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_CONSTANT = "0" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "00000000000000000000000000000000" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_C_IN = "0" *) 
  (* C_HAS_C_OUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_LATENCY = "0" *) 
  (* C_OUT_WIDTH = "32" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  adder_c_addsub_v12_0_12 U0
       (.A(A),
        .ADD(1'b1),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b1),
        .CLK(1'b0),
        .C_IN(1'b0),
        .C_OUT(NLW_U0_C_OUT_UNCONNECTED),
        .S(S),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADD_MODE = "0" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "0" *) 
(* C_A_WIDTH = "32" *) (* C_BORROW_LOW = "1" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_CONSTANT = "0" *) (* C_B_TYPE = "0" *) (* C_B_VALUE = "00000000000000000000000000000000" *) 
(* C_B_WIDTH = "32" *) (* C_CE_OVERRIDES_BYPASS = "1" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_C_OUT = "0" *) (* C_HAS_SCLR = "0" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "0" *) 
(* C_OUT_WIDTH = "32" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module adder_c_addsub_v12_0_12
   (A,
    B,
    CLK,
    ADD,
    C_IN,
    CE,
    BYPASS,
    SCLR,
    SSET,
    SINIT,
    C_OUT,
    S);
  input [31:0]A;
  input [31:0]B;
  input CLK;
  input ADD;
  input C_IN;
  input CE;
  input BYPASS;
  input SCLR;
  input SSET;
  input SINIT;
  output C_OUT;
  output [31:0]S;

  wire \<const0> ;
  wire [31:0]A;
  wire [31:0]B;
  wire [31:0]S;
  wire NLW_xst_addsub_C_OUT_UNCONNECTED;

  assign C_OUT = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_ADD_MODE = "0" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_CONSTANT = "0" *) 
  (* C_B_TYPE = "0" *) 
  (* C_B_VALUE = "00000000000000000000000000000000" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_C_IN = "0" *) 
  (* C_HAS_C_OUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_LATENCY = "0" *) 
  (* C_OUT_WIDTH = "32" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  adder_c_addsub_v12_0_12_viv xst_addsub
       (.A(A),
        .ADD(1'b0),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b0),
        .CLK(1'b0),
        .C_IN(1'b0),
        .C_OUT(NLW_xst_addsub_C_OUT_UNCONNECTED),
        .S(S),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
INaBf8vh5mCmDzf2yp77pxZAxQdyEQiT/vG2dEgvrFjseUnGc6ldwH4JvdnpZSpdf/ihioPyMNjl
u6ooyzv5TA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
S5XIZZtuFR/MZffuhwdnvE3H9oRWM4uXoaGZTa/Dyk62O+Wa0v41pjmZELCiR7uodZPFQfykZ6K9
2ZDMu8dB3afQRMs5lnd/53M1b9ke+MNEeZ/wzjUcsJghubnEAwzdWeW/0tlqST1WD9B/KCxYqwH5
Gj6IZTTFHAXcaVhnCT8=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CM6IcdzP0PbD6yMSqylmi4JE2qpmxiNeI+prjGwJiD8e3Xsynu3PbGKJAOpOxtR1hT/3mpBcx1Rz
Fkz0QBh4wtE8fiziv1i+xi8T6cqC8ClamjrpZ//sn6dh7NvwSYik14MlwVuei4DZoZJZF63aoPUn
RXkQ13wtK+MkYKBcPVSZMFZmaCU6jMMBYclXzvRG1JqqZoa7mWFTeFZePUTXG7Wo12QaZ8GUi0AV
UIshoN25yn5e2Xr3FyuEtm5AvsZb+iLsgLeHBtKBnsVaHQphicgqwgwv6MQQF6ZNBgU/aACfibDS
3+n/mMMm8k1cj2bW6VCi7a+c8LmCf81NlJuLww==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ehl0CusS7+JNGq6HfhyaBMy68nccIdIGqixoEztEZfkCpXuUYsdqw6G9MIJdWdu0Ck2acV7K6IVg
rzb8/bNaDDVWp48kupToegTkOdwDkCejEqppido4BkJ+iEkjPniz+aJHlOlOwmauETy2hCMuuC57
oWDprzGWlsqbCjqzKrXmPYm6fNdcOa2DiOYstQaMFNbPU2ccrbLJAiYMHNDqtPNqWxKBsD67kiGf
2eOneDOmdmy7YkNsL+cx8MJc3BVUsYBrpAEsGyFMkmX8a8nYz8R/wlFQFGQAd/t5XrfxFNI58mj1
AHXbcAMhGKVq9YdKeU/vSXY/NwMqp12xJ1nUaw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
h/qRAwiPuqY/Zg/QWqbaYm8xWTi9SshYuPzyL0UME9ZDDF+C2CyGAugh9HzMdD0kZmT94TKmBgLR
dKP28nlE8VCCU5rvbjKxfn/wNtNKHCvZ1hns8CF7+pGuelhxGvXNmYKFw5co8+4grYFaDXeoZZR6
S5sjvhqtSVD3+qq4vYWRjT2Y/yes7L9dRsLq2D3iZ4xjgVHuIbOQLT/EUKW+9iYudT9Uy6YTwB+5
mSb0QK3YfZdGwZyXB4S3mdF9vNQHdW/rnACq3yngF+lprNkh3ooQKdGqtxtz8KSQxNZOAFE+koOw
h00o7AKpvDAp3uNguLvnNJH3rugOhh95b8Jatw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
TsA04vIYHDZne2CBj5bWCBFH4MtNoFDCn/3DNEi0BwutuUf+X+lD9kAO3kl352WHjQbF79Ssm+PT
fCYpODgWdxSVbzaHFpITxCQ4HcIJhUeW5PC5tw09Tand68D6eg84qRguH+llbb5jdGJkJeTCf+Mx
pupkkLiDvNyTYWe+nqw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rx9hgQkvaJJTJJcTjGFW1DrrWiT+xanrcMvFn0Z3KRXlZvf+SE7IQgGCiP7ZDA6T5z1Zv5nzS4h5
cVi+CvwC9UMZRWmLDAjzASJ2nx1g9BjbYe2vHAUmyurIiR6LSigTeM/9TlMv+fFwJbqwuH6FJ3/z
Vl4tIMk4NrqkMn/riOG87SjhesepM6kcQOBgDGzLTG14z3qeZG8OPzxgApfyubmX4qdD1oTgGm2u
Q4mQfFxEye6Jqkn4Rzjhifs/ieNYomHlK7R2/72QJj5j0WyYBIhvO+09izz299Z54ZP2ZXaRMfDT
lU4lQNqQU14PX9Yk9p7sy2PnK4vTwwF0CFIgSQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NRjKySv8N4fGsu2vX/vF4zsNTKZYL9eTO9qr1TiFazNJ0ZlF0VaUpDIfpJKSOUo5VB427X3m21gO
Zpvj4cpnZypKWtMoH0zQ8gDPkVtVcAmbjL/NG/XMRMdC8ilzZLnDzpQDFaLuY9Rdu9aTIIisC5rQ
ery3ZbSuLxdu8WWLstoWMFF4dBlh+sSj9FAveFhqyntjnrNZQk4PZeGnl0OqFdzv9lYC1hGUIht1
RuakUW7UVz9dQiL1OY0T2CIKqqLGjkQGHI3kliCTPGmTIHfzWZ1/3f+AuqDbn63QncoqVAI/zEfK
MKIKz2ZEnIOn4zrGBDrLGONe6cxDc8bzwWwpaA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FoTzQ9Fa5zgPzBpUkjCXZKiem3HlaXI9HXQ3SppAieoXD5BsvMVGi1lo7LJtojqPXE6s5NLiteGl
pMuaohwYGtzTA5X6d5dx4MGciV1LBSTiavyU28lLtGOkCv33DaRtqWqJJxoGMqcuTcA3ieO6tQrq
jKO0QBLovCAzsdALHaDO6x4CUw3XaoZjsMyXQNAPD6WS4xqx8ZaMXs1HqOWqGUh1yiKPZ8OK37Eb
Q7kDSmok+iYXXAtcFwGymemD/N1v8xqhmjdhS9yBLWy+ZUl9rwYLo/8Xf75QEQSYMfvroqF2RRIq
eAhlcphSTCGb2Wj89NoWoxXqJXeyb/HGkcIJtA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 16352)
`pragma protect data_block
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
w37G8OOsOa47J7/3feHUsRwdNZx5gw==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
