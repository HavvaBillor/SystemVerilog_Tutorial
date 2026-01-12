

module tb_struct_union;


  // logic a;
  //logic control;


  typedef struct packed {
    // string name;   ---- string ler unpacked dir
    int       age;  // initial değerler struct içinde olabilir ama sadece unpacked olanlar
    bit [3:0] id;
  } employee_t;

  employee_t employee;

  // Union, tüm üyelerin aynı bellek alanını paylaştığı bir veri tipidir.
  // Bir üyeye değer atandığında, diğer üyeler aynı bellekten değer okur.
  // Union, farklı veri tiplerini aynı adreste depolamak veya hafızayı verimli kullanmak için tercih edilir.

  typedef union {
    bit [31:0] data;
    bit [7:0]  fbyte;
  } data_u_t;

  data_u_t data_u;


  initial begin

    // employee.name = "ahmet";
    //employee.age  = 32;
    //employee.id = 10;

    employee = '{id  : 10, default: 35};

    $display("age: %0d, id: %0d", employee.age, employee.id);

    data_u.data = 32'hDEAD_BEAF;
    #1;
    data_u.fbyte = 8'hCC;
    $display("Data:  %0h", data_u.data);
    $display("fbyte:  %0h", data_u.fbyte);


  end



endmodule
