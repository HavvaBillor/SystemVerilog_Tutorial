// ayrı olarak compile edilmesi lazım
// içerisindeki elemanlar kullanmadan compile edilmesi lazım
// function, task, parameter, struct, typedef

package uart_pkg;

  parameter DATA_WIDTH = 8;
  parameter FIFO_DEPTH = 16;


  // Testbench parametreleri
  parameter CLK_PERIOD = 10;  // 100mhz clock(10ns period)
  parameter BAUD_DIV = 104;
  parameter BAUD_CLK_PERIOD = BAUD_DIV * CLK_PERIOD;  // Divisor = Clk_freq / ( 16* baud_rate )

  // FSM tanımlamaları 
  typedef enum logic [1:0] {
    IDLE,
    SENDING_START,
    SENDING_DATA,
    SENDING_STOP
  } state_t;

  // import do not chain



  /*
  
  p1      p2      uart
  
  -p1'i p2 import
  -p2'yi uart import
  -uart p1'i göremez

  p1 ve p2 aynı parametreye sahipse mesela add_sum

  p1::*;
  p2::*;

  p2::add_sum;
  */

endpackage
