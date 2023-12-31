// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_periph package generated by `tlgen.py` tool

package tl_periph_pkg;

  localparam logic [31:0] ADDR_SPACE_UART = 32'h 30000000;
  localparam logic [31:0] ADDR_SPACE_GPIO = 32'h 30010000;
  localparam logic [31:0] ADDR_SPACE_SPI  = 32'h 30020000;
  localparam logic [31:0] ADDR_SPACE_I2C  = 32'h 30030000;
  localparam logic [31:0] ADDR_SPACE_PLIC = 32'h 30050000;

  localparam logic [31:0] ADDR_MASK_UART = 32'h 0000ffff;
  localparam logic [31:0] ADDR_MASK_GPIO = 32'h 0000ffff;
  localparam logic [31:0] ADDR_MASK_SPI  = 32'h 0000ffff;
  localparam logic [31:0] ADDR_MASK_I2C  = 32'h 0000ffff;
  localparam logic [31:0] ADDR_MASK_PLIC = 32'h 0000ffff;

  localparam int N_HOST   = 1;
  localparam int N_DEVICE = 5;

  typedef enum int {
    TlUart = 0,
    TlGpio = 1,
    TlSpi = 2,
    TlI2C = 3,
    TlPlic = 4
  } tl_device_e;

  typedef enum int {
    TlPeriHost = 0
  } tl_host_e;

endpackage
