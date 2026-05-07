<'

-- ================================================= --
--   alu_scoreboard.e : Scoreboard for TB
-- ================================================= --

unit alu_scoreboard_u {

  -- reference to monitor
  monitor: alu_monitor_u;
  
  -- expected results queue
  !expected_q: list of alu_packet_s;
  
  -- method for creating expected results
  -- called before driving stimulus to DUT
  push_expected(pkt: alu_packet_s) is {
    expected_q.add(pkt);
  };
  
  -- TCM: run in a loop, check every result
  run() @monitor.clk_p$ is {
    while TRUE {
      -- block until monitor sees a result
      wait @monitor.result_ready;

      var actual: uint (bits: 9) = monitor.last_result;

      if expected_q.size() == 0 {
        dut_error("[SCB] Received result but expected queue is empty!");
      } else {
        var exp : alu_packet_s = expected_q.pop();

        if actual != exp.expected_result {
          dut_error("[SCB]", "TEST FAILED | Expected: 0x%0x | Actual: 0x%0x", exp.expected_result, actual);
        } else {
          out("[SCB]", "TEST PASS | Expected: 0x%0x | Actual: 0x%0x", exp.expected_result, actual);
        };
      };  
    };
  };
  

}; -- alu_scoreboard_u

'>