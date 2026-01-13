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
    output logic [ 7:0] empty_o,
    output logic [ 7:0] full_o,
    output logic [ 7:0] tx_bit_o
);

  logic        rd_en;
  logic [ 7:0] data;
  logic [ 9:0] frame;  // start ve stop biti için 10 bitlik bir frame
  logic [ 3:0] bit_counter;  // kaç tane bit gönderdiğimizi sayması için
  logic        baud_clk;
  logic [15:0] baud_counter;  // divider ile aynı genişlikte

  wbit_fifo#(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) (
      .clk(clk_i), .rst(!rst_ni), .wr_en(tx_wen_i), .rd_en(rd_en), .wdata(din_i), .rdata(data), .full(full_o), .empty(empty_o)

  );  // rst_ni tersini verdik çünkü wbit_fifo da senkron 

  enum logic [1:0] {
    IDLE,
    LOAD,
    SENDING
  }
      state, nextstate;

  always_comb begin
    nextstate = state;
    case (state)
      IDLE:    if (tx_en_i && !empty_o) nextstate = LOAD;
      LOAD:    nextstate = SENDING;
      SENDING: if (bit_counter == 4'd9) nextstate = (tx_en_i && !empty_o) ? SENDING : IDLE;
    endcase
    frame = {1'b0, data, 1'b1};
    tx_bit_o = state == SENDING ? frame[bit_counter] : '1;
    rd_en = state == LOAD;
  end



  always_ff @(posedge clk_i) begin

    if (!rst_ni) begin
      state <= IDLE;
      bit_counter <= '0;
      baud_counter <= '0;
      baud_clk <= '0;
    end else begin

      // baud_clk generator

      if (tx_en_i) begin
        if (baud_counter == baud_div_i - 16'b1) begin
          baud_clk <= 1;
          baud_counter <= '0;
        end else begin
          baud_clk <= 0;
          baud_counter <= baud_counter + 1;
        end

      end else begin
        baud_clk <= 0;
        baud_counter <= '0;
      end

      //bit_counter

      if (baud_clk) begin
        // eklenecekler var 
        bit_counter = (state == SENDING && bit_counter != 4'd9) ? bit_counter + 1 : 0;
      end

    end

  end

endmodule
