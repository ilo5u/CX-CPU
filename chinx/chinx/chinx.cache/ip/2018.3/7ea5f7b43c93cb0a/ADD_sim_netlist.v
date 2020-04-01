// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:44:06 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ ADD_sim_netlist.v
// Design      : ADD
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ADD,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_12 U0
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
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_12
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_12_viv xst_addsub
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
