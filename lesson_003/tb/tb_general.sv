module tb_general;

  // always, always_ff, always_comb, always_latch

  logic [3:0] a;

  logic       clk = 0;
  always #5 clk = ~clk;

  // bu blok lar içinde atanan bir değişen başka blokta atanamaz
  // sentez tool'u sizi eğer ff üretilmiyorsa uyarabilir
  // edge sensitive depolama elemanı üretmek için kullanılır

  // always_ff @(posedge clk) begin
  //   a <= 5;
  // end

  // 0 anında bir kez çalıştırılır
  // tool sizi uyarabilir eğer combinational devre üretmezse
  // always_comb begin
  //   a = 5;
  // end

  // 0 zamanında always ve initial blocklarından sonra bir kez çalıştırılır

  // always_latch begin
  //   a <= 5;
  // end

  // ---------------------------------------------------------------------------------------------------------------------

  //sized literal
  // <size>'<base><value>

  logic [7:0] data;
  int         count;

  initial begin

    data = 8'b0000_1011;

    repeat (8) begin

      data = {data[6:0], data[7]};
      $display("data : %0b", data);
      if (data[7]) break;
    end

    $display("-----------------");

    foreach (data[i]) begin
      if (data[i]) continue;
      count = count + 1;
    end

    $display(" count : %0d", count);



    // data = 4'b1011;

    // for (int i = 0; i < 4; i = i + 1) begin
    //   $display("data[%0d] : %0d", i, data[i]);
    // end

    // $display("--------------------------");

    // // foreach most significant bit ini alıyor
    // foreach (data[i]) begin
    //   $display("data[%0d] : %0d", i, data[i]);
    // end




    // for (int i = 0; i < 4; i = i + 1) begin
    //   $display("start counter : %0d", i);
    // end

    // for (int i = 0; i < 4; i = i + 1) begin
    //   $display("start counter : %0d", i);
    // end

    // data = 4'b0011;
    // $display("data : %0b", data);

    // //unsized literal
    // //'<value>

    // data = '1;
    // $display("data : %0b", data);

    // data = '0;
    // $display("data : %0b", data);

    // data = 'x;
    // $display("data : %0b", data);

    // data = 'z;
    // $display("data : %0b", data);




    #100ns;
    $stop;

  end



endmodule
