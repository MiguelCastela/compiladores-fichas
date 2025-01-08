declare i32 @_read(i32)
declare i32 @_write(i32)

define i32 @_sum(i32 %a, i32 %b) {
  %1 = add i32 %a, %b
  ret i32 %1
}

define i32 @main() {
  %1 = call i32 @_sum(i32 3, i32 4)
  call i32 @_write(i32 %1)
  ret i32 0
}