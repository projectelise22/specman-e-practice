# ALU Specman-e Testbench (eRM)

A complete **Coverage-Driven Verification (CDV)** testbench for an 8-bit ALU written in **Specman-e** using the **eRM (e Reuse Methodology)**. This is the first project in a series working toward mastering Specman-e alongside SystemVerilog/UVM.

---

## DUT — 8-bit ALU

| Signal   | Direction | Width | Description                          |
|----------|-----------|-------|--------------------------------------|
| `clk`    | input     | 1-bit | System clock                         |
| `rst_n`  | input     | 1-bit | Active-low synchronous reset         |
| `a`      | input     | 8-bit | Operand A                            |
| `b`      | input     | 8-bit | Operand B                            |
| `op`     | input     | 2-bit | Operation: `00`=ADD `01`=SUB `10`=AND `11`=OR |
| `valid`  | input     | 1-bit | Input valid strobe                   |
| `result` | output    | 9-bit | Result (9-bit captures carry/borrow) |
| `done`   | output    | 1-bit | Result valid strobe                  |

---

## Testbench Architecture

```
sys (root)
└── alu_env_u
    ├── alu_evc_u                  ← eVC: bundles driver + monitor
    │   ├── alu_driver_u           ← drives stimulus onto DUT pins
    │   └── alu_monitor_u          ← observes DUT outputs, fires events
    ├── alu_random_seq_u           ← generates constrained-random packets
    ├── alu_corner_seq_u           ← targeted corner case stimulus
    ├── alu_scoreboard_u           ← checks actual vs expected result
    └── alu_coverage_u             ← functional coverage collection
```

---

## File Structure

```
alu/
├── design.sv        # Verilog DUT (alu module + top wrapper)
└── testbench.e      # Combined e testbench (all sections in load order)
```

### Testbench Sections (in load order inside `testbench.e`)

| Section              | e Construct | Purpose |
|----------------------|-------------|---------|
| `alu_packet_s`       | `struct`    | Transaction: holds `a`, `b`, `op`, computed `expected_result` |
| `alu_driver_u`       | `unit`      | Drives reset and packet stimulus using TCMs |
| `alu_monitor_u`      | `unit`      | Passively observes `result` and `done`, fires `result_ready` event |
| `alu_evc_u`          | `unit`      | eVC wrapper — owns HDL path bindings for all DUT signals |
| `alu_scoreboard_u`   | `unit`      | FIFO queue comparison: expected vs actual |
| `alu_coverage_u`     | `unit`      | Functional coverage: opcodes, operand ranges, cross coverage |
| `alu_random_seq_u`   | `unit`      | 20 constrained-random transactions |
| `alu_corner_seq_u`   | `unit`      | 4 targeted corner cases |
| `alu_env_u`          | `unit`      | Wires all units together via `read_only` references |
| `extend sys`         | AOP         | Entry point — instantiates env, launches `run_env()` |

---

## Key e Concepts Demonstrated

### Temporal Control Methods (TCMs)
Methods that are time-aware. Declared with `@event` — they can `wait` for clock edges.
```e
drive_reset() @clk_rise is {
    rst_n_p$ = 0;
    wait [5];      -- wait 5 rising edges (SV equivalent: repeat(5) @posedge clk)
    rst_n_p$ = 1;
};
```

### Constraint-Driven Stimulus
```e
-- Default constraints on the struct
keep soft a in [0..255];
keep (op == SUB) => (b != 0);   -- hard constraint: no divide-by-zero equivalent

-- Per-call inline override in the sequence
gen pkt keeping { it.a == 0xFF; it.b == 0xFF; it.op == ADD; };
```

### Aspect-Oriented Programming (AOP)
Extend any unit from any file without modifying it — unique to e.
```e
extend alu_env_u {
    run_env() @evc.clk_rise is { ... };
};

extend sys {
    env : alu_env_u is instance;
    run() is also { start env.run_env(); };
};
```

