require 'ffi'

CLONE_NEWPID = 0x20000000

module LinuxClone
  extend FFI::Library
  ffi_lib 'libc.so.6'
  callback :f_c, [:void], :int
  attach_function :clone, [:f_c, :pointer, :int], :int
  attach_function :getpid, [], :int
end

stack = FFI::MemoryPointer.new(:char, 8096)
stack_top = FFI::Pointer.new(stack.address + 8096)

f = proc do
  puts "getpid: #{LinuxClone.getpid}"
  return 0
end

puts "clone(2) retval= #{LinuxClone.clone(f, stack_top, CLONE_NEWPID)}"
