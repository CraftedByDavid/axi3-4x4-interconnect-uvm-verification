# 🔀 UVM-Based Verification of AXI3 4×4 Interconnect

<div align="center">

![Methodology](https://img.shields.io/badge/Methodology-UVM%201.2-blue?style=for-the-badge)
![Coverage](https://img.shields.io/badge/Functional%20Coverage-93.63%25-brightgreen?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-SystemVerilog-orange?style=for-the-badge)
![Protocol](https://img.shields.io/badge/Protocol-AXI3-purple?style=for-the-badge)
![Assertions](https://img.shields.io/badge/SVA%20Assertions-20-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

**UVM verification of a 4-master / 4-slave AXI3 crossbar interconnect**  
*Round-robin arbitration · 8 active agents · 16 covergroups · 20 SVA assertions · 93.63% functional coverage*

</div>

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [DUT Architecture](#-dut-architecture)
- [Testbench Architecture](#-testbench-architecture)
- [Directory Structure](#-directory-structure)
- [UVM Component Breakdown](#-uvm-component-breakdown)
- [SVA Assertions](#-sva-assertions)
- [Test Plan](#-test-plan)
- [Functional Coverage](#-functional-coverage)
- [TLM Connection Map](#-tlm-connection-map)
- [How to Run](#-how-to-run)
- [Simulation Results](#-simulation-results)
- [Key Learnings](#-key-learnings)

---

## 📌 Project Overview

This project implements a complete **UVM-based functional verification environment** for an
**AXI3 4×4 Interconnect** — a parameterizable crossbar fabric that routes AXI3 transactions
from 4 master ports to 4 slave ports based on address decoding, with round-robin arbitration
for simultaneous access resolution.

| Parameter | Value |
|-----------|-------|
| **DUT** | `axi_interconnect_wrap_4x4` → `axi_interconnect` |
| **Protocol** | AXI3 — 5 channels: AW, W, B, AR, R |
| **Data / Address Width** | 32-bit data, 32-bit address, 8-bit transaction ID |
| **Masters / Slaves** | 4 masters (S-ports) × 4 slaves (M-ports) |
| **Arbitration** | Round-robin with blocking acknowledge |
| **Address Map** | 4 × 16 MB regions (24-bit width each) |
| **UVM Agents** | 4 × Master Agent (Active) + 4 × Slave Agent (Active) |
| **SVA Assertions** | 20 protocol assertions (embedded in interfaces) |
| **Functional Coverage** | **93.63%** |
| **Tests** | 7 (Fixed, INCR, WRAP, Random, 3× Extended Random) |

---

## 🏗️ DUT Architecture

### Module Hierarchy

```
axi_interconnect_wrap_4x4       ← 4×4 wrapper (flattens per-port signals)
└── axi_interconnect            ← Core crossbar (S_COUNT=4, M_COUNT=4)
      ├── arbiter               ← Round-robin, PORTS=8 (4 slaves × {write,read})
      │     └── priority_encoder × 2  ← Masked priority encoder
      └── 8-state FSM per slot  ← IDLE→DECODE→WRITE/READ→WAIT_IDLE
```

### Address Map

| Slave | Base Address | Range | Size |
|-------|-------------|-------|------|
| Slave 0 | `0x00000000` | `0x00000000 – 0x00FFFFFF` | 16 MB |
| Slave 1 | `0x01000000` | `0x01000000 – 0x01FFFFFF` | 16 MB |
| Slave 2 | `0x02000000` | `0x02000000 – 0x02FFFFFF` | 16 MB |
| Slave 3 | `0x03000000` | `0x03000000 – 0x03FFFFFF` | 16 MB |

### Interconnect FSM

The core implements an 8-state FSM: `IDLE` → `DECODE` → `WRITE` → `WRITE_RESP` → `WAIT_IDLE`
(write path) and `IDLE` → `DECODE` → `READ` → `WAIT_IDLE` (read path).
Drop states (`WRITE_DROP`, `READ_DROP`) handle decode errors (invalid addresses).

### AXI Channels

| Channel | Dir | Key Signals |
|---------|-----|-------------|
| AW | M→S | AWID[7:0], AWADDR[31:0], AWLEN[7:0], AWSIZE[2:0], AWBURST[1:0], AWVALID, AWREADY |
| W  | M→S | WID[7:0], WDATA[31:0], WSTRB[3:0], WLAST, WVALID, WREADY |
| B  | S→M | BID[7:0], BRESP[1:0], BVALID, BREADY |
| AR | M→S | ARID[7:0], ARADDR[31:0], ARLEN[7:0], ARSIZE[2:0], ARBURST[1:0], ARVALID, ARREADY |
| R  | S→M | RID[7:0], RDATA[31:0], RRESP[1:0], RLAST, RVALID, RREADY |

---

## 🧪 Testbench Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TEST LAYER                                     │
│   fixed_test  incr_test  wrap_test  random_test  extended_random_test 1/2/3 │
│                       └─── axi_test (base) ───┘                            │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────────────┐
│                      axi_env  (UVM Environment)                             │
│                                                                             │
│   magt_toph[0..3]  (Master Agent Tops)                                     │
│   ┌─────────────────────────────────────────────┐                          │
│   │  axi_mdrv   axi_mmon   axi_mseqr            │ × 4                      │
│   │  (semaphore-based 5-channel parallel drive)  │                          │
│   └───────────────────┬─────────────────────────┘                          │
│                       │ mmp (analysis_port)                                 │
│   sagt_toph[0..3]  (Slave Agent Tops)                                      │
│   ┌─────────────────────────────────────────────┐                          │
│   │  axi_sdrv   axi_smon   axi_sseqr            │ × 4                      │
│   │  (responds to AW/W; drives BRESP/RDATA)     │                          │
│   └───────────────────┬─────────────────────────┘                          │
│                       │ smp (analysis_port)                                 │
│   ┌───────────────────▼─────────────────────────────────────────────────┐   │
│   │  axi_sb  (Scoreboard)                                                │   │
│   │  fmep[0..3]  fsep[0..3]  (TLM FIFOs)                                │   │
│   │  16 covergroups (waddr/wdata/raddr/rdata × 4 pairs)                  │   │
│   │  check_data(): axi_trans.compare() master vs slave                   │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                               │
      axi_mif × 4  +  axi_sif × 4
      (mst_drv_cb / mst_mon_cb | slv_drv_cb / slv_mon_cb)
      20 SVA assertions embedded in interface files
                               │
┌──────────────────────────────▼──────────────────────────────────────────────┐
│  DUT: axi_interconnect_wrap_4x4                                             │
│  (4 slave ports s00–s03 → crossbar → 4 master ports m00–m03)               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
axi3-interconnect-uvm-verification/
│
├── rtl/
│   ├── priority_encoder.v          # Parameterizable priority encoder (LSB/MSB)
│   ├── arbiter.v                   # Round-robin arbiter with blocking ack
│   ├── axi_interconnect.v          # Core 4×4 AXI crossbar (8-state FSM)
│   └── axi_interconnect_wrap_4x4.v # 4×4 wrapper — exposes per-port flat signals
│
├── tb/
│   ├── axi_top.sv                  # UVM top — clock/reset gen, 8 interface inst, run_test()
│   ├── axi_mif.sv                  # Master-side SV interface + 10 SVA assertions
│   ├── axi_sif.sv                  # Slave-side SV interface + 10 SVA assertions
│   ├── axi_pkg.sv                  # Package importing all TB classes
│   │
│   ├── transaction/
│   │   └── axi_trans.sv            # Unified AXI transaction (W+R), constraints, addr/strb calc
│   │
│   ├── config/
│   │   ├── axi_env_config.sv       # Env config (num_magent/sagent, has_scoreboard)
│   │   ├── axi_magent_config.sv    # Master agent config (mvif, is_active)
│   │   └── axi_sagent_config.sv    # Slave agent config (svif, is_active)
│   │
│   ├── master_agent/
│   │   ├── axi_mdrv.sv             # Master driver (semaphore-gated 5-channel)
│   │   ├── axi_mmon.sv             # Master monitor (posedge sampling, all channels)
│   │   ├── axi_mseqr.sv            # Master sequencer
│   │   ├── axi_magent.sv           # Master agent (packs drv+mon+seqr)
│   │   └── axi_magent_top.sv       # Master agent top wrapper
│   │
│   ├── slave_agent/
│   │   ├── axi_sdrv.sv             # Slave driver (responds AW/W/AR; drives B/R channels)
│   │   ├── axi_smon.sv             # Slave monitor
│   │   ├── axi_sseqr.sv            # Slave sequencer
│   │   ├── axi_sagent.sv           # Slave agent
│   │   └── axi_sagent_top.sv       # Slave agent top wrapper
│   │
│   ├── scoreboard/
│   │   └── axi_sb.sv               # SB + 16 covergroups + compare + report
│   │
│   ├── env/
│   │   └── axi_env.sv              # UVM env — connects 8 agents + scoreboard
│   │
│   └── sequences/
│       ├── axi_mseq.sv             # Master sequence library (fixed/incr/wrap/random/extended×12)
│       └── axi_sseq.sv             # Slave base sequence
│
├── tests/
│   └── axi_test.sv                 # All 7 test classes
│
└── README.md
```

---

## 🔩 UVM Component Breakdown

### Master Driver (`axi_mdrv`)
Uses **5 semaphores** for channel ordering within each transaction:
- `sem_awc` → `drive_awaddr()` → `sem_awdc.put` → `drive_wdata()` → `sem_wdrc.put` → `drive_bresp()`
- `sem_arc` → `drive_raddr()` → `sem_ardc.put` → `drive_rdata()`

Both write and read channels run in parallel via `fork...join_any`. Internal queues `q1–q5` decouple the channels from the sequence item.

### Master Monitor (`axi_mmon`)
Mirrors the driver semaphore structure for sampling. Separately collects: write address → write data → write response, and read address → read data. Publishes each partial transaction immediately via `mmp.write()`.

### Slave Driver (`axi_sdrv`)
Acts as a simple memory slave. On write: accepts AW, then W beats (storing into `mem[addr]` indexed by computed beat address), then drives BRESP=OKAY. On read: accepts AR, drives random `$urandom` RDATA for each beat with RRESP=OKAY and RLAST on the last beat.

### Scoreboard (`axi_sb`)
- 8 TLM FIFOs — `fmep[0..3]` for master monitors, `fsep[0..3]` for slave monitors
- `run_phase`: nested `fork:A...join_any` / `disable A` to get first master transaction from any FIFO, then `fork:B...join_any` / `disable B` to get first slave transaction
- Calls `check_data(wth, rth)` → `mth.compare(sth)` → prints SUCCESS/FAIL
- Samples all 16 covergroups after each pair
- `report_phase`: prints per-channel coverage + computes `fc = sum(16 covergroups)/16`

---

## ✅ SVA Assertions

20 assertions are embedded in `axi_mif.sv` and `axi_sif.sv`:

| Group | Count | Properties |
|-------|-------|------------|
| Valid-Stable | 5 | AW/W/AR/B/R signals must remain stable from VALID until READY handshake |
| Handshake Hold | 5 | AWVALID/WVALID/ARVALID/BVALID/RVALID must not drop until READY seen |
| WRAP Alignment | 4 | WRAP bursts must have aligned addresses (SIZE=1→addr%2==0, SIZE=2→addr%4==0) |
| Size Limits | 2 | AWSIZE < 3 when AWVALID; ARSIZE < 3 when ARVALID |
| 4KB Boundary | 2 | (AWLEN+1)×2^AWSIZE < 4096; (ARLEN+1)×2^ARSIZE < 4096 |
| Burst Type | 2 | AWBURST ≠ 3; ARBURST ≠ 3 (reserved encoding must not occur) |
| LAST Hold | 2 | WLAST/RLAST — VALID must remain high after LAST until READY |

---

## 🧾 Test Plan

All tests inherit `axi_test`. Sequences run on all 4 master sequencers in a `for` loop:

| Test | Sequence | Burst Type | Scenario |
|------|----------|------------|----------|
| `fixed_test` | `fixed_mseq` | FIXED (0) | maddr=1 → saddr=0 |
| `incr_test` | `incr_mseq` | INCR (1) | maddr=2 → saddr=1 |
| `wrap_test` | `wrap_mseq` | WRAP (2) | maddr=3 → saddr=2 |
| `random_test` | `random_mseq` | All types | maddr=0 → saddr=3 |
| `extended_random_test1` | `ermseq1..4` | Mixed per master | AWSIZE=2, ARBURST∈{1,2}, specific stobe sets |
| `extended_random_test2` | `ermseq5..8` | Mixed | AWSIZE=2/ARBURST=2, varied stobe ranges |
| `extended_random_test3` | `ermseq9..12` | Mixed | AWSIZE=1/2, ARBURST∈{1,2}, more strobe combinations |

---

## 📊 Functional Coverage

16 covergroups — 4 per master-slave pair (0..3):

| Covergroup | Coverpoints | Description |
|-----------|-------------|-------------|
| `cg_axiN_waddr` | AWADDR, AWBURST[0:2], AWSIZE[0:2], AWLEN[0:15], BRESP=0, cross | Write address coverage per slave region; burst×size×len cross |
| `cg_axiN_wdata` | WDATA[0:0xFFFFFFFF], WSTRB∈{15,14,12,8,7,4,3,2,1}, cross | Per-beat write data and strobe coverage |
| `cg_axiN_raddr` | ARADDR, ARBURST[0:2], ARSIZE[0:2], ARLEN[0:15], cross | Read address and burst cross coverage |
| `cg_axiN_rdata` | RDATA[0:0xFFFFFFFF], RRESP=0 | Read data range and response coverage |

```
Overall Functional Coverage:  93.63%
```

---

## 🔌 TLM Connection Map

| From | To | Purpose |
|------|----|---------|
| `magt_toph[i].magth.mmonh.mmp` | `sbh.fmep[i].analysis_export` | Master transactions to scoreboard |
| `sagt_toph[i].sagth.smonh.smp` | `sbh.fsep[i].analysis_export` | Slave transactions to scoreboard |
| `axi_mdrv.seq_item_port` | `axi_mseqr.seq_item_export` | Master driver pulls items |
| `axi_sdrv.seq_item_port` | `axi_sseqr.seq_item_export` | Slave driver pulls items |

---

## ▶️ How to Run

### Compile + Run with VCS

```bash
# Compile
vcs -sverilog -ntb_opts uvm-1.2 \
    rtl/priority_encoder.v rtl/arbiter.v \
    rtl/axi_interconnect.v rtl/axi_interconnect_wrap_4x4.v \
    tb/axi_mif.sv tb/axi_sif.sv tb/axi_top.sv tb/axi_pkg.sv \
    +incdir+tb/ -o simv

# Run tests
./simv +UVM_TESTNAME=fixed_test      +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=incr_test       +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=wrap_test       +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=random_test     +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=extended_random_test1 +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=extended_random_test2 +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=extended_random_test3 +UVM_VERBOSITY=UVM_MEDIUM

# Dump waveforms
./simv +UVM_TESTNAME=random_test -ucli -do "fsdbDumpvars 0 axi_top; fsdbDumpSVA 0 axi_top; run; exit"
```

### Regression

```bash
for test in fixed_test incr_test wrap_test random_test \
            extended_random_test1 extended_random_test2 extended_random_test3; do
    echo "Running $test..."
    ./simv +UVM_TESTNAME=$test +UVM_VERBOSITY=UVM_LOW | tee logs/${test}.log
done
```

---

## 📈 Simulation Results

### UVM Topology

```
uvm_test_top          random_test / axi_test
  envh                axi_env
    magt_toph[0..3]   axi_magent_top
      magth           axi_magent
        mdrvh         axi_mdrv
        mmonh         axi_mmon
        mseqrh        axi_mseqr
    sagt_toph[0..3]   axi_sagent_top
      sagth           axi_sagent
        sdrvh         axi_sdrv
        smonh         axi_smon
        sseqrh        axi_sseqr
    sbh               axi_sb
      fmep[0..3]      uvm_tlm_analysis_fifo  (master)
      fsep[0..3]      uvm_tlm_analysis_fifo  (slave)
```

### Address Routing (printed by DUT at elaboration)

```
 0 ( 0): 00000000 / 24 -- 00000000-00ffffff  → Slave 0
 1 ( 0): 01000000 / 24 -- 01000000-01ffffff  → Slave 1
 2 ( 0): 02000000 / 24 -- 02000000-02ffffff  → Slave 2
 3 ( 0): 03000000 / 24 -- 03000000-03ffffff  → Slave 3
```

---

## 💡 Key Learnings

- **Semaphore-Based Channel Management** — Using 5 semaphores per driver/monitor pair correctly enforces AXI channel ordering (address before data, data before response) without blocking independent read and write paths.

- **Unified Transaction Class** — Using a single `axi_trans` for both master and slave sides with a custom `do_compare()` that checks only protocol-relevant fields avoids the overhead of separate master/slave transaction classes.

- **`post_randomize()` Address Calculation** — Computing burst beat addresses (with wrap-boundary logic) inside `post_randomize()` keeps sequences clean and ensures the driver and monitor always agree on which address each beat corresponds to.

- **`fork:A...join_any` / `disable A` Pattern** — Using named fork blocks with `disable` in the scoreboard efficiently implements "wait for the first arriving transaction from any of N FIFOs" without polling.

- **SVA in Interface Files** — Embedding assertions directly in `axi_mif.sv` and `axi_sif.sv` means they fire automatically for all 4 master and 4 slave interface instances without duplicating any code.

- **Extended Random Sequences** — Rather than a single random test, creating 12 extended sequences with targeted strobe/burst/size constraints drives corner cases that plain random misses, which explains the 93.63% coverage result.

---

## 📄 License

RTL design (`axi_interconnect`, `arbiter`, `priority_encoder`) based on open-source AXI infrastructure. Testbench design, verification plan, and coverage methodology are original work.

---

<div align="center">
  <b>Built with ❤️ using SystemVerilog + UVM 1.2</b><br>
  If this helped you, consider giving it a ⭐
</div>
