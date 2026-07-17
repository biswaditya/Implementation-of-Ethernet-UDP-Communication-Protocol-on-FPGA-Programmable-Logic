

set_property PACKAGE_PIN C8 [get_ports mgt_clk_0_clk_p]
create_clock -period 6.400 -name gt_ref_clk [get_ports mgt_clk_0_clk_p]

set_property PACKAGE_PIN F21      [get_ports "CLK_125_N"] ;# Bank  47 VCCO - VCC3V3   - IO_L5N_HDGC_AD7N_47
set_property IOSTANDARD  LVDS_25  [get_ports "CLK_125_N"] ;# Bank  47 VCCO - VCC3V3   - IO_L5N_HDGC_AD7N_47
set_property PACKAGE_PIN G21      [get_ports "CLK_125_P"] ;# Bank  47 VCCO - VCC3V3   - IO_L5P_HDGC_AD7P_47
set_property IOSTANDARD  LVDS_25  [get_ports "CLK_125_P"] ;# Bank  47 VCCO - VCC3V3   - IO_L5P_HDGC_AD7P_47


set_property PACKAGE_PIN A12 [get_ports {SFP_TXD_Enable[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_TXD_Enable[0]}]

set_property PACKAGE_PIN D2 [get_ports sfp_0_rxp]
set_property PACKAGE_PIN D1 [get_ports sfp_0_rxn]
set_property PACKAGE_PIN E4 [get_ports sfp_0_txp]
set_property PACKAGE_PIN E3 [get_ports sfp_0_txn]


set_property PACKAGE_PIN AG14 [get_ports {Dout_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Dout_0[0]}]
set_property PACKAGE_PIN AF13 [get_ports {Dout_1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Dout_1[0]}]
set_property PACKAGE_PIN AE13 [get_ports {Dout_2[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Dout_2[0]}]
set_property PACKAGE_PIN AJ14 [get_ports {Dout_3[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Dout_3[0]}]




