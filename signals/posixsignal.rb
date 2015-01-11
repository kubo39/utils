require 'ffi'

module Unistd
  extend FFI::Library
  ffi_lib 'libc.so.6'

  # unsigned int alarm(unsigned int);
  attach_function :alarm, [:uint], :uint

  # int pause(void);
  attach_function :pause, [:void], :int
end


module SignalExt
  extend FFI::Library
  ffi_lib 'libc.so.6'

  class Sigset < FFI::Struct
    layout :__val, :ulong
  end

  # int sigprocmask(int, const sigset_t*, const sigset_t*);
  attach_function :sigprocmask, [:int, :pointer, :pointer], :int

  # int sigismember(const sigset_t*, int);
  attach_function :sigismember, [:pointer, :int], :int
end

module Signal
  class SigprocmaskError < Exception; end

  def self.sigprocmask(how, set, oldset)
    if SignalExt.sigprocmask(how, set, oldset) < 0
      raise SigprocmaskError
    end
  end
end
