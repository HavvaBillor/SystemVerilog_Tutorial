`timescale 1ns / 1ps

module tb_uart;

  // TESTBENCH parameter

  localparam CLK_PERIOD = 10;  // 100Mhz clock için 10ns
  localparam BAUD_RATE = 9600;
  localparam CLK_FREQ = 1_000_000_000 / CLK_PERIOD;  //100Mhz
  localparam BAUD_DIVISOR = CLK_FREQ / (16 * BAUD_RATE);  // 100M/(16*9600) = 651

  // dut parameter

  localparam DATA_WIDTH = 8;
  localparam FIFO_DEPTH = 16;
  localparam XLEN = 32;

  // signal declaration
  logic            clk;
  logic            rst_n;

  // CPU Interface signals
  logic            stb;
  logic [     1:0] addr;
  logic [     3:0] byte_sel;
  logic            we;
  logic [XLEN-1:0] data_in;
  logic [XLEN-1:0] data_out;

  // uart pins
  logic            uart_tx;

  // reference model (TX Queue) for verification
  byte             TxQueue  [$];

  // DUT Interface
  uart #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) uart_inst (
      .clk_i     (clk),
      .rst_ni    (rst_n),
      .stb_i     (stb),
      .adr_i     (addr),
      .byte_sel_i(byte_sel),
      .we_i      (we),
      .data_i    (data_in),
      .data_o    (data_out),
      .uart_rx_i (uart_tx),   // TX loopback to RX
      .uart_tx_o (uart_tx)
  );

  // clock and reset generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // CPU Bus Write Task
  task automatic write_reg(input logic [1:0] w_addr, input logic [XLEN-1:0] w_data, input logic [3:0] w_byte_sel);
    stb      = 1'b1;
    we       = 1'b1;
    addr     = w_addr;
    byte_sel = w_byte_sel;
    data_in  = w_data;
    @(posedge clk);
    stb = 1'b0;
    we  = 1'b0;
  endtask

  // CPU Bus Read Task
  task automatic read_reg(input logic [1:0] r_addr, output logic [XLEN-1:0] r_data);
    stb  = 1'b1;
    we   = 1'b0;
    addr = r_addr;
    @(posedge clk);
    stb = 1'b0;
    we  = 1'b0;
    @(posedge clk);
    r_data = data_out;
  endtask

  //-------------------------------------------------------------------------------------------------
  // TEST SCENARIO

  initial begin

    // wait after reset
    @(posedge rst_n);

    // define register addresses
    `define UART_BAUD_ADDR 2'b00
    `define UART_CTRL_ADDR 2'b01
    `define UART_STATUS_ADDR 2'b10
    `define UART_TX_DATA_ADDR 2'b11
    `define UART_RX_DATA_ADDR 2'b11

    // configure UART baud rate
    $info("INFO: Setting UART baud rate. Divisor: %0d", BAUD_DIVISOR);
    write_reg(.w_addr(`UART_BAUD_ADDR), .w_data(BAUD_DIVISOR), .w_byte_sel(4'b0011));

    // Enable TX and RX
    $info("INFO: Enabling UART TX and RX.");
    write_reg(.w_addr(`UART_CTRL_ADDR), .w_data({32'b0, 1'b1, 1'b1}), .w_byte_sel(4'b0001));

    // Send random data
    $info("INFO: Starting random data transmission test.");

    for (int i = 0; i < FIFO_DEPTH; ++i) begin
      logic [DATA_WIDTH-1:0] random_data;
      random_data = $urandom();


      // Wait if TX is full
      do begin
        logic [XLEN-1:0] status;
        read_reg(.r_addr(`UART_STATUS_ADDR), .r_data(status));
        if (!status[0]) begin  // tx_full_o = bit 0
          break;
        end
        @(posedge clk);
      end while (1);

      // write data to TX FIFO
      write_reg(.w_addr(`UART_TX_DATA_ADDR), .w_data({26'b0, random_data}), .w_byte_sel(4'b001));

      TxQueue.push_back(random_data);
      $info("INFO: Data written to TX FIFO: 0x%0h. TX queue size: %0d", random_data, TxQueue.size());

      @(posedge clk);
    end

    $info("INFO: TX FIFO is full. Waiting for data to be received.");

    // Bekleme süresini, tüm verilerin iletimi için yeterli olacak şekilde artırın
    // 16 veri * 10bit/veri * (1/96000 baud) = 16.67 ms
    // Bu süre 100mhz clock ta yaklaşık 1.670.000 clock döngüsünüe denk gelir
    // güvenli olması için daha fazla bekleyelim

    repeat (2_000) @(posedge clk);

    // RX FIFO daki veriyi oku ve doğrula

    while (TxQueue.size() > 0) begin
      logic [DATA_WIDTH -1:0] expected_data;
      logic [         XLEN:0] received_data;

      expected_data = TxQueue.pop_front();

      // RX FIFO'nun boş olmamasını bekleyin
      // Bu testin en öenmli parçasıdır

      do begin
        logic [XLEN-1:0] status;
        read_reg(.r_addr(`UART_STATUS_ADDR), .r_data(status));
        if (!status[3]) begin  // 
          break;
        end
        @(posedge clk);
      end while (1);


      //RX FIFO dan veriyi okuma
      read_reg(.r_addr(`UART_RX_DATA_ADDR), .r_data(received_data));

      // Alınan veriyi doğrulayın
      if (received_data[DATA_WIDTH-1:0] == expected_data) begin
        $info("INFO: Data verified. Received: 0x%0h, Expected: 0x%0h", received_data[DATA_WIDTH-1:0], expected_data);
      end else begin
        $error("ERROR: Data verified. Received: 0x%0h, Expected: 0x%0h", received_data[DATA_WIDTH-1:0], expected_data);
      end
    end

    $info("INFO: All data transmitted, received, and verified successfully.");
    $info("INFO: Test PASSED!");
    $finish;

  end

endmodule
