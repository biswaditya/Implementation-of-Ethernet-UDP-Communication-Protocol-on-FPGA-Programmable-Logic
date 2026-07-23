//======================================================================================================================
//  File        : eth_registers.vh
//  Project     : PL-only Ethernet Transmitter (ZCU102 / Vivado 2023.2)
//  Target IP   : AMD/Xilinx AXI Ethernet 1G/2.5G Subsystem v7.2 (soft TEMAC, 1000BASE-X)
//  Purpose     : Symbolic definitions of the AXI4-Lite configuration registers, their bit fields, and the
//                composed write values used to bring the MAC up for transmit.  This header removes every
//                "magic number" from the RTL: each address and each bit has a name traceable to PG138.
//
//  Reference   : PG138 "AXI Ethernet 1G/2.5G Subsystem Product Guide", chapter "Register Space".
//                AMD example design axi_ethernet_0_axi_lite_ctrl.v confirms the same offsets
//                (ADDR_MDIOFREQ=0x500, ADDR_RXCTRL=0x404, ADDR_TXCTRL=0x408).
//
//  Register-map summary (offsets are relative to the subsystem AXI4-Lite base address):
//  -------------------------------------------------------------------------------------------------------
//   Name          Offset   PG138 section            Purpose
//   RCW1          0x404    "Receive Configuration"  Receiver enable + in-band FCS control + pause addr LSBs
//   TC            0x408    "Transmit Control"       Transmitter enable + in-band FCS control
//   FCC           0x40C    "Flow Control Config"    Enable/disable TX & RX pause-frame flow control
//   EMMC          0x410    "MAC Speed Config"       Operating line speed (10/100/1000) - LEFT AT RESET here
//   MDIO_SETUP    0x500    "MDIO Setup"             Enable MDIO master + MDC clock divider
//   MDIO_CONTROL  0x504    "MDIO Control"           PHY/register address + read/write op (not used here)
//   MDIO_WR_DATA  0x508    "MDIO Write Data"        Data driven onto MDIO for a write (not used here)
//   MDIO_RD_DATA  0x50C    "MDIO Read Data"         Data captured from MDIO for a read (not used here)
//  -------------------------------------------------------------------------------------------------------
//======================================================================================================================
`ifndef ETH_REGISTERS_VH
`define ETH_REGISTERS_VH

    //==================================================================================================================
    // 1) REGISTER ADDRESSES (byte offsets from the AXI4-Lite base address)            [PG138 - Register Space]
    //==================================================================================================================
    `define REG_RCW1            32'h0000_0404   // Receive Configuration Word 1
    `define REG_TC              32'h0000_0408   // Transmitter Control
    `define REG_FCC             32'h0000_040C   // Flow Control Configuration
    `define REG_EMMC            32'h0000_0410   // MAC Speed / management config (left at reset for 1000BASE-X)
    `define REG_MDIO_SETUP      32'h0000_0500   // MDIO master setup (enable + clock divide)
    `define REG_MDIO_CONTROL    32'h0000_0504   // MDIO control (address / start)
    `define REG_MDIO_WR_DATA    32'h0000_0508   // MDIO write data
    `define REG_MDIO_RD_DATA    32'h0000_050C   // MDIO read data

    //==================================================================================================================
    // 2) RCW1 - RECEIVE CONFIGURATION WORD 1 (0x404)                                  [PG138 - RCW1]
    //    We enable the receiver so the MAC/PCS link state machine is fully operational; in-band FCS is left
    //    cleared so the MAC strips/handles the FCS itself (we are not passing CRC in the data stream).
    //==================================================================================================================
    `define RCW1_RST_BIT        31              // 1 = soft reset receiver
    `define RCW1_JUM_BIT        30              // 1 = jumbo frames enabled
    `define RCW1_FCS_BIT        29              // 1 = in-band FCS (pass FCS up); 0 = MAC handles FCS
    `define RCW1_RX_BIT         28              // 1 = receiver enable
    `define RCW1_VLAN_BIT       27              // 1 = VLAN aware

    //==================================================================================================================
    // 3) TC - TRANSMITTER CONTROL (0x408)                                             [PG138 - TC]
    //    TX enable (bit 28) starts the transmitter.  FCS (bit 29) MUST be 0 so the MAC computes and APPENDS the
    //    4-byte CRC for us (requirement: "CRC generation shall be performed by the MAC").
    //==================================================================================================================
    `define TC_RST_BIT          31              // 1 = soft reset transmitter
    `define TC_JUM_BIT          30              // 1 = jumbo frames enabled
    `define TC_FCS_BIT          29              // 1 = in-band FCS (data supplies CRC); 0 = MAC inserts CRC
    `define TC_TX_BIT           28              // 1 = transmitter enable
    `define TC_VLAN_BIT         27              // 1 = VLAN aware

    //==================================================================================================================
    // 4) FCC - FLOW CONTROL CONFIGURATION (0x40C)                                     [PG138 - FCC]
    //    For a fire-and-forget transmitter we DISABLE flow control (write 0) so no pause frames gate our TX.
    //==================================================================================================================
    `define FCC_FCTX_BIT        30              // 1 = transmit flow control (pause) enable
    `define FCC_FCRX_BIT        29              // 1 = receive  flow control (pause) enable

    //==================================================================================================================
    // 5) EMMC - MAC SPEED CONFIGURATION (0x410)                                       [PG138 - EMMC]
    //    Provided for completeness.  For the 1000BASE-X variant the reset value already selects 1000 Mb/s, so
    //    this register is intentionally LEFT AT RESET and NOT written by the init FSM.
    //==================================================================================================================
    `define EMMC_LINKSPD_MSB    31              // LINKSPD[1:0] = 00:10Mb/s  01:100Mb/s  10:1000Mb/s
    `define EMMC_LINKSPD_LSB    30
    `define EMMC_SPEED_1000     2'b10

    //==================================================================================================================
    // 6) MDIO_SETUP - MDIO MASTER SETUP (0x500)                                       [PG138 - MDIO Setup]
    //    MDIOEN enables the MDIO master clock; CLOCK_DIVIDE sets MDC = ACLK / (2*(CLOCK_DIVIDE+1)).
    //    0x28 keeps MDC <= 2.5 MHz for a typical 125 MHz AXI clock, matching the AMD example (0x68 == EN|0x28).
    //==================================================================================================================
    `define MDIO_EN_BIT         6               // 1 = enable MDIO master
    `define MDIO_CLKDIV_MSB     5               // CLOCK_DIVIDE[5:0]
    `define MDIO_CLKDIV_LSB     0
    `define MDIO_CLKDIV_VAL     6'h28           // divider value (see formula above)

    //==================================================================================================================
    // 7) COMPOSED 32-BIT WRITE VALUES (built ONLY from the named bits above - no magic numbers)
    //==================================================================================================================
    // MDIO_SETUP <= enable master, divider 0x28
    `define VAL_MDIO_SETUP   ( (32'h1 << `MDIO_EN_BIT) | (`MDIO_CLKDIV_VAL << `MDIO_CLKDIV_LSB) )

    // RCW1 <= receiver enable, in-band FCS off (MAC handles FCS)
    `define VAL_RCW1_RX_EN   ( 32'h1 << `RCW1_RX_BIT )

    // TC <= transmitter enable, in-band FCS off => MAC computes & appends CRC
    `define VAL_TC_TX_EN     ( 32'h1 << `TC_TX_BIT )

    // FCC <= 0 : both TX and RX flow control disabled
    `define VAL_FCC_DISABLE  ( 32'h0000_0000 )

    // EMMC <= 1000 Mb/s (reference value only; not written by the FSM)
    `define VAL_EMMC_1000    ( `EMMC_SPEED_1000 << `EMMC_LINKSPD_LSB )

`endif // ETH_REGISTERS_VH
