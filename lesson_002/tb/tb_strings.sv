module tb_strings;


    string message = "hello world";
    string extra_info;

    initial begin
        extra_info = "SystemVerilog";

        message = {message, "\n", extra_info};

        $display("message: %0s",message);
        $display("message: %0s",message.toupper());
        $display("message: %0s",message.tolower());
        message.putc(2,"Z");
        $display("message: %0s",message);
        $display("message: %0s",message.getc(2));
    end

endmodule