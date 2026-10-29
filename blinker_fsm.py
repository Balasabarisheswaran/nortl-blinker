from nortl import Engine, Const

engine = Engine("blinker")

start = engine.define_input("start", width=1)
led = engine.define_output("led", width=1, reset_value=0)
busy = engine.define_output("busy", width=1, reset_value=0)

N_BLINKS = 4
ON_CYCLES = 3

with engine.while_loop(Const(True)):
    engine.wait_for(start == 1)
    engine.set(busy, 1)
    with engine.for_loop(0, N_BLINKS) as i:
        engine.set(led, 1)
        with engine.for_loop(0, ON_CYCLES):
            engine.sync()
        engine.set(led, 0)
        with engine.for_loop(0, ON_CYCLES):
            engine.sync()
    engine.set(busy, 0)
    engine.wait_for(start == 0)

sv = engine.to_verilog()
with open("blinker.sv", "w") as f:
    f.write(sv)
