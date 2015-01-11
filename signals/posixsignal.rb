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

  # int sigemptyset(sigset_t*);
  attach_function :sigemptyset, [:pointer], :int

  # int sigaddset(sigset_t*, int);
  attach_function :sigaddset, [:pointer, :int], :int

  # int sigpending(sigset_t*);
  attach_function :sigpending, [:pointer], :int
end


module Signal
  SIG_BLOCK = 0
  SIG_UNBLOCK = 1
  SIG_SETMASK = 2

  class SigprocmaskError < Exception; end
  class SigpendingError < Exception; end

  Sigset = SignalExt::Sigset

  def self.sigprocmask(how, set, oldset)
    if SignalExt.sigprocmask(how, set, oldset) != 0
      raise SigprocmaskError
    end
    return 0
  end

  def self.sigismember(set, signo)
    SignalExt.sigismember(set, signo)
  end

  def self.sigemptyset(set)
    SignalExt.sigemptyset(set)
  end

  def self.sigaddset(set, signo)
    SignalExt.sigaddset(set, signo)
  end

  def self.sigpending(set)
    if SignalExt.sigpending(set) != 0
      raise SigpendingError
    end
    return 0
  end
end
