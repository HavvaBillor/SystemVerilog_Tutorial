
module tb_task_function;

  /*
    -----------TASK-------------------
    - istenilen sayı kadar input output inout portunu destekler
    - ANSI-C olabilir
    - Timing içerebilir (@, wait, #10)
    - blocking ve non-blocking kullanılabilir
*/

  task adder_task(input [3:0] a, input [3:0] b, output integer result);
    // input a, input b, output sum, output carry
    begin
      result = a + b;
      $display("A: %0d, B: %0d, Result: %0d", a, b, result);
    end
  endtask

  /* 
    ---------FUNCTION-----------------
    - istenilen sayı kadar input sadece ANSI-C still
    - Timing içeremez
    - Function 0 zamanda tamamlanmalı
    - Tek bir değer return edebilir. Vector, integer ya da real
    - output ya da inout portuna sahip function sadece procedural blokta çağırabilrsiniz. Continuous assigment yapamazsınız
    - sadece blocking kullanın
*/

  function logic [4:0] adder_func0(input [3:0] a, input [3:0] b, output integer result);
    integer diff;
    begin
      result = a + b;
      diff   = a - b;
      $display("A: %0d, B: %0d, Result: %0d, Diff : %0d", a, b, result, diff);
      return diff;
    end
  endfunction

  function void adder_func1(input integer a = 0, input integer b = 1, output integer result);
    result = a + b;
    $display("A: %0d, B: %0d, Result: %0d", a, b, result);
  endfunction

  logic [3:0] a, b;
  integer result, diff;

  initial begin

    a = '0;
    b = '0;
    #10ns;

    a = 5;
    b = 3;
    adder_task(.a(a), .b(b), .result(result));
    #10ns;

    a = 5;
    b = 3;
    diff = adder_func0(.a(a), .b(b), .result(result));
    #10ns;

    a = 5;
    b = 3;
    adder_func1(.a(), .b(), .result(result));
    #10ns;



    #100ns;
    $stop;

  end

endmodule
