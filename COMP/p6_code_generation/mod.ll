declare i32 @_read(i32)
declare i32 @_write(i32)

define i32 @_mod(i32 %a, i32 %b) {
  %1 = sdiv i32 %a, %b
  %2 = mul i32 %1, %b
  %3 = sub i32 %a, %2
  ret i32 %3
}

define i32 @main() {
  %input1 = call i32 @_read(i32 0)
  %input2 = call i32 @_read(i32 0)
  %result = call i32 @_mod(i32 %input1, i32 %input2)
  call i32 @_write(i32 %result)
  ret i32 0
}