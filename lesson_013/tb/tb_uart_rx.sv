`timescale 1ns / 1ps


module tb_uart_rx;

  // Testbench parametreleri

  parameter FIFO_DEPTH = 8;
  parameter DATA_WIDTH = 8;
  parameter CLK_PERIOD = 10;
  parameter BAUD_DIV = 104;
  parameter BAUD_CLK_PERIOD = (BAUD_DIV * CLK_PERIOD);  // Divisor = Clk_freq / ( 16* baud_rate )
  parameter BAUD_CLK__HALF_PERIOD = (BAUD_DIV * CLK_PERIOD) / 2;

  // Test sinyalleri
  logic        clk_i = 0;
  logic        rst_ni;
  logic [15:0] baud_div_i;
  logic        rx_ren_i;
  logic        rx_en_i;
  logic        rx_bit_i;
  logic [ 7:0] dout_o;
  logic        empty_o;
  logic        full_o;


  // test verileri
  // Gönderilecek test verisi dizisi
  logic [ 7:0] test_data_array_tx[] = {'h41, 'h42, 'h43, 'h0A};  // test için gönderilecek veri "ABC\n"

  // alınan veriyi karşılaştırmak için kullanılacak FIFO
  logic [ 7:0] golden_model_fifo [$                                                                      ];

  //doğrulamak için kullanılacak sinyaller
  int          tx_data_index;
  int          rx_data_index;

  //DUT 

  uart_rx #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) dut (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .baud_div_i(baud_div_i),
      .rx_ren_i  (rx_ren_i),
      .rx_en_i   (rx_en_i),
      .rx_bit_i  (rx_bit_i),
      .dout_o    (dout_o),
      .empty_o   (empty_o),
      .full_o    (full_o)
  );

  // saat sinyali üreteci

  always #(CLK_PERIOD / 2) clk_i = ~clk_i;

  task send_byte(input logic [DATA_WIDTH-1:0] data);
    $strobe("Sending data 'h%0h = 'b%0b...", data, data);
    rx_bit_i = 0;
    #BAUD_CLK_PERIOD;

    for (int i = 0; i < DATA_WIDTH; ++i) begin
      rx_bit_i = data[i];
      #BAUD_CLK_PERIOD;
    end
    rx_bit_i = 1;
    #BAUD_CLK_PERIOD;
  endtask

  task read_and_verify();
    logic [7:0] received_data;
    logic [7:0] expected_data;

    rx_ren_i = 1;
    @(posedge clk_i);
    rx_ren_i = 0;

    @(posedge clk_i);
    received_data = dout_o;

    expected_data = golden_model_fifo.pop_front();

    if (received_data != expected_data) begin
      $display("ERROR: Data mismatch! Received 'h%0h, but expected 'h%0d", received_data, expected_data);
      $finish;
    end else begin
      $display("INFO: Data received  succesfully: 'h%0h", received_data);
    end
  endtask

  initial begin

    $display("INFO: Starting UART RX Testbench...");

    //basşlangıç değerleri
    baud_div_i <= BAUD_DIV;
    rx_ren_i   <= 0;
    rx_en_i    <= 0;
    rx_bit_i   <= 1'b1;  // hattı idle drumuna getir

    // reset
    rst_ni <= 0;
    repeat (2) @(posedge clk_i);
    rst_ni  <= 1;

    // rx alımını başlat
    rx_en_i <= 1;

    //TX'den test verilerini gönder ve golden model fifo ya kaydet
    $display("INFO: Sending test data via simulated TX...");
    for (tx_data_index = 0; tx_data_index < test_data_array_tx.size(); tx_data_index++) begin
      //veriyi golden model fifo ya ekle
      golden_model_fifo.push_back(test_data_array_tx[tx_data_index]);
      //UART bitlerini gönder
      send_byte(test_data_array_tx[tx_data_index]);
    end

    $display("INFO: All data sent. Waiting for DUT to receive...");

    //DUT nin tüm verileri almasını bekle
    wait (empty_o == 0);  // FIFO da en az bir veri dolana kadar bekle

    //FIFO boşalana kadar okuma ve doğrulama
    while (golden_model_fifo.size() > 0) begin
      read_and_verify();
      @(posedge clk_i);
    end

    $display("INFO: All data received and verified. FIFO is empty");

    //boş bir transfer  yapıdığında da IDLE 'a dönüp dönmediğini kontrol et
    $display("INFO: Sending one more byte to test the end-to-end logic");
    send_byte('h5A);
    golden_model_fifo.push_back('h5A);

    wait (empty_o == 0);
    @(posedge clk_i);

    read_and_verify();

    //son bir süre bekleme
    #100ns;

    $display("INFO: Test finished successfully");
    $finish;
  end

endmodule
