`timescale 1ns / 1ps

module tb_fork_join;

  initial begin

    /*

    $display("-------------------------------------");
    $display("Baslnagic: %0t ns", $time);

    // fork.... join_any örneği
    // Bu blok, içindeki süreclerinden sadece İLK BİTENİ bekler
    // Diğerleri sonlandırılır
    $display("-------------------------------------");
    $display(">>> fork...join_any <<<");
    fork
      #5ns $display("Islem 1 (join_any): %0t", $time);
      #3ns $display("Islem 2 (join_any): %0t", $time);
    join_any
    $display("join_any bitti: %0t ns", $time);

    // fork...join örneği
    // Bu blok içindeki TÜM süreçlerin bitmesini bekler
    $display("-------------------------------------");
    $display(">>> fork...join <<<");
    fork
      #5ns $display("Islem 1 (join): %0t", $time);
      #3ns $display("Islem 2 (join): %0t", $time);
    join
    $display("join_any bitti: %0t ns", $time);

    // fork...join_none örneği
    // Bu blok süreçleri başlatır ve HİÇBİRİNİ beklemez
    // Hemen devam eder ve süreçler arka planda çalıştıırlır
    $display("-------------------------------------");
    $display(">>> fork...join_none <<<");
    fork
      #5ns $display("Islem 1 (join_none): %0t", $time);
      #3ns $display("Islem 2 (join_none): %0t", $time);
    join_none
    $display("join_none bitti: %0t ns", $time);
    $display("-------------------------------------");

    #10ns;
    $display("-------------------------------------");
    $display("Tum islemler bitti: %0t ns", $time);

    $finish;
*/

    // disable fork örneği
    // fork içerisindeki süreçlerden biri tamamlanmadan diğer süreçler disable edilebilir

    $display("-------------------------------------");
    $display(">>> disable fork ornegi <<<");
    fork : disable_fork
      begin
        #4ns $display("islem 1 (disable fork): %0t ns", $time);
        disable disable_fork;  // diger süreçler burada iptal edilir
      end
      begin
        #10ns $display("islem 2 (disable fork): %0t ns", $time);  // bu işlem iptal edilir
      end
    join_none
    #15ns;  // disable ile iptal edilen işlemler dikkate alınmaz, bu bekleme zorunlu
    $display("display fork ornegi bitti: %0t ns", $time);


    // wait fork örneği
    // fork başlatılır ve beklenir, sonra devam edilir 
    $display("-------------------------------------");
    $display(">>> wait fork ornegi <<<");
    fork : wait_fork
      begin
        #5ns $display("islem 1 (wait fork): %0t ns", $time);
        #7ns $display("islem 2 (wait fork): %0t ns", $time);
      end
    join_none
    wait fork;  // fork tamamlanana kadar bekle
    $display("wait fork ornegi bitti: %0t ns", $time);
    $display("-------------------------------------");
    $finish;

  end

endmodule
