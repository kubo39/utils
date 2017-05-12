import core.stdc.stdlib : exit;
import std.conv;
import std.format;
import std.process;
import std.regex;
import std.stdio;

void main(string[] args)
{
    if (args.length != 3) {
        stderr.writeln("Too few arguments.");
        exit(1);
    }
    auto program = args[1];
    auto sym = args[2];

    auto symInfo = executeShell("objdump -t %s |grep %s".format(program, sym));
    foreach (c; symInfo.output.matchAll(ctRegex!(r"0*(?P<startAddress>[0-9a-f]+) [ \.a-z]*\t0*(?P<offsetHex>[0-9a-f]+)", "i"))) {
        auto startAddress = c["startAddress"];
        auto offsetHex = c["offsetHex"];
        auto s2 = startAddress;
        auto stopAddress =  parse!ulong(s2, 16) + parse!ulong(offsetHex, 16);

        executeShell("objdump -d -Mintel --start-address=0x%s --stop-address=0x%s %s| less"
                     .format(startAddress, stopAddress.to!string(16), program))
            .output.writeln;
    }
}
