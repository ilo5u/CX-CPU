// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:44:30 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top suber -prefix
//               suber_ SUB_sim_netlist.v
// Design      : SUB
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "SUB,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module suber
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

  (* C_ADD_MODE = "1" *) 
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
  suber_c_addsub_v12_0_12 U0
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

(* C_ADD_MODE = "1" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "0" *) 
(* C_A_WIDTH = "32" *) (* C_BORROW_LOW = "1" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_CONSTANT = "0" *) (* C_B_TYPE = "0" *) (* C_B_VALUE = "00000000000000000000000000000000" *) 
(* C_B_WIDTH = "32" *) (* C_CE_OVERRIDES_BYPASS = "1" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_C_OUT = "0" *) (* C_HAS_SCLR = "0" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "0" *) 
(* C_OUT_WIDTH = "32" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module suber_c_addsub_v12_0_12
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
  (* C_ADD_MODE = "1" *) 
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
  suber_c_addsub_v12_0_12_viv xst_addsub
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
dPuDrPw488+N5S2bflNhqOde1Z47/f8LvbrWIWpH+XfTUyUwL8dH6zBtRajxm8Akqygz0aY8+LDT
gjkllBofOIJnroZ3RiMJjAVldV80k+aSZDoK3rlwdNMUv1RrIvjbENNxS6n9IL3/2gwijqiVj7gA
LNGCwHaxVTzAI+ynELTR1j+jWYZGSFlT3odO49qd1z89tsW9Lr6XCdiYGN5EmOv6O/hY1msuGwX7
yN9545wUapGiwxF7hD3Y3iSVMCUOGBybV3qheLaHsjkgSiD9MYQ19OCcRYWYm/oKcPzAhDNTbitk
UEHWTagYDk/FSqOzXlFcBVEXpfFcHGqcll5qJA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cvOZfQVW+ryAXGLNHoKyIV+Eav/UXhh7PSdSDDOvsLt5HeC9uVJsHrhyjt1ui+jq5G3HWYf1Mzjj
/coId7GOdBTMZCfb/9H5gMrTouts4nduNnWlyrg62fh8EhyC0zcbRou7XNFrN7RPuZSizmj1bPmd
XRpGAFvCS1l312EaTXvooNBxR+WOowHym/l69x3dp31fQMWsK35BUc3G7+jsROZ6dMaSqKhrPDWs
WlrZUuTKvwJTuN+06etey1MSahDCr+H3lhEb1J39/kP6dKcF3sXaC5J6YyWxXcspuKFIep2MAG+k
Sylqf4WeDtG0/mU0rp38WO5OpN5HFAjpvUJq3Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 16352)
`pragma protect data_block
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
wqk26T7TU1t3Hfv7WaWhp8IKDTasyQ==
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
