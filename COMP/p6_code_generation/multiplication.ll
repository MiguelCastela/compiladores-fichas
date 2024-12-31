declare i32 @_read(i32)
declare i32 @_write(i32)

define i32 @_multiply(i32 %a, i32 %b) {
  %1 = mul i32 %a, %b
  ret i32 %1
}

define i32 @main() {
  %input1 = call i32 @_read(i32 0)
  %input2 = call i32 @_read(i32 0)
  %result = call i32 @_multiply(i32 %input1, i32 %input2)
  call i32 @_write(i32 %result)
  ret i32 0
}