// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:43:47 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/livew/Desktop/CX/chinx/chinx/chinx.srcs/sources_1/ip/add1/add1_sim_netlist.v
// Design      : add1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "add1,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module add1
   (A,
    S);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [7:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 s_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_intf, LAYERED_METADATA undef" *) output [7:0]S;

  wire [7:0]A;
  wire [7:0]S;
  wire NLW_U0_C_OUT_UNCONNECTED;

  (* C_ADD_MODE = "0" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "8" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_CONSTANT = "1" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "00000001" *) 
  (* C_B_WIDTH = "8" *) 
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
  (* C_OUT_WIDTH = "8" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  add1_c_addsub_v12_0_12 U0
       (.A(A),
        .ADD(1'b1),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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

(* C_ADD_MODE = "0" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "1" *) 
(* C_A_WIDTH = "8" *) (* C_BORROW_LOW = "1" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_CONSTANT = "1" *) (* C_B_TYPE = "1" *) (* C_B_VALUE = "00000001" *) 
(* C_B_WIDTH = "8" *) (* C_CE_OVERRIDES_BYPASS = "1" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_C_OUT = "0" *) (* C_HAS_SCLR = "0" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "0" *) 
(* C_OUT_WIDTH = "8" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* ORIG_REF_NAME = "c_addsub_v12_0_12" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module add1_c_addsub_v12_0_12
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
  input [7:0]A;
  input [7:0]B;
  input CLK;
  input ADD;
  input C_IN;
  input CE;
  input BYPASS;
  input SCLR;
  input SSET;
  input SINIT;
  output C_OUT;
  output [7:0]S;

  wire \<const0> ;
  wire [7:0]A;
  wire [7:0]S;
  wire NLW_xst_addsub_C_OUT_UNCONNECTED;

  assign C_OUT = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_ADD_MODE = "0" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "8" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_CONSTANT = "1" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "00000001" *) 
  (* C_B_WIDTH = "8" *) 
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
  (* C_OUT_WIDTH = "8" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  add1_c_addsub_v12_0_12_viv xst_addsub
       (.A(A),
        .ADD(1'b0),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
Dj7p8ulMcuLu0UqZ8CehdrEblljk+iZvdXd/d2dePQ3vDd4tr8z8l83t+tzS6v36aly1h/7NVaDx
vZuuPvhqKajDe7RHYxXAgu+AcK6dFmjGEnT9XEA1WGcyrsJIMrOJ+UB/2+OeIQn9BMvsGAvW5czL
jbY46TK1dEJo37mF+RE5+BaKKgJj4zchBCTdZJa6ObulvE75EwgZgBL3mGtHvZlHz/+5DCaMDUtP
DGAItk/wobII/hdIoUJnVg/l3dpb8jX6kA8ZWZVTGBdzvPZH5QDddZQxy07ZYuWKgKtoReq95ljh
xiyczWokTV0s2o68YXXFPpr3udfVVGZ1tsqgzg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
d0a0V4oI1k63ZW18Y0H9+mGSU8GxeKB3AlgI6PtCToqaZoiQdtRdkrtei/oej6uPp33edgT00QNm
V9+SvJYrPLSyPpNvhJZfStkV88jxE7WJJAXAZH6k4y0ozi9RS1KB+7ZTSZMvAkO2Umy5ooKmIBMS
qqbJvpyVSpbxC14UN4QmTknln5GZkWQFULXrG5X2pDNqBSjvyPVc5izG+py9xvRRs/6Wgjo/hB+8
JuEHK+Ot1r3VDnFx4CZS02TKD6vf0DnOcgLxUnam6nLaFZ30UoR9eOT83qW649Yl8XCY2U1pcpnT
rSMF6OipvlSkTaNXJpiCsTeideIA/MO06d3SJg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 3424)
`pragma protect data_block
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
OaQ01g==
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
