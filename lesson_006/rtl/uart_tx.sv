`timescale 1ns / 1ps

/*
    Baud Rate= Clock frequency / (16 * divisor)

    clock frequency: UART'ın beslediği saat sinyali (örneğin 16 MHz)

    Divisor: Baud rate oluşturmak için kullanılan bölücü değeri

    16: UART'larda genellikle kullanılan oversampling oranıdır

    Divisor: 16_000_000 / ( 16 * 9600 ) = 104.1667 = 104 

*/

module uart_tx #(
    parameter DATA_WIDTH,
    parameter FIFO_DEPTH
) (

    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [15:0] baud_div_i,
    input  logic        tx_wen_i,    // write enable
    input  logic        tx_en_i,     // haberleşme enable
    input  logic [ 7:0] din_i,       // 8 bitlik data input
    output logic        empty_o,
    output logic        full_o,
    output logic        tx_bit_o
);

  // dahili sinyaller 
  logic        rd_en;
  logic [ 7:0] data;
  logic [ 7:0] data_q;  // data nın register dan geçirilmiş hali
  logic [ 3:0] bit_counter;  // kaç tane bit gönderdiğimizi sayması için
  logic        baud_clk;
  logic [15:0] baud_counter;  // divider ile aynı genişlikte

  // FSM tanımlamaları 
  typedef enum logic [1:0] {
    IDLE,
    SENDING_START,
    SENDING_DATA,
    SENDING_STOP
  } state_t;

  state_t state, nextstate;

  // fifo modülü 
  wbit_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) uut (
      .clk  (clk_i),
      .rst  (!rst_ni),
      .wr_en(tx_wen_i),
      .rd_en(rd_en),
      .wdata(din_i),
      .rdata(data),
      .full (full_o),
      .empty(empty_o)

  );  // rst_ni tersini verdik çünkü wbit_fifo da senkron 

  always_comb begin
    nextstate = state;
    rd_en     = 1'b0;

    case (state)

      // fifo da veri varsa ve tx_en ise sonraki state a geç
      IDLE: begin
        if (tx_en_i && !empty_o) begin
          nextstate = SENDING_START;  // sonraki cycle state SENDING_START , rd_en burada 1 yaptığımız için verisi okunmuş olacak
          rd_en = 1'b1;  // veriyi fifo dan oku
        end
      end
      SENDING_START: begin
        // ilk bit start biti gönderildikten sonra veri bitlerini göndermeye başla
        if (baud_counter == baud_div_i - 16'b1) begin  // bir UART bit süresinin tamamlandı mı?
          nextstate = SENDING_DATA;
        end
      end
      SENDING_DATA: begin
        // 8 veri bitinin tamamı gönderildiğinde stop bitini göndermeye başla
        if (baud_counter == baud_div_i - 16'b1 && (bit_counter == 7)) begin
          nextstate = SENDING_STOP;
        end
      end
      SENDING_STOP: begin
        // stop biti gönderildiğinde, IDLE durumuna dön veya yeni veri varsa tekrar başlat
        if (baud_counter == baud_div_i - 16'b1) begin
          if (tx_en_i && !empty_o) begin
            nextstate = SENDING_START;
            rd_en = 1'b1;
          end else begin
            nextstate = IDLE;
            rd_en = 1'b0;
          end
        end
      end
    endcase

    // TX pin çıkışı

    case (state)
      IDLE:          tx_bit_o = 1'b1;
      SENDING_START: tx_bit_o = 1'b0;
      SENDING_DATA:  tx_bit_o = data_q[bit_counter];
      SENDING_STOP:  tx_bit_o = 1'b1;
    endcase
  end

  // fsm nin ardışıl ( sequential) mantığı
  always_ff @(posedge clk_i) begin

    if (!rst_ni) begin
      state        <= IDLE;
      bit_counter  <= 4'd0;
      baud_counter <= 16'd0;
      data_q       <= '0;
    end else begin
      state <= nextstate;

      // baud rate ayarı
      if (state != IDLE) begin
        if (baud_counter == baud_div_i - 1) begin
          baud_counter <= 0;
        end else begin
          baud_counter <= baud_counter + 1;
        end
      end else begin
        bit_counter <= 0;
      end

      // bit sayacı ve frame yönetimi

      if (baud_counter == baud_div_i - 1) begin

        case (state)

          IDLE: begin
            bit_counter <= 0;
          end
          SENDING_START: begin
            bit_counter <= 0;
            data_q <= data;
          end
          SENDING_DATA: begin
            if (bit_counter == 7) begin
              bit_counter <= 0;
            end else begin
              bit_counter <= bit_counter + 1;
            end
          end
          SENDING_STOP: begin
            bit_counter <= 0;
          end
        endcase
      end
    end
  end

endmodule
