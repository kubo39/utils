require 'ffi'

CLONE_NEWPID = 0x20000000

module Libc
  extend FFI::Library
  ffi_lib 'libc.so.6'
  callback :f_c, [:void], :int
  attach_function :clone, [:f_c, :pointer, :int], :int
  attach_function :getpid, [:void], :int
end

stack = FFI::MemoryPointer.new(:char, 8096)
stack_top = FFI::Pointer.new(stack.address + 8096)

f = proc do
  puts "getpid: #{Libc.getpid}"
  return 0
end

puts "clone(2) retval= #{Libc.clone(f, stack_top, CLONE_NEWPID)}"
