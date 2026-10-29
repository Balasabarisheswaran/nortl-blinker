`timescale 1ns/1ps
module tb_blinker;
  logic clk = 0, rst = 1, start = 0;
  logic led, busy;

  blinker dut (.CLK_I(clk), .RST_ASYNC_I(rst), .start(start), .led(led), .busy(busy));

  always #5 clk = ~clk;   // 100 MHz clock

  integer rises = 0, on_cycles = 0;
  logic led_d = 0;
  integer len = 0;
  always @(posedge clk) begin
    if (led && !led_d) rises++;
    if (led) begin on_cycles++; len++; end
    else if (led_d) begin $display("LED pulse of %0d cycles", len); len = 0; end
    led_d <= led;
  end

  initial begin
    $dumpfile("blinker.vcd");
    $dumpvars(0, tb_blinker);
    #22 rst = 0;
    @(posedge clk); start = 1;   // press start
    @(posedge busy);             // sequence started
    @(negedge busy);             // sequence finished
    start = 0;                   // release
    repeat (20) @(posedge clk);
    $display("LED pulses: %0d (expected 4)", rises);
    $display("LED-on clock cycles total: %0d", on_cycles);
    if (rises == 4) $display("PASS"); else $display("FAIL");
    $finish;
  end
endmodule
