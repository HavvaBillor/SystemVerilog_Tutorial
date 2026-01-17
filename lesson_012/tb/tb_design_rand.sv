`timescale 1ns / 1ps

module tb_design_rand;

  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] c;

  design_rand dut (
      .a(a),
      .b(b),
      .c(c)
  );

  initial begin
    a <= 0;
    b <= 0;
    #10ns;
    repeat (100) begin
      // randomize()

      void'(std::randomize(a) with {a < 3 || a > 10;});
      void'(std::randomize(
          b
      ) with {
        b dist {
          [1 : 3] := 2,
          4 := 5,
          9 := 3
        };
      });
      #10;
      $display("output: %0d", c);
    end
  end

endmodule
