// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
<%
 # Additional reset
 int_reset_reqs = rst_reqs["int"]
 debug_reset_reqs = rst_reqs["debug"]
%>\
{ name: "PWRMGR",
  clocking: [
    {clock: "clk_i", reset: "rst_ni", primary: true},
    {reset: "rst_main_ni"},
    {clock: "clk_slow_i", reset: "rst_slow_ni"},
    {clock: "clk_lc_i", reset: "rst_lc_ni"},
    {clock: "clk_esc_i", reset: "rst_esc_ni"}
  ]
  bus_interfaces: [
    { protocol: "tlul", direction: "device" }
  ],
  interrupt_list: [
    { name: "wakeup", desc: "Wake from low power state. See wake info for more details" },
  ],
  alert_list: [
    { name: "fatal_fault",
      desc: '''
      This fatal alert is triggered when a fatal TL-UL bus integrity fault is detected.
      '''
    }
  ],

  inter_signal_list: [
    { struct:  "pwr_ast",
      type:    "req_rsp",
      name:    "pwr_ast",
      act:     "req",
      package: "pwrmgr_pkg",
    },

    { struct:  "pwr_rst",
      type:    "req_rsp",
      name:    "pwr_rst",
      act:     "req",
      package: "pwrmgr_pkg",
    },

    { struct:  "pwr_clk",
      type:    "req_rsp",
      name:    "pwr_clk",
      act:     "req",
      package: "pwrmgr_pkg",
    },

    { struct:  "pwr_otp",
      type:    "req_rsp",
      name:    "pwr_otp",
      act:     "req",
      package: "pwrmgr_pkg",
    },

    { struct:  "pwr_lc",
      type:    "req_rsp",
      name:    "pwr_lc",
      act:     "req",
      package: "pwrmgr_pkg",
    },

    { struct:  "pwr_flash",
      type:    "uni",
      name:    "pwr_flash",
      act:     "rcv",
      package: "pwrmgr_pkg",
    },

    { struct:  "esc_tx",
      type:    "uni",
      name:    "esc_rst_tx",
      act:     "rcv",
      package: "prim_esc_pkg",
    },

    { struct:  "esc_rx",
      type:    "uni",
      name:    "esc_rst_rx",
      act:     "req",
      package: "prim_esc_pkg",
    },

    { struct:  "pwr_cpu",
      type:    "uni",
      name:    "pwr_cpu",
      act:     "rcv",
      package: "pwrmgr_pkg",
    },

    { struct:  "logic",
      width:   ${NumWkups},
      type:    "uni",
      name:    "wakeups",
      act:     "rcv",
      package: "",
    },

    { struct:  "logic",
      width:   ${NumRstReqs},
      type:    "uni",
      name:    "rstreqs",
      act:     "rcv",
      package: "",
    },

    { struct:  "logic",
      type:    "uni",
      name:    "ndmreset_req",
      act:     "rcv",
    },

    { struct:  "logic",
      type:    "uni",
      name:    "strap",
      act:     "req",
      package: "",
    },

    { struct:  "logic",
      type:    "uni",
      name:    "low_power",
      act:     "req",
      package: "",
    },

    { struct:  "pwrmgr_data",
      type:    "uni",
      name:    "rom_ctrl",
      act:     "rcv",
      package: "rom_ctrl_pkg",
    },

    { struct:  "lc_tx",
      type:    "uni",
      name:    "fetch_en",
      act:     "req",
      package: "lc_ctrl_pkg",
    },

    { struct:  "lc_tx",
      type:    "uni",
      name:    "lc_dft_en",
      act:     "rcv",
      package: "lc_ctrl_pkg",
    },

    { struct:  "lc_tx",
      type:    "uni",
      name:    "lc_hw_debug_en",
      act:     "rcv",
      package: "lc_ctrl_pkg",
    },

    { struct:  "mubi4",
      type:    "uni",
      name:    "sw_rst_req",
      act:     "rcv",
      package: "prim_mubi_pkg",
    },
  ],

  param_list: [
    { name: "NumWkups",
      desc: "Number of wakeups",
      type: "int",
      default: "${NumWkups}",
      local: "true"
    },

    % for wkup in Wkups:
    { name: "${wkup['module'].upper()}_${wkup['name'].upper()}_IDX",
      desc: "Vector index for ${wkup['module']} ${wkup['name']}, applies for WAKEUP_EN, WAKE_STATUS and WAKE_INFO",
      type: "int",
      default: "${loop.index}",
      local: "true"
    },

    % endfor

    { name: "NumRstReqs",
      desc: "Number of peripheral reset requets",
      type: "int",
      default: "${NumRstReqs}",
      local: "true"
    },

    { name: "NumIntRstReqs",
      desc: "Number of pwrmgr internal reset requets",
      type: "int",
      default: "${len(int_reset_reqs)}",
      local: "true"
    },

    { name: "NumDebugRstReqs",
      desc: "Number of debug reset requets",
      type: "int",
      default: "${len(debug_reset_reqs)}",
      local: "true"
    },

    % for req in int_reset_reqs + debug_reset_reqs:
    { name: "${f"Reset{req['name']}Idx"}",
      desc: "Reset req idx for ${req['name']}",
      type: "int",
      default: "${loop.index + NumRstReqs}",
      local: "true"
    },
    % endfor

  ],
  countermeasures: [
    { name: "BUS.INTEGRITY",
      desc: "End-to-end bus integrity scheme."
    }
    { name: "LC_CTRL.INTERSIG.MUBI",
      desc: "life cycle control / debug signals are multibit."
    }
    { name: "ROM_CTRL.INTERSIG.MUBI",
      desc: "rom control done/good signals are multibit."
    }
    { name: "RSTMGR.INTERSIG.MUBI",
      desc: "reset manager software request is multibit."
    }
    { name: "ESC_RX.CLK.BKGN_CHK",
      desc: "Escalation receiver has a background timeout check"
    }
    { name: "ESC_RX.CLK.LOCAL_ESC",
      desc: "Escalation receiver clock timeout has a local reset escalation"
    }
    { name: "FSM.SPARSE",
      desc: "Sparse encoding for slow and fast state machines."
    }
    { name: "FSM.TERMINAL",
      desc: '''
        When FSMs reach a bad state, go into a terminate state that does not
        recover without user or external host intervention.
      '''
    }
    { name: "CTRL_FLOW.GLOBAL_ESC",
      desc: "When global escalation is received, proceed directly to reset."
    }
    { name: "MAIN_PD.RST.LOCAL_ESC",
      desc: "When main power domain reset glitches, proceed directly to reset."
    }
    { name: "CTRL.CONFIG.REGWEN",
      desc: "Main control protected by regwen."
    }
    { name: "WAKEUP.CONFIG.REGWEN",
      desc: "Wakeup configuration protected by regwen."
    }
    { name: "RESET.CONFIG.REGWEN",
      desc: "Reset configuration protected by regwen."
    }

  ]

  regwidth: "32",
  registers: [

    { name: "CTRL_CFG_REGWEN",
      swaccess: "ro",
      hwaccess: "hwo",
      hwext: "true",
      desc: '''
      Controls the configurability of the !!CONTROL register.

      This register ensures the contents do not change once a low power hint and
      WFI has occurred.

      It unlocks whenever a low power transition has completed (transition back to the
      ACTIVE state) for any reason.
      ''',

      fields: [
        { bits: "0",
          name: "EN",
          desc: '''
            Configuration enable.

            This bit defaults to 1 and is set to 0 by hardware when low power entry is initiated.
            When the device transitions back from low power state to active state, this bit is set
            back to 1 to allow software configuration of !!CONTROL
          ''',
          resval: "1",
        },
      ]
      tags: [// This regwen is completely under HW management and thus cannot be manipulated
             // by software.
             "excl:CsrNonInitTests:CsrExclCheck"]
    },


    { name: "CONTROL",
      desc: "Control register",
      swaccess: "rw",
      hwaccess: "hro",
      regwen: "CTRL_CFG_REGWEN",
      tags: [// Turning off USB clock in active state impacts other CSRs
             // at the chip level (in other blocks, such as clkmgr),
             // so we exclude writing from this register.
             "excl:CsrAllTests:CsrExclWrite"]
      fields: [
        { bits: "0",
          hwaccess: "hrw",
          name: "LOW_POWER_HINT",
          desc: '''
            The low power hint to power manager.
            The hint is an indication for how the manager should treat the next WFI.
            Once the power manager begins a low power transition, or if a valid reset request is registered,
            this bit is automatically cleared by HW.
            '''
          resval: "0"
          enum: [
            { value: "0",
              name: "None",
              desc: '''
                No low power intent
                '''
            },
            { value: "1",
              name: "Low Power",
              desc: '''
                Next WFI should trigger low power entry
                '''
            },
          ]
          tags: [// The regwen for this reg is RO. CSR seq can't support to check this reg
          "excl:CsrAllTests:CsrExclAll"]
        },

        { bits: "4",
          name: "CORE_CLK_EN",
          desc: "core clock enable during low power state",
          resval: "0"
          enum: [
            { value: "0",
              name: "Disabled",
              desc: '''
                Core clock disabled during low power state
                '''
            },
            { value: "1",
              name: "Enabled",
              desc: '''
                Core clock enabled during low power state
                '''
            },
          ]
        },

        { bits: "5",
          name: "IO_CLK_EN",
          desc: "IO clock enable during low power state",
          resval: "0"
          enum: [
            { value: "0",
              name: "Disabled",
              desc: '''
                IO clock disabled during low power state
                '''
            },
            { value: "1",
              name: "Enabled",
              desc: '''
                IO clock enabled during low power state
                '''
            },
          ]
        },

        { bits: "6",
          name: "USB_CLK_EN_LP",
          desc: "USB clock enable during low power state",
          resval: "0",
          enum: [
            { value: "0",
              name: "Disabled",
              desc: '''
                USB clock disabled during low power state
                '''
            },
            { value: "1",
              name: "Enabled",
              desc: '''
                USB clock enabled during low power state.

                However, if !!CONTROL.MAIN_PD_N is 0, USB clock is disabled
                during low power state.
                '''
            },
          ]
        },

        { bits: "7",
          name: "USB_CLK_EN_ACTIVE",
          desc: "USB clock enable during active power state",
          resval: "1"
          enum: [
            { value: "0",
              name: "Disabled",
              desc: '''
                USB clock disabled during active power state
                '''
            },
            { value: "1",
              name: "Enabled",
              desc: '''
                USB clock enabled during active power state
                '''
            },
          ]
        },

        { bits: "8",
          name: "MAIN_PD_N",
          desc: "Active low, main power domain power down",
          resval: "1"
          enum: [
            { value: "0",
              name: "Power down",
              desc: '''
                Main power domain is powered down during low power state.
                '''
            },
            { value: "1",
              name: "Power up",
              desc: '''
                Main power domain is kept powered during low power state
                '''
            },
          ]
        },


      ],
    },

    { name: "CFG_CDC_SYNC",
      swaccess: "rw",
      hwaccess: "hrw",
      hwqe: "true",
      desc: '''
      The configuration registers CONTROL, WAKEUP_EN, RESET_EN are all written in the
      fast clock domain but used in the slow clock domain.

      The configuration are not propagated across the clock boundary until this
      register is triggered and read.  See fields below for more details
      ''',

      fields: [
        { bits: "0",
          name: "SYNC",
          desc: '''
            Configuration sync.  When this bit is written to 1, a sync pulse is generated.  When
            the sync completes, this bit then self clears.

            Software should write this bit to 1, wait for it to clear, before assuming the slow clock
            domain has accepted the programmed values.
          ''',
          resval: "0",
        },
      ]
      tags: [// This bit triggers a payload synchronization and self clears when complete.
             // Do not write this bit as there will be side effects and the value will not persist
             "excl:CsrNonInitTests:CsrExclWrite"]
    },

    { name: "WAKEUP_EN_REGWEN",
      desc: "Configuration enable for wakeup_en register",
      swaccess: "rw0c",
      hwaccess: "none",
      fields: [
        { bits: "0",
          resval: "1"
          name: "EN",
          desc: '''
            When 1, WAKEUP_EN register can be configured.
            When 0, WAKEUP_EN register cannot be configured.
          ''',
        },
      ]
    },

    { multireg:
      { name: "WAKEUP_EN",
        desc: "Bit mask for enabled wakeups",
        swaccess: "rw",
        hwaccess: "hro",
        regwen: "WAKEUP_EN_REGWEN",
        resval: "0"
        cname: "wakeup_en",
        count: "NumWkups"
        fields: [
          { bits: "0",
            name: "EN",
            desc: '''
              Whenever a particular bit is set to 1, that wakeup is also enabled.
              Whenever a particular bit is set to 0, that wakeup cannot wake the device from low power.
            ''',
          },
        ]
      },
    },

    { multireg:
      { name: "WAKE_STATUS",
        desc: "A read only register of all current wake requests post enable mask",
        swaccess: "ro",
        hwaccess: "hwo",
        resval: "0"
        cname: "wake_status",
        count: "NumWkups",
        tags: [// Cannot auto-predict current wake request status
               "excl:CsrNonInitTests:CsrExclWriteCheck"],
        fields: [
          { bits: "0",
            name: "VAL",
            desc: '''
              Current value of wake requests
            ''',
          },
        ]
      },
    },

    { name: "RESET_EN_REGWEN",
      desc: "Configuration enable for reset_en register",
      swaccess: "rw0c",
      hwaccess: "none",
      fields: [
        { bits: "0",
          resval: "1"
          name: "EN",
          desc: '''
            When 1, RESET_EN register can be configured.
            When 0, RESET_EN register cannot be configured.
          ''',
        },
      ]
    },

    { multireg:
      { name: "RESET_EN",
        desc: "Bit mask for enabled reset requests",
        swaccess: "rw",
        hwaccess: "hro",
        regwen: "RESET_EN_REGWEN",
        resval: "0"
        cname: "rstreq_en",
        count: "NumRstReqs"
        fields: [
          { bits: "0",
            name: "EN",
            desc: '''
              Whenever a particular bit is set to 1, that reset request is enabled.
              Whenever a particular bit is set to 0, that reset request cannot reset the device.
            ''',
          },
        ]
        tags: [// Self resets should never be triggered by automated tests
        "excl:CsrAllTests:CsrExclWrite"]
      },
    },

    { multireg:
      { name: "RESET_STATUS",
        desc: "A read only register of all current reset requests post enable mask",
        swaccess: "ro",
        hwaccess: "hwo",
        resval: "0"
        cname: "reset_status",
        count: "NumRstReqs",
        fields: [
          { bits: "0",
            name: "VAL",
            desc: '''
              Current value of reset request
            ''',
          },
        ]
      },
    },

    { name: "ESCALATE_RESET_STATUS",
      desc: "A read only register of escalation reset request",
      swaccess: "ro",
      hwaccess: "hwo",
      resval: "0"
      fields: [
        { bits: "0",
          name: "VAL",
          desc: '''
            When 1, an escalation reset has been seen.
            When 0, there is no escalation reset.
          ''',
        },
      ]
    },

    { name: "WAKE_INFO_CAPTURE_DIS",
      desc: "Indicates which functions caused the chip to wakeup",
      swaccess: "rw",
      hwaccess: "hro",
      resval: "0"
      fields: [
        { bits: "0",
          name: "VAL",
          desc: '''
            When written to 1, this actively suppresses the wakeup info capture.
            When written to 0, wakeup info capture timing is controlled by HW.
          ''',
        },
      ]
    },

    { name: "WAKE_INFO",
      desc: '''
        Indicates which functions caused the chip to wakeup.
        The wake info recording begins whenever the device begins a valid low power entry.

        This capture is continued until it is explicitly disabled through WAKE_INFO_CAPTURE_DIS.
        This means it is possible to capture multiple wakeup reasons.
      ''',
      swaccess: "rw1c",
      hwaccess: "hrw",
      hwext: "true",
      hwqe: "true",
      resval: "0"
      fields: [
        { bits: "${NumWkups-1}:0",
          name: "REASONS",
          desc: "Various peripheral wake reasons"
        },
        { bits: "${NumWkups}",
          name: "FALL_THROUGH",
          desc: '''
            The fall through wakeup reason indicates that despite setting a WFI and providing a low power
            hint, an interrupt arrived at just the right time to break the executing core out of WFI.

            The power manager detects this condition, halts low power entry and reports as a wakeup reason
          ''',
        },
        { bits: "${NumWkups+1}",
          name: "ABORT",
          desc: '''
            The abort wakeup reason indicates that despite setting a WFI and providing a low power
            hint, an active flash / lifecycle / otp transaction was ongoing when the power controller
            attempted to initiate low power entry.

            The power manager detects this condition, halts low power entry and reports as a wakeup reason
          ''',
        },
      ]
      tags: [// This regwen is completely under HW management and thus cannot be manipulated
             // by software.
             "excl:CsrNonInitTests:CsrExclCheck"]
    },

    { name: "FAULT_STATUS",
      desc: "A read only register that shows the existing faults",
      swaccess: "ro",
      hwaccess: "hrw",
      sync: "clk_lc_i",
      resval: "0"
      fields: [
        { bits: "0",
          name: "REG_INTG_ERR",
          desc: '''
            When 1, an integrity error has occurred.
          ''',
        },

        { bits: "1",
          name: "ESC_TIMEOUT",
          desc: '''
            When 1, an escalation clock / reset timeout has occurred.
          ''',
        },

        { bits: "2",
          name: "MAIN_PD_GLITCH",
          desc: '''
            When 1, unexpected power glitch was observed on main PD.
          ''',
        },
      ]
    },
  ]
}