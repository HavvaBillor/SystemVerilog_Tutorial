`timescale 1ns / 1ps

module tb_uart_tx;

  // Testbench parametreleri

  parameter FIFO_DEPTH = 8;
  parameter DATA_WIDTH = 8;
  parameter CLK_PERIOD = 10;
  parameter BAUD_DIV = 104;
  parameter BAUD_CLK_PERIOD = BAUD_DIV * CLK_PERIOD;  // Divisor = Clk_freq / ( 16* baud_rate )

  // Test sinyalleri
  // -------
  // Interface örnekle
  logic clk_i;
  uart_if #(BAUD_DIV) uart_if (.clk_i(clk_i));

  // test verileri
  logic [7:0] test_data_array[] = {'h41, 'h42, 'h43, 'h0A};  // test için gönderilecek veri "ABC\n"
  // doğrulama için kullanılacak sinyaller
  logic [3:0] bit_counter;
  logic [9:0] expected_frame;

  // DUT (device under test)
  uart_tx #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
      .clk_i     (clk_i),
      .uart_tx_if(uart_if.slave)  // pass a port bus
  );


  // saat sinyali üreteci
  initial begin
    clk_i = 0;
  end
  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // gönderim fonksiyonları

  // fifo ya tek bir byte yazma

  task write_fifo(input logic [7:0] data);
    $strobe("writing data: %0b to FIFO...", data);
    uart_if.tx_wen_i = 1;
    uart_if.din_i = data;
    @(posedge clk_i);
    uart_if.tx_wen_i = 0;
    @(posedge clk_i);
  endtask


  // uart bitleribi okumak ve doğrulamak için bir göre

  task verify_tx_bit(input logic expected_bit, input int bit_index);
    @(negedge clk_i);
    if (expected_bit !== uart_if.tx_bit_o) begin
      $display("ERROR: TX bit verification failed! At bit %0d, expected: %0b, but got: %0b", bit_index, expected_bit, uart_if.tx_bit_o);
    end else begin
      $display("INFO: TX bit verification successful.  bit %0d   is: %0b", bit_index, uart_if.tx_bit_o);
    end
  endtask

  // test senaryosu

  initial begin

    $display("INFO: Starting UART TX Testbench");

    // başlangıç değerleri
    uart_if.rst_signals();
    repeat (2) @(posedge clk_i);
    uart_if.rst_ni <= 1;

    // fifo ya tüm test verilerini yazdırma

    $display("INFO: writing test data to FIFO");
    for (int i = 0; i < test_data_array.size(); ++i) begin
      write_fifo(test_data_array[i]);
    end

    // gönderimi başlatma 

    $display("INFO: Enabling TX and starting transmission");
    uart_if.tx_en_i <= 1;

    for (int i = 0; i < test_data_array.size(); ++i) begin
      @(posedge clk_i);
      expected_frame = {1'b1, test_data_array[i], 1'b0};

      $display("INFO: Verifying start bit");
      verify_tx_bit(expected_frame[0], 0);

      for (bit_counter = 1; bit_counter < 9; bit_counter++) begin
        #BAUD_CLK_PERIOD;
        verify_tx_bit(expected_frame[bit_counter], bit_counter);
      end

      #BAUD_CLK_PERIOD;
      $display("INFO: Verifying stop bit");
      verify_tx_bit(expected_frame[9], 9);

      #BAUD_CLK_PERIOD;

    end

    wait (uart_if.empty_o && bit_counter == 9);
    #100ns;
    $display("INFO: All data transmitted. Waiting for final state...");
    $finish;

  end

endmodule
