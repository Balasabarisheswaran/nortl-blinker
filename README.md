# nortl-blinker

A small start-triggered LED blinker written in Python with [noRTL](https://github.com/imms-ilmenau/nortl) and rendered to SystemVerilog.

## What it does
- Waits until `start` goes high.
- Sets `busy` high and blinks `led` **4 times** (`N_BLINKS`).
- Clears `busy`, then waits until `start` goes low again, so one press gives exactly one sequence.
- Repeats forever.

The FSM is described with nested `for_loop`s and `wait_for` calls. No states are declared by hand: noRTL derives them (21 states here) from the program flow.

## Files
| File | Purpose |
|------|---------|
| `blinker_fsm.py` | noRTL description of the FSM; generates `blinker.sv` |
| `blinker.sv` | Generated SystemVerilog (module `blinker`) |
| `tb_blinker.sv` | Self-checking testbench for Icarus Verilog |

## Run it
```bash
pip install nortl                  # Python 3.12+
python blinker_fsm.py              # writes blinker.sv
iverilog -g2012 -o sim blinker.sv tb_blinker.sv
vvp sim                            # prints PASS/FAIL, writes blinker.vcd
```
Open `blinker.vcd` in GTKWave to see the waveform.

## Simulation result
```
LED pulse of 15 cycles   (x4)
LED pulses: 4 (expected 4)
PASS
```

## What I learned
`ON_CYCLES = 3` does **not** give a 3-cycle pulse. In simulation each LED pulse lasts 15 clock cycles, because every hardware loop iteration also spends states on incrementing and comparing its counter. The Python code describes *structure*; exact timing has to be checked in simulation. A next step is a cycle-exact delay (for example a single counter instead of a loop of `sync()` calls).
