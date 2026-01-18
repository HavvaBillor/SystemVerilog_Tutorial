module uart #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
) (
    input  logic        clk_i,       // sistem saat girişi
    input  logic        rst_ni,      // asenkron aktif düşük reset
    input  logic        stb_i,       // işlemci veriyolu (bus) strobe sinyali
    input  logic [ 1:0] adr_i,       // işlemci tarafından seçilen register adresi
    input  logic [ 3:0] byte_sel_i,  // hangi byte ların yazılacağını belirler
    input  logic        we_i,        // yazma etkinleştirme sinyali
    input  logic [31:0] data_i,      // işlemciden gelen veri
    output logic [31:0] data_o,      // işlemciye gönderilen veri
    input  logic        uart_rx_i,   // gelen veri uart hattı
    output logic        uart_tx_o    // giden veri uart hattı
);

  // Dahili sinyaller

  logic                                                                                                               [          15:0] baud_div_reg;  // baud rate bölücü değeri     
  logic                                                                                                                                tx_en_reg;  // tx modülü etkinleştirme    
  logic                                                                                                                                rx_en_reg;  // rx modülü etkinleştirme    
  logic                                                                                                                                tx_full_o;  // tx FIFO dolu     
  logic                                                                                                                                rx_full_o;  // rx FIFO dolu   
  logic                                                                                                                                tx_empty_o;  // tx FIFO boş   
  logic                                                                                                                                rx_empty_o;  // rx FIFO boş   
  logic                                                                                                                                rx_frame_error;  // rx framing hatası  
  logic                                                                                                                                tx_wen;  // tx FIFO write enable
  logic                                                                                                                                rx_ren;  // rx FIFO read enable
  logic                                                                                                               [DATA_WIDTH-1:0] dout_0;  // rx FIFO çıkışı
  logic                                                                                                               [          31:0] rdata;
  logic                                                                                                                                rd_state;

  // adres tanımlamaları
  enum logic [1:0] {UART_BAUD_ADDR = 2'b00, UART_CTRL_ADDR = 2'b01, UART_STATUS_ADDR = 2'b10, UART_DATA_ADDR = 2'b11}                  uart_reg_e;

  // tx module
  uart_tx #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) uart_tx_inst (

      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .baud_div_i(baud_div_reg),
      .tx_wen_i  (tx_wen),
      .tx_en_i   (tx_en_reg),
      .din_i     (data_i[DATA_WIDTH-1:0]),
      .empty_o   (tx_empty_o),
      .full_o    (tx_full_o),
      .tx_bit_o  (uart_tx_o)
  );

  // tx module
  uart_rx #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) uart_rx_inst (

      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .baud_div_i(baud_div_reg),
      .rx_ren_i  (rx_ren),
      .rx_en_i   (rx_en_reg),
      .dout_o    (dout_0),
      .empty_o   (rx_empty_o),
      .full_o    (rx_full_o),
      .rx_bit_i  (uart_rx_i)
  );

  // Register yazma kısmı

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      baud_div_reg <= 16'd0;
      tx_en_reg    <= 1'b0;
      rx_en_reg    <= 1'b0;
    end else if (stb_i && we_i) begin
      unique case (adr_i)
        UART_BAUD_ADDR: begin
          if (byte_sel_i[0] || byte_sel_i[1]) baud_div_reg <= data_i[15:0];
        end
        UART_CTRL_ADDR: begin
          if (byte_sel_i[0]) begin
            tx_en_reg <= data_i[0];
            rx_en_reg <= data_i[1];
          end
        end
        default: ;  // no other registers writable
      endcase
    end
  end

  // FIFO control combinational block

  always_comb begin
    tx_wen = 1'b0;
    rx_ren = 1'b0;

    if (stb_i) begin
      unique case (adr_i)
        UART_DATA_ADDR: begin
          if (we_i) begin
            // tx write
            tx_wen = ~tx_full_o;
          end else begin
            // rx read
            rx_ren = ~rx_empty_o;
          end
        end
        default: ;
      endcase
    end
  end

  // okuma verisi (senkron, stabil tutma)
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      rdata <= '0;
      rd_state <= '0;  // fifo ya okuma isteği atanıyor ama bir clock sonra veriyi elde ediyorsunuz o yüzden
    end else begin
      //varsayılan önceki değeri koru
      rdata <= rdata;
      rd_state <= stb_i && adr_i == UART_DATA_ADDR && !we_i;
      if (stb_i) begin
        unique case (adr_i)
          UART_BAUD_ADDR:   rdata <= {16'b0, baud_div_reg};
          UART_CTRL_ADDR:   rdata <= {29'b0, rx_en_reg, tx_en_reg};
          UART_STATUS_ADDR: rdata <= {27'b0, rx_frame_error, rx_empty_o, rx_full_o, tx_empty_o, tx_full_o};
          default:          rdata <= '0;
        endcase
      end
    end
  end

  assign data_o = rd_state ? {{(32 - DATA_WIDTH) {1'b0}}, dout_0} : rdata;

endmodule
