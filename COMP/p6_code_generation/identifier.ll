declare i32 @_read(i32)
declare i32 @_write(i32)

define i32 @_identity(i32 %n) {
  %1 = add i32 %n, 0
  ret i32 %1
}

define i32 @main() {
  %input = call i32 @_read(i32 0)
  %result = call i32 @_identity(i32 %input)
  call i32 @_write(i32 %result)
  ret i32 0
}