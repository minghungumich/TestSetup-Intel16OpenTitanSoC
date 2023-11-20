// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_1to2 module generated by `tlgen.py` tool
// all reset signals should be generated from one reset signal to not make any deadlock
//
// Interconnect
// core
//   -> s1n_3
//     -> sram
//     -> main

module xbar_1to2 (
  input clk_i,
  input rst_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_core_i,
  output tlul_pkg::tl_d2h_t tl_core_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_sram_o,
  input  tlul_pkg::tl_d2h_t tl_sram_i,
  output tlul_pkg::tl_h2d_t tl_main_o,
  input  tlul_pkg::tl_d2h_t tl_main_i,

  input prim_mubi_pkg::mubi4_t scanmode_i
);

  import tlul_pkg::*;
  import tl_1to2_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = ^scanmode_i;

  tl_h2d_t tl_s1n_3_us_h2d ;
  tl_d2h_t tl_s1n_3_us_d2h ;


  tl_h2d_t tl_s1n_3_ds_h2d [2];
  tl_d2h_t tl_s1n_3_ds_d2h [2];

  // Create steering signal
  logic [1:0] dev_sel_s1n_3;



  assign tl_sram_o = tl_s1n_3_ds_h2d[0];
  assign tl_s1n_3_ds_d2h[0] = tl_sram_i;

  assign tl_main_o = tl_s1n_3_ds_h2d[1];
  assign tl_s1n_3_ds_d2h[1] = tl_main_i;

  assign tl_s1n_3_us_h2d = tl_core_i;
  assign tl_core_o = tl_s1n_3_us_d2h;

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_3 = 2'd2;
    if ((tl_s1n_3_us_h2d.a_address &
         ~(ADDR_MASK_SRAM)) == ADDR_SPACE_SRAM) begin
      dev_sel_s1n_3 = 2'd0;

    end else if ((tl_s1n_3_us_h2d.a_address &
                  ~(ADDR_MASK_MAIN)) == ADDR_SPACE_MAIN) begin
      dev_sel_s1n_3 = 2'd1;
end
  end


  // Instantiation phase
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (8'h0),
    .DRspDepth (8'h0),
    .N         (2)
  ) u_s1n_3 (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .tl_h_i       (tl_s1n_3_us_h2d),
    .tl_h_o       (tl_s1n_3_us_d2h),
    .tl_d_o       (tl_s1n_3_ds_h2d),
    .tl_d_i       (tl_s1n_3_ds_d2h),
    .dev_select_i (dev_sel_s1n_3)
  );

endmodule