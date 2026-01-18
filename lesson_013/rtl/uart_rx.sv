
module uart_rx #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
) (
    input logic        clk_i,       // sistem saat girişi
    input logic        rst_ni,      // asenkron aktif-düşük reset sinyali
    input logic [15:0] baud_div_i,  // baud-rate bölücü
    input logic        rx_ren_i,    // FIFO'dan okuma etkinleştirme
    input logic        rx_en_i,     // haberleşme enable
    input logic        rx_bit_i,    // Gelen seri data hattı

    output logic [DATA_WIDTH-1:0] dout_o,   // FIFO dan okunan veri çıkışı
    output logic                  empty_o,  // FIFO boş mu 
    output logic                  full_o    // FIFO dolu mu
);

  localparam COUNTER_WIDTH = $clog2(DATA_WIDTH + 1);

  // dahili sinyaller 
  logic                      rx_we;  // FIFO'ya yazma etkinleştirme
  logic [   DATA_WIDTH -1:0] rx_data_reg;  // gelen veri bitlerinin geçici olarak tutulduğu register
  logic [COUNTER_WIDTH -1:0] bit_counter;  // alınan bit sayacını tutar
  logic [              15:0] baud_counter;  // her bit periyodunu sayan sayaç


  // FSM tanımlamaları
  typedef enum logic [2:0] {
    IDLE,
    START_BIT,
    DATA_BITS,
    STOP_BIT
  } state_t;
  state_t state, next_state;

  logic mid_tick;
  logic end_tick;

  assign mid_tick = (baud_counter == (baud_div_i >> 1) - 1);  // 1 bit sağa shift etmek 2 ye bölmek demek ya o yüzden 
  assign end_tick = (baud_counter == baud_div_i - 1);

  //FIFO module
  wbit_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) rx_buffer (
      .clk  (clk_i),
      .rst  (!rst_ni),
      .wr_en(rx_we),
      .rd_en(rx_ren_i),
      .wdata(rx_data_reg),
      .rdata(dout_o),
      .full (full_o),
      .empty(empty_o)
  );

  //FIFO ya yazma etkinleştirme sinyali
  assign rx_we = (state == STOP_BIT) && end_tick;


  // FSM combinational logic
  always_comb begin
    next_state = state;

    case (state)

      IDLE: begin
        if (rx_en_i && !rx_bit_i && !full_o) begin  // rx_bit_i low yani 0 olunca start biti geldiğinde
          next_state = START_BIT;
        end
      end
      START_BIT: begin
        if (mid_tick) begin  // verinin ortasında
          if (!rx_bit_i) begin
            next_state = DATA_BITS;
          end else begin
            next_state = IDLE;
          end
        end
      end
      DATA_BITS: begin
        if (mid_tick && (bit_counter == DATA_WIDTH - 1)) begin
          next_state = STOP_BIT;
        end
      end
      STOP_BIT: begin
        if (mid_tick) begin
          if (rx_bit_i == 1'b1) begin  // stop biti 1 ya 
            next_state = IDLE;
          end
        end
      end
    endcase
  end



  // FSM sequantial logic
  always_ff @(posedge clk_i) begin

    if (!rst_ni) begin
      state        <= IDLE;
      baud_counter <= '0;
      bit_counter  <= '0;
      rx_data_reg  <= '0;
    end else begin
      state <= next_state;

      // BAUD sayacı
      if (state == IDLE || end_tick) begin
        baud_counter <= '0;
      end else begin
        baud_counter = baud_counter + 1'b1;
      end
    end

    // örnekleme bit sayacı
    if (mid_tick) begin
      if (state == DATA_BITS) begin
        rx_data_reg[bit_counter] <= rx_bit_i;
        if (bit_counter < DATA_WIDTH - 1) begin
          bit_counter <= bit_counter + 1'b1;
        end
      end else if (state == START_BIT) begin
        bit_counter <= '0;
      end
    end
  end


endmodule
