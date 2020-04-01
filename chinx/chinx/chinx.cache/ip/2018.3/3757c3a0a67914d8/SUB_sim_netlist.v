// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:44:30 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ SUB_sim_netlist.v
// Design      : SUB
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "SUB,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
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

(* C_ADD_MODE = "1" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "0" *) 
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
