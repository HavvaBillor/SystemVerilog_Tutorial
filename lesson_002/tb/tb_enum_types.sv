/*

    SystemVerilog'da enum, birden fazla sabir değeri isimlendirerek
    gruplayan bir veri türüdür. Kodun okunulabilirliğini artırır,
    hata riskini azaltır ve debug isimlerini kolaylaştırır. Sentezlenebilir ve veri tipi
*/


module tb_enum_types;

  // enum bit [4:0] {red = 1, yellow =2 , green} light1, light2;  // anonymous int

  // longint [127:0] my_data;

  // typedef longint [127:0] my_type;
  // my_type mydata; 



  typedef enum bit [4:0] {
    red,
    yellow,
    green
  } light_t;
  light_t light1, light_2;

  initial begin

    repeat (light1.num()) begin
      $display("Name  : %0s", light1.name());
      light1 = light1.next();
    end

  end

  typedef enum bit [4:0] {red[4: 0]} reds;
  reds reds1, reds2;
  bit [4:0] my_b;

  initial begin

    repeat (reds1.num()) begin
      $display("Name  : %0s", reds1.name());
      reds1 = reds1.next();
    end

    $display("Enum = %0d", reds1);

    if (reds1 == 0) begin
      $display("Enum = 0");
    end

    my_b = reds1.next() + 5;
    $display("my_b = %0d", my_b);

    reds1 = reds'(3);
    $display("Enum = %0d", reds1);

  end






endmodule
