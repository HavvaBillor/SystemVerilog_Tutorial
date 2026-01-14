`timescale 1ns / 1ps

module tb_uart_tx;

  // Testbench parametreleri

  parameter FIFO_DEPTH = 8;
  parameter DATA_WIDTH = 8;
  parameter CLK_PERIOD = 10;
  parameter BAUD_DIV = 104;
  parameter BAUD_CLK_PERIOD = BAUD_DIV * CLK_PERIOD;  // Divisor = Clk_freq / ( 16* baud_rate )

  // Test sinyalleri
  logic        clk_i;
  logic        rst_ni;
  logic [15:0] baud_div_i;
  logic        tx_wen_i;
  logic        tx_en_i;
  logic [ 7:0] din_i;
  logic        empty_o;
  logic        full_o;
  logic        tx_bit_o;

  // test verileri
  logic [ 7:0] test_data_array[] = {'h41, 'h42, 'h43, 'h0A};  // test için gönderilecek veri "ABC\n"
  // doğrulama için kullanılacak sinyaller
  logic [ 3:0] bit_counter;
  logic [ 9:0] expected_frame;

  // DUT (device under test)
  uart_tx #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .baud_div_i(baud_div_i),
      .tx_wen_i  (tx_wen_i),
      .tx_en_i   (tx_en_i),
      .din_i     (din_i),
      .empty_o   (empty_o),
      .full_o    (full_o),
      .tx_bit_o  (tx_bit_o)
  );


  // saat sinyali üreteci
  initial clk_i = 0;
  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  // gönderim fonksiyonları

  // fifo ya tek bir byte yazma

  task write_fifo(input logic [7:0] data);
    $strobe("writing data: %0b to FIFO...", data);
    tx_wen_i = 1;
    din_i = data;
    @(posedge clk_i);
    tx_wen_i = 0;
    @(posedge clk_i);
  endtask


  // uart bitleribi okumak ve doğrulamak için bir göre

  task verify_tx_bit(input logic expected_bit, input int bit_index);
    @(negedge clk_i);
    if (expected_bit !== tx_bit_o) begin
      $display("ERROR: TX bit verification failed! At bit %0d, expected: %0b, but got: %0b", bit_index, expected_bit, tx_bit_o);
    end else begin
      $display("INFO: TX bit verification successful.  bit %0d   is: %0b", bit_index, tx_bit_o);
    end
  endtask

  // test senaryosu

  initial begin

    $display("INFO: Starting UART TX Testbench");

    // başlangıç değerleri
    tx_en_i    <= 0;  // hepsini aynı anda atamak istedeğimiz için non-blocking atama yaptık
    tx_wen_i   <= 0;
    din_i      <= 0;
    baud_div_i <= BAUD_DIV;

    // reset durumu
    rst_ni     <= 0;
    repeat (2) @(posedge clk_i);
    rst_ni <= 1;

    // fifo ya tüm test verilerini yazdırma

    $display("INFO: writing test data to FIFO");
    for (int i = 0; i < test_data_array.size(); ++i) begin
      write_fifo(test_data_array[i]);
    end

    // gönderimi başlatma 

    $display("INFO: Enabling TX and starting transmission");
    tx_en_i <= 1;

    for (int i = 0; i < test_data_array.size(); ++i) begin
      @(posedge clk_i);
      expected_frame = {1'b1, test_data_array[i], 1'b0};

      $display("INFO:Verifying start bit");
      verify_tx_bit(expected_frame[0], 0);

      for (bit_counter = 1; bit_counter < 9; bit_counter++) begin
        #BAUD_CLK_PERIOD;
        verify_tx_bit(expected_frame[bit_counter], bit_counter);
      end

      #BAUD_CLK_PERIOD;
      $display("INFO:Verifying stop bit");
      verify_tx_bit(expected_frame[9], 9);

      #BAUD_CLK_PERIOD;

    end

    wait (empty_o && bit_counter == 9);
    #100ns;
    $display("INFO:All data transmitted. Waiting for final state...");
    $finish;

  end

endmodule
