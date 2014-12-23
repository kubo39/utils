require 'thread'

def nonblock_read_subprocess(cmd)
  q = Queue.new
  r, w = IO.pipe
  pid = spawn(cmd, [:out, :err] => w)
 
  Thread.start(r, q) {|r, q|
    r.each do |line|
      q.push line
    end
    w.close
  }
 
  while true
    begin
      line = q.pop(true)
      puts line
      break if line =~ "hoge"
    rescue ThreadError
      # nop
    end
  end

  return pid
end


if __FILE__ == $0
  cmd = "tail -f /var/log/syslog"
  pid = nonblock_read_subprocess(cmd)
  Process.kill(:KILL, pid)
end
