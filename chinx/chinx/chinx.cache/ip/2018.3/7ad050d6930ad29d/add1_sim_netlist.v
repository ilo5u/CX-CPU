// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Apr  1 10:43:45 2020
// Host        : DESKTOP-2E57V9P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ add1_sim_netlist.v
// Design      : add1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "add1,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_12 U0
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_12_viv xst_addsub
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
q+wyW2OYWjBKMCHnYOyyf5MhrmtJuBA3GV18mTUTAHvy/7OHrCYIK3DkUPlIV457isMyeoq/2uK9
lrMdwPAsjK5H7SIjT8bGeiMAWe50aFE8A80o+Hbc7kSQQIuG6ISerE4F7vkjXcTQt2pA9eqX/u2j
KMt1nWziaSiYUtB2Tw3xNspd+HsfOZgYM4oPLq1bgvCvgEtHoyRgPI/r36mlzvDpASTZurvgJO90
uIcDlJQUX5uFbkePf71YOIEJZjf0YuWHnvLiQQoEXb+36APYksaEQwtI7W5WNwFWcktjyi/JOaRk
slbEwH317PymFNtrg/sbi/if2kztn1YyIJsTUA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L2RW/BqgMMn3cU2Vnv9cUn/KtpXVcTEkM9q+1R3k+p8KcmfI9dLzH+HSH1fVawaroY5BuPJ+KSUD
vXn5UWOuzhp4LpFNCckDZt0LLciPEa4RfC7ysT0r0o5QSGG4XiBtwDi2Lks0sdLxgUZojXnRCG4h
HzaalRhWr/laItFjaF47qfD1Bl+ih7QbulsfLzezliFcfKppFZX0BfcXEDKEDXGAAdcPZYr5OUGn
iTRHXGoUFuS+o3T27Xs2MX/NbXqxjZGAFNfPIHcGxqAk1PfiJqNGiXBnIwUSGmbepa7dHVLhMy+2
REdgILBQQ0v3+pILN3qIjx/aa5ecNsTKonw2Tw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 3488)
`pragma protect data_block
4ONsY215a3KONCOXi/aSf/yLOdUEAW4vGwIY0VJ5yrJHoJVaIjaGwBo9b6bfXMLJIEu1d3fX+ao3
228PDYBE77UmrWsMq/PXAvYjFI4YnnDqhK50xcnEsBpVOyeeFEbOyae7fiiOzN9aRADuzh74DiOu
q3KwXbUJwNTzJnBZFs8h/gCCr9voqDYsCginuPNSbxWUHukI3GHyonvOk4g0wjfuWd4LLVcBAJjC
jo1nAFZS90AtccG4+mXSdqFQrbdo6Wsq9ZzB2BUy1S0qMr3cWirQk4iA4yvz+1sbD+oaH7YAki2z
pOQsqZx+r9NshxGMm8XbIHYK+HcdpQY95tTY7wHvASQ2aFM27pFOHmt1+KGkkRSudWYHDZu+kgOg
vUQ0vbLH70Pd58SLqjPkAatN47nTKuVHVWpo+783uRUb+sNTCVnk9BJbBl3q5uv4Sf+jOitF8/+A
24ZAlKQWmtkPiqGDZTk29AtlSM/3tiVu4py2D3wa/N6k2yyR0fchBy8Q3pNTIdqsiaRKwjA1ePyH
aEcaUSSid56uqQKKlV63mmuEHuQUdMxk3wocHA6PYfhbl4xKdpBxGcCPdx2ZQGypVbn2QSrh0qZ0
eJ1jMicbWZPgNgyzwjeN7n78TJGGnJgSxiQueyNr1BsVI5Jn1i4pjhmtfVGl0kH4VVw0z89PGvUc
2relYuZBoyxeBeAPUDe7Z8y/eoaEFcHU7kzRLSwByaAOgc1hNccp4rbg/iE3Nr9xocJ3lXACPo5d
hY/zO+j81FDhQmj6Ryc1tgW2u34K9gY1/pCC2EeVV95ZnO/8ziDtEFoze+zndbPo6tSMg9oSCv0o
G0HzXc7Atgxa0CSS58e5iVNPDDJt9yHveXqUzgROzVPMW/6S9k4fyqWvZSmC5f19z1KoQiwLCTDm
5frlF0o6dP5QQWxfiuJJJlB43Gw4kB0r7VVTiQUZmODQXbld0xlnd+GlHkpN0yy5Key9jDpRk7ro
mkO4f1t/MCd6Slzcc4UmHQrdwlCko8kciyk++O44UPptq3/87Cp/M2Afm+MCQtvj27Oe3rr+msvY
e3oF33sSb4bZFNfwVGV1e3yRdRnlvuWDCqLJQhrGYnyfiTUGUzq9uam2iXoNPE9+0SGSSBsSGsP2
ODhAwutrJi56nKNVjmv3GnB8kk0+EGDAWcw1JKQGzhPc2Unik0g+KFDBJc+/dOWkgXA0BXsvmIv2
t1TS8rv128DJ1GlCZDkroWEn5gzC1f1VaztINkSXDV62mcOsIocvX6DjOXKmpUegb8+/cyFRzDkm
Gd8oamIHT8SxvC8DzRRpOcL9PHmFWkhRt4eNuFVkfl/Lwsdr+JBmx7STfNZS0AkX8dYqen3H2wvd
HbD1eoU8VVau3UxfmPi0DNvVhYAYdJ0llECNSNHJSamBoDfhUEzusR9WXiaEM+hNmd95Q1WGLGzQ
7oqx7PHceLAXLHnopHHb4GR9CXofuNRTD6Z91vERWV1IvD93d1aY5wYMxnVfzPc/u5pPD779wUZV
6cVTwUxriZOxHEL6uYJT5Bl994NOIuC+6kgoxkG9cMvhJJXRGfmUvqGaf2r7OHH6h4KDz2jCfkc5
/yHeZ4DqikyCXeqtRpK5eDPkcn8v2veDkUGpgxz38hELUGVrj0rmyTFtiT+9WrCANaCfWYZzKMH7
8H5z0uFgr4tCUbKyjx5/lcVsLMTgepIVNWMcUwp0E3uwCWCBhRXnDPHDTsnSn8xN05hd6ngcql1j
18Jumnz8hjrCHMFoY5z5w99MQMPsStbqxoexGI+UPy5EQLzqsX7I+47xbKyU8MJgYJGrOc41Feky
wlcpdH9uUcvwFK39Kfcu7Zz7PVfOVOnkYcc3C2eDJrF4sOOl3l8p7O6b/qBITmnkY+wynTNvvcp2
5UTDNivTw4u3+65OcJJbeDr6c0qt612uSUeLqRQkW8Hu/lbeYhlu/gwyBkdOrgsHKDtHOCYLvGGN
BcX2wHXG+Y7AC4ikaaYYn67HzbxH9Fo0RXIFx/Ii7SNELOZ7rgnqaXTg6wdze55GOnEC4soeXlov
beN/cdZhKjTf4AoR1Gn1Tv5j8f6EXJVnSLGnNgHrUXetBUudvavZBYNNyl8KzGQ0h3TCMZbafzgd
GDYh1vs7vFCi+th8e6jW7z73JMP6y4DsSWVbvCwTVZrnvVWVxt8u04H7K6ooJfMjU0/hY7TBUUVc
B1hqGi6icAmDkNwXU8gPTBQPh1xG4TjMKEucU8SDRnAmKFxYVTCbkKgsgJyfbPrqE7cwoAIhMR3r
p3z7w0IkDrzeR4iqPpsYlyliAxw1bGhK2LmNRCOBUqWG49YDgGxEs0tMKVB9pwLtBYYMmJlj4HbO
d70yM3C4OfpSzGScsnuKpiBKBs1Kjc4SBSzYHzJpURj1HiJjiBFULtxjX44gtrtgZTGMFWKNbs4J
+o9NaFLAq402FH82EAibSIkkyI7eIVvUpF6uog90UC2d08r2ZrUwkDs7g28Lo1pm4yhgM6MEFbZq
ipu+MN7Nzk5o0mm4vt1D2nXC/jRHdTCVEX0wSWBZ0ZSfljdKj8Hvv6ty4LHNvSWZeQAEqVRNP6SB
eDvAPDYJFLB5ULvdOc5EGOmRDxBuADdm7uaah49IqmsGWeq6XihHZ4MRrna7h+o/T/c26fv/raix
Zo28xCvzOP3o3kFKfmclkw0hhLRkL8M4tU6RjSAjcrZnPh6TZrlXWmssWn/AgB5+8FLUOLh36RFl
1RXMqqvPmF43AD8nLf2uTu8PiKVcUtg7I4yc0d2lUEMo7IHswwXoKhtuE2z1xgwlPWVmG8VDk8YU
Pd+5OgyKPUhQgMqv/+1EpC9n+S2nZDtlZJLjPpQMdKTlgzuEVJhfm2b73zb5EogGuLjNIW+bpJ1v
7txlmy/+MM1XzVLEndqdQes72VOdI4nLHcC3ZHUuV6Ey/hDAOcnzGkQoBvnzrGJ0vR8wD28N/KZ1
sB/LnDqtyDFRqDeSHXtBfFvMpNyfn2lb8WpfkQ5jPHkfMaIljTX3ZwVnR2qm47VsX8XvoDp0mV0S
BDzMoaFLPVFjIbRtBhEkLk7VnTn2V79FUgOtfiRnDf5UIAkaIZNTnJVDtzsDMN/NkllbX9mkfmKC
vsPw2Ldl4QL6/sOFq02mJaM6m1y0rsS8oe1SN87Sk1fR1KPLQWH7RmXlBlRLxFWOQ5P69Or5Pq8p
GJ2jvqLsfxrT4JA3zJyA8YgGJzoQZ5vli3n3qXfGLnjvDZQUo9PQlJf/fris/0SgXoimFwfyDDD+
JkpQmsW5mie0HN19DTePWdQ89Er9CnByhhzWsKO3AD4CkonMZ/zoDEpoW9H+WgZD547sk9eRTmLK
d4cNz/fxS9R7ouLr9V5fuct78XDoyWkPf+iZYQx8nQcoYFJoTgIx2zmJhy3lVqXkKEwJupTFIPPW
N9rSyBfZOMHFXFIKnxP+sASuu5b8Uvgw/z9P7bJSW0w5XyVfQuTamP3a7K52tUkdh8GFKMTDG5i5
TQvllBo74DL8mwLkqsDkF+wCQctloOMxSnHkYEPo0MNdDHGQcBLlDwV3IsBb8wK6uSb8K4LI9eWd
uOHoLF85Ri1fsa7bD8Trzmah8byjpTh3buFheA2saI0RoThSA7Ql2/KTwiK1QI0JTJoIn3DGZjQn
tCei7cSw66bJdwlwEW3aLAd+DBFuWd/eEFPIzl5R1UsuOwKqizFHwngWZgu68v4GcOD5zaRwVTBH
Wy61MhiuahOYKe5mJ6sEkb51+7x3YMQsoFz7bsuG6n1DIQFMTmnPxwoU1J5CUkJG+lF9OEoJFLfh
7bA54q4cGdfQ/cFCpmQMmPgfq1Cx1/fk2mzzsmvMDNiDG4hzBDnouJsTDJd36pM0+aNRC4CI5jJU
NiIRqozRS7X6Ao0EVmBlR+D6DmYojXPs2Cy8ovslr/i6h+7pzlQ7xmcLs+vjWWKqHLdQey1M1kqB
QITR8tkCKMtk4yO+PmqDrvpnj75GsoTiFSHcs0CxCM1ALtYrQSQPmTLVyTuqyocDvhJkCyM273QB
CzdHbSmF91PN53NWmXKObNNWdRmoFAktl3WOlhEUyK8fIK6SWWScVA3alxpxwtbQt44v3lJ3zrwg
fwh71fLkoCQwNFPdNiIqlaLbhZLS+wy6nJqnWEReZ52wGtAy7Elhz2+uJf0qvFMt5dXzyffP9pVZ
+9L70V+KVKbsVrKbdR55hgkS5oFWJKtBsNUUPASTeaeaEU+v6LZtz/CII6r/Q5HJ1l2HVM4Rc16s
Klc/Lhpk4iGtxrs2fiTCqW0ruZIJg+Vw+lKwVUPTJNe6xBqIAzPgk7NQCN1d07qv24tlPBFMtekz
EGZQTGGgUUAM4oYg+fSHCQEp+FupMjr7T6KbU2OBc9vH8Cct3F3MVl+hX00KFCsV3/wm4sQ5Tt45
Ea/4iCFsRBmnIvXwkHRlSDBuMtsgtMpob5If4l4ww+8ropznvD6H7vU7iRXBOECrWmI5Q+uUZbqL
M/KK7tmzP6XhX2XpivYxh9jkvtil68cEZCpUsIk11s6bkzsSWjEjPip5lpW7a6TlP4Lko6ZYRbqA
3Yrm+EGe+dOhbZ2e9I5oA6OaQnBK/Ydu4JmE1idBP5Tg4CcKyNpiEJ4aLwdCc4n3qDXv/LohwVaE
MCIpHV5By21LIzc=
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
