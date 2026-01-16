`timescale 1ns / 1ps

module tb_dynamic_arrays;

  // Eğer simülasyon sırasında bir array in boyutunu değiştirmek istiyorsanız kullanırsınız
  // array tanımından sonra unpacked olan boyutunu [] bırakarak

  logic [7:0] dyn_arr[];

  initial begin
    dyn_arr = new[8];  // bu satıra gelince bu array var olur

    for (int i = 0; i < 8; ++i) begin
      dyn_arr[i] = i;
    end

    $display("array size: %0d", dyn_arr.size());

    dyn_arr = new[16];  // create, ya da boyutunu değiştirir
    $display("array new[] size: %0d", dyn_arr.size());

    dyn_arr.delete();  // delete elemanları temizler ve eleman sayısını 0 yapar
    $display("array delete() size: %0d", dyn_arr.size());

  end

  // ----------------------------------------------------------------------------------------------------------------------------------

  //associative arrays
  // atama yapılana kadar elemanları var olmazlar
  // key: value 
  logic [7:0] assoc_arr1[int];  // key:int
  logic [7:0] assoc_arr2[string];

  /*
  num()
  size()
  exists()
  delete()
  first()
  last()
  prev()
  next()
  */


  initial begin
    assoc_arr1[10] = 8'd7;  // bu satıra gelince bu array var olur
    assoc_arr2["ev fiyati"] = 8'd7;

    $display("assoc_arr1[10]: %0d", assoc_arr1[10]);
    $display("ev fiyati: %0d", assoc_arr2["ev fiyati"]);

  end

  // ----------------------------------------------------------------------------------------------------------------------------------

  // Queues
  // Kullanırken kendileri otomatik olarak boyutlarını artırıp azaltabilirler

  /*
  size()        // eleman sayısı
  insert()      // herhangi bir index e bir eleman yerleştirme
  delete()      // eleman kaldırma
  pop_front()   // 0. index e eleman kaldırma okuma
  push_front()  // 0. index e elemana yazma 
  pop_back()    // en sonuncu elemanı kaldırma okuma
  push_back()   // en sonuncu elemana yazma
  */

  int my_que[$];  // my_que[$:100]; max olarak sınırlandırma 100
  int size;

  initial begin
    my_que.push_front(1);  // {1}
    my_que.push_back(2);  // {1,2}
    my_que.push_front(5);  // {5,1,2}
    my_que.push_back(0);  // {5,1,2,0}
    #20ns;

    size = my_que.size();

    for (int i = 0; i < size; ++i) begin
      $display("my_que%0d: %0d", i, my_que.pop_front());
    end

  end




endmodule
