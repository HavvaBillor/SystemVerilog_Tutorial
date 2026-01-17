
// interface kendi port larına shaip olabilir
interface uart_if #(
    parameter BAUD_DIV = 104

) (
    input logic clk_i
);

  // interface ayrı bir dosyada tanımlanmalı ve ayrı bir dosyada compile edilmeli
  logic        rst_ni;
  logic [15:0] baud_div_i;
  logic        tx_wen_i;
  logic        tx_en_i;
  logic [ 7:0] din_i;
  logic        empty_o;
  logic        full_o;
  logic        tx_bit_o;


  // modport

  modport master(output baud_div_i, output tx_wen_i);
  modport slave(input rst_ni, input baud_div_i, input tx_wen_i, input tx_en_i, input din_i, output empty_o, output full_o, output tx_bit_o, import rst_signals);
  // task, function, initial, always bloğu gibi bloklar içerebilir



  task rst_signals();  // sıfırlama task ı 
    rst_ni     <= 0;
    tx_en_i    <= 0;
    tx_wen_i   <= 0;
    din_i      <= 0;
    baud_div_i <= BAUD_DIV;
  endtask

  // array olarak da örnekleyebilirsiniz
  // bir interface içerisinde başka interface de örneklenebilir
  // assign ataması kullanılabilir
  // assertion yazılabilir

endinterface
