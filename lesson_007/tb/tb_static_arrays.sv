
`timescale 1ns / 1ps

module tb_static_arrays;

  // Static array lar compile edildikten sonra boyutları değişmez

  // systemverilog ta herhangi bir türü array olarak tanımlamanıza izin verir
  // Verilog ta standart array lar unpack
  //  - index isimden sonra tanımlanır
  //  - elemanlar ayrı depolanır

  // Unpack 
  // - her eleman ayrı depolanır
  // - birden fazla aynı anda elemana erişim ya da işlem yapma mümkün değil
  // - isimden sonra boyut tanımlanır
  //
  // Pattern assignment array birden boyutlarına erişim için en kolay yoldur
  // - anahtar (key) olarak eleman indeksi kullanılabilir
  // - default anahtar kelimesi kullanılarak, atanmadık diğer tüm elemanlara aynı değer verilebilir

  bit             arr2d                [1:0] [4];  // 2 tane 4 elemanlı ( yani arr2d de 2 parantez parantez içlerinde 4 eleman değerini gir)

  // -------------------------------------------------------------------------------------------------------------------------------------
  // packed multi-dimensional
  // sadece tek bit değişken türleri pack array oluşturur. bit, logic 
  // index isimden önce belirtilr

  bit [ 1:0][3:0] arr2d_pack1;  // 8bit
  bit [ 7:0]      arr2d_pack2;

  // -------------------------------------------------------------------------------------------------------------------------------------
  // Mix

  bit [31:0]      mem                  [7:0];
  // Packed word lerin unpacked array i mem yani 32 bit word 8 tane

  initial begin
    // pattern assignment
    // arr2d = '{'{2, 3, 5, 7}, '{11, 13, 17, 19}}; // int 32 bit ya o yüzden

    //nested ordered
    // arr2d[0][0] = 1;
    // arr2d[0][1] = 2;
    // arr2d[0][2] = 3;
    // arr2d[0][3] = 4;
    // arr2d[1][0] = 5;
    // arr2d[1][1] = 6;
    // arr2d[1][2] = 7;
    // arr2d[1][3] = 8;

    // Keyed
    arr2d = '{default: 0};
    foreach (arr2d[i]) begin
      $display("UNPACKED %0d : %0p", i, arr2d[i]);
    end

    #10ns;
    $display("------------------------------");

    arr2d_pack1[0] = 4'd3;
    arr2d_pack1[1] = 4'd1;

    foreach (arr2d_pack1[i]) begin
      $display("PACKED arr2d_pack1 %0d : %0d", i, arr2d_pack1[i]);
    end

    $display("------------------------------");

    arr2d_pack2 = arr2d_pack1;

    foreach (arr2d_pack2[i]) begin
      $display("PACKED arr2d_pack2 %0d : %0d", i, arr2d_pack2[i]);
    end

    // Packed 
    // - elemanlar tek bir eleman gibi depolanır
    // - birden fazla aynı anda elemana erişim ya da işlem yapma mümkündür

    $display("-------$dimensions------------");
    $display("Dimensions of arr2d:       %0d", $dimensions(arr2d));  //int kendi bir boyut daha ekler eğer o bit olsaydı 2 olacaktı
    $display("Dimensions of arr2d_pack1: %0d", $dimensions(arr2d_pack1));
    $display("Dimensions of arr2d_pack2: %0d", $dimensions(arr2d_pack2));
    $display("Dimensions of mem:         %0d", $dimensions(mem));

    $display("-----$unpacked_dimensions-----");
    $display("Dimensions of arr2d:       %0d", $unpacked_dimensions(arr2d));
    $display("Dimensions of arr2d_pack1: %0d", $unpacked_dimensions(arr2d_pack1));
    $display("Dimensions of arr2d_pack2: %0d", $unpacked_dimensions(arr2d_pack2));
    $display("Dimensions of mem:         %0d", $unpacked_dimensions(mem));

    $display("-----$size eleman sayisi-------");
    $display("Size of arr2d:       %0d", $size(arr2d));
    $display("Size of arr2d_pack1: %0d", $size(arr2d_pack1));
    $display("Size of arr2d_pack2: %0d", $size(arr2d_pack2));
    $display("Size of mem:         %0d", $size(mem));

    $display("------$bits toplam boyut------");
    $display("Size of arr2d:       %0d", $bits(arr2d));
    $display("Size of arr2d_pack1: %0d", $bits(arr2d_pack1));
    $display("Size of arr2d_pack2: %0d", $bits(arr2d_pack2));
    $display("Size of mem:         %0d", $bits(mem));
  end

endmodule
