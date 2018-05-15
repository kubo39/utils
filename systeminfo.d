import std.file : readText;
import std.format : format;
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

string getStorageSize()
{
    import std.conv : to;
    auto size = readText("/sys/block/sda/size").chop();
    auto gb = size.to!ulong * 512.0 / (1000.0 * 1000.0 * 1000.0);
    return format("%d GB", gb.to!ulong);
}

string getOSInfo()
{
    import std.process : pipeProcess, Redirect, wait;
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
    writeln("HDD容量: ", getStorageSize());
    writeln("OS情報: ", getOSInfo());
    writeln("メーカー: ", getVendor());
    writeln("型番: ", getProductName());
}
