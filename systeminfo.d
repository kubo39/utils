import std.conv : to;
import std.file : readText;
import std.format : format;
import std.process : pipeProcess, Redirect, wait;
import std.stdio : File, writeln;
import std.string : chop, split, startsWith;

struct ProcessorInfo
{
    string modelName;
    uint numOfProcessors;

    this(string modelName, uint numOfProcessors)
    {
        this.modelName = modelName;
        this.numOfProcessors = numOfProcessors;
    }

    auto toString()
    {
        return format("%s   コア数: %d", this.modelName, this.numOfProcessors);
    }
}

auto getProcessorInfo()
{
    uint numOfProcessors = 0;
    string modelName;
    bool modelNameSeen = false;

    auto f = File("/proc/cpuinfo");
    foreach (line; f.byLineCopy())
    {
        // Calculate number of processors.
        if (line.startsWith("processor"))
            numOfProcessors++;

        // Get model name only once.
        if (line.startsWith("model name") && !modelNameSeen)
        {
            modelName = cast(immutable) line.split(": ")[1];
            modelNameSeen = true;
        }
    }
    return ProcessorInfo(modelName, numOfProcessors);
}

string getTotalRAM()
{
    string memTotal;
    foreach (line; readText("/proc/meminfo").chop().split("\n"))
    {
        if (line.startsWith("MemTotal"))
            memTotal = line.split(": ")[1];
    }
    return memTotal;
}

enum DiskType
{
    HDD = 1,
    SSD,
}

DiskType findTypeFromName(string name)
{
    auto rotational = readText(format("/sys/block/%s/queue/rotational", name)).chop();
    return cast(DiskType) rotational.to!int;
}

string getStorageSize(string name)
{
    auto size = readText(format("/sys/block/%s/size", name)).chop();
    auto gb = size.to!ulong * 512.0 / (1000.0 * 1000.0 * 1000.0);
    return format("%d GB", gb.to!ulong);
}

string getKernelVersion()
{
    auto pipes = pipeProcess(["uname", "-mrv"], Redirect.stdout);
    scope(exit) wait(pipes.pid);
    return pipes.stdout.readln.chop;
}

string getOSInfo()
{
    auto pipes = pipeProcess(["lsb_release", "-ds"], Redirect.stdout);
    scope(exit) wait(pipes.pid);
    return pipes.stdout.readln.chop;
}

string getProductName()
{
    return readText("/sys/devices/virtual/dmi/id/product_name").chop();
}

string getVendor()
{
    return readText("/sys/devices/virtual/dmi/id/sys_vendor").chop();
}

void main()
{
    writeln("CPU情報: ", getProcessorInfo());
    writeln("メモリ容量: ", getTotalRAM());
    writeln(format("ディスク容量: %s (%s)", getStorageSize("sda"), findTypeFromName("sda")));
    writeln("Linuxカーネル: ", getKernelVersion());
    writeln("OS情報: ", getOSInfo());
    writeln("メーカー: ", getVendor());
    writeln("型番: ", getProductName());
}