### HDL Path Bindings
e connects to Verilog signals by path — no `interface` or `virtual interface` needed.
```e
keep clk_p.hdl_path()            == "top.alu.clk";
keep driver.rst_n_p.hdl_path()   == "top.alu.rst_n";
keep monitor.result_p.hdl_path() == "top.alu.result";
```

### Events and Reactive Blocks
```e
event clk_rise     is rise(clk_p$)              @sim;
event result_ready is true(done_p$ == 1) @clk_rise;

-- Fires automatically when result_ready occurs
on result_ready {
    sampled_op = monitor.last_op;
};
```

### Functional Coverage
```e
cover result_ready using per_unit_instance is {
    item op     : alu_op_t = sampled_op;
    item a_high : bool     = sampled_a_high using text = "a >= 128";
    cross op, a_high;    -- cross coverage: every op X every a_high combo
};
```

---

## Test Results

```
[DRV] op=ADD  a=0xcc b=0xda exp=0x1a6
[MON] result=0x1a6
[SCB] PASS | Exp: 0x1a6 | Got: 0x1a6
...
[DRV] op=ADD  a=0xff b=0xff exp=0x1fe   ← corner: max overflow
[SCB] PASS | Exp: 0x1fe | Got: 0x1fe
[DRV] op=SUB  a=0xe9 b=0xe9 exp=0x000  ← corner: subtract to zero
[SCB] PASS | Exp: 0x000 | Got: 0x000
[DRV] op=AND_OP a=0xd8 b=0x00 exp=0x000 ← corner: AND with zero
[SCB] PASS | Exp: 0x000 | Got: 0x000
[DRV] op=OR_OP  a=0x60 b=0xff exp=0x0ff ← corner: OR with 0xFF
[SCB] PASS | Exp: 0x0ff | Got: 0x0ff

24/24 transactions PASSED (20 random + 4 corner cases)
```

---

## How to Run

### EDA Playground
1. Go to [edaplayground.com](https://edaplayground.com) — free Google login, no license required
2. Set **Testbench + Design** → `Specman e + SV/Verilog`
3. Set **Simulator** → `Specman 2025.03`
4. Paste `testbench.e` into the left pane
5. Paste `design.sv` into the right pane
6. Click **Run**

### Cadence Xcelium (local)
```bash
xrun -Q -unbuffered -timescale 1ns/1ns -sysv -access +rw design.sv testbench.e
```

---

## Known Warnings (Safe to Ignore)

| Warning | Cause | Impact |
|---------|-------|--------|
| `DEPR_PORTS_UNIFICATION_DISABLED` | Three ports bound to `top.alu.clk` separately | Performance only — functionally correct |
| `WARN_VERILOG_WIRE_UNDEFINED` | Driver ports use deposit semantics on Verilog nets | Functionally correct for this design |

The `read_only` port-sharing pattern (`keep driver.clk_p == read_only(clk_p)`) causes a constraint elaboration error in Specman (`instances must be unique`) and cannot be used for `simple_port`. Each unit binds its own port independently — this is the correct approach.

---

## eRM vs SV/UVM Mapping

| eRM | SV/UVM Equivalent |
|-----|-------------------|
| `struct alu_packet_s` | `class ... extends uvm_sequence_item` |
| `unit alu_driver_u` | `class ... extends uvm_driver` |
| `unit alu_monitor_u` | `class ... extends uvm_monitor` |
| `unit alu_evc_u` | `class ... extends uvm_agent` |
| `unit alu_env_u` | `class ... extends uvm_env` |
| `keep` / `keep soft` | `constraint` / `soft constraint` |
| `gen pkt keeping { }` | `randomize() with { }` |
| `wait [N]` | `repeat(N) @(posedge clk)` |
| `all of { }` | `fork ... join` |
| `extend unit { }` | subclass override (less flexible) |
| `hdl_path()` | `virtual interface` |
| `dut_error()` | `` `uvm_error() `` |
| `stop_run()` | `$finish` |

---

## References

- [EDA Playground](https://edaplayground.com) — browser-based simulation, no install