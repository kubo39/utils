import std.process;
import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.algorithm;

struct NR
{
  string str; int nr;
}

void genSyscall()
{
  executeShell("printf '#include<sys/syscall.h>' | cpp -dM - | grep '__NR_'")
    .output.split("\n").map!(a => a.split(" "))
    .filter!(a => a.length >= 2 && a[2].isNumeric)
    .map!(a => NR(a[1], a[2].to!int))
    .array.sort!((a, b) => a.nr < b.nr)
    .each!(a => writeln("enum " ~ a.str[2..$] ~ " = " ~ a.nr.to!string ~ ";"));
}

void main()
{
  genSyscall();
}
