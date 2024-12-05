using System.Diagnostics;
using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.ComponentModel;

public class Program
{
    public static string ServerProperties = @"
        #Minecraft server properties
        #Tue Sep 17 14:11:00 CDT 2024
        accepts-transfers=false
        allow-flight=false
        allow-nether=true
        broadcast-console-to-ops=true
        broadcast-rcon-to-ops=true
        bug-report-link=
        difficulty=easy
        enable-command-block=true
        enable-jmx-monitoring=false
        enable-query=false
        enable-rcon=false
        enable-status=true
        enforce-secure-profile=true
        enforce-whitelist=false
        entity-broadcast-range-percentage=100
        force-gamemode=false
        function-permission-level=2
        gamemode=survival
        generate-structures=true
        generator-settings={biome\:""minecraft\:plains"",layers\:[]}
        hardcore=false
        hide-online-players=false
        initial-disabled-packs=
        initial-enabled-packs=vanilla
        level-name=world
        level-seed=
        level-type=minecraft\:flat
        log-ips=true
        max-chained-neighbor-updates=1000000
        max-players=20
        max-tick-time=60000
        max-world-size=29999984
        motd=A Minecraft Server
        network-compression-threshold=256
        online-mode=true
        op-permission-level=4
        player-idle-timeout=0
        prevent-proxy-connections=false
        pvp=true
        query.port=25565
        rate-limit=0
        rcon.password=
        rcon.port=25575
        region-file-compression=deflate
        require-resource-pack=false
        resource-pack=
        resource-pack-id=
        resource-pack-prompt=
        resource-pack-sha1=
        server-ip=
        server-port=25565
        simulation-distance=10
        spawn-animals=true
        spawn-monsters=true
        spawn-npcs=true
        spawn-protection=16
        sync-chunk-writes=true
        text-filtering-config=
        use-native-transport=true
        view-distance=10
        white-list=false
        
        ";

    public static string Usage = @"Usage:

MCFunctionEnvironment -f<function> -d<dir> [-m<macroparams>] [-p]
    [-a<action>]

Options will not work if their parameters are in separate command line arguments.
So use -fmy-project:main, not -f my-project:main

<function>: namespaced ID of main function to run
<dir>: Directory of datapack's 'data' folder (the pack.mcmeta is generated automatically so you can't include it)
<macroparams>: Minecraft compound tag SNBT syntax for the macro parameters of <function>

This program generates a brand new world each time for a clean slate. The -p option adds a file
named '__KEEP' to the world which tells this program not to delete it on launch. This also might
speed up start times.

The -a flag adds a few special actions. -arun is how it normally behaves without the -a flag.
-areset deletes the world even if it is persistent.
-aresetrun deletes the world and then runs your program with a new world.

";
    //Microsoft code from:
    //https://learn.microsoft.com/en-us/dotnet/standard/io/how-to-copy-directories
    static void CopyDirectory(string sourceDir, string destinationDir, bool recursive)
    {
        // Get information about the source directory
        var dir = new DirectoryInfo(sourceDir);

        // Check if the source directory exists
        if (!dir.Exists)
            throw new DirectoryNotFoundException($"Source directory not found: {dir.FullName}");

        // Cache directories before we start copying
        DirectoryInfo[] dirs = dir.GetDirectories();

        // Create the destination directory
        Directory.CreateDirectory(destinationDir);

        // Get the files in the source directory and copy to the destination directory
        foreach (FileInfo file in dir.GetFiles())
        {
            string targetFilePath = Path.Combine(destinationDir, file.Name);
            file.CopyTo(targetFilePath);
        }

        // If recursive and copying subdirectories, recursively call this method
        if (recursive)
        {
            foreach (DirectoryInfo subDir in dirs)
            {
                string newDestinationDir = Path.Combine(destinationDir, subDir.Name);
                CopyDirectory(subDir.FullName, newDestinationDir, true);
            }
        }
    }
    public static void Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine(Usage);
            Environment.Exit(4);
        }

        string[] actionOptions = args.Where(x => x.StartsWith("-a")).ToArray();
        if (actionOptions.Length == 1)
        {
            switch (actionOptions[0].Substring(2))
            {
                case "run":
                    break;
                case "reset":
                    if (Directory.Exists("./mc") && Directory.Exists("./mc/world"))
                    {
                        Directory.Delete("./mc/world", true);
                        Console.WriteLine("World deleted.");
                        Console.WriteLine("Please press any key to exit...");
                        Console.ReadKey();
                        Environment.Exit(0);
                    }
                    else
                    {
                        Console.WriteLine("No world exists to delete.");
                        Console.WriteLine("Please press any key to exit...");
                        Console.ReadKey();
                        Environment.Exit(1);
                    }
                    break;
                case "resetrun":
                    if (Directory.Exists("./mc") && Directory.Exists("./mc/world"))
                    {
                        Directory.Delete("./mc/world", true);
                    }
                    break;
            }
        }
        else if (actionOptions.Length > 1)
        {
            Console.Error.WriteLine("You must supply at most one -a option.");
            Console.Error.WriteLine("Please press any key to exit...");
            Console.ReadKey();
            Environment.Exit(4);
        }

        if (!Directory.Exists("./mc"))
        {
            Console.Error.WriteLine("Folder mc must exist and contain the minecraft server jar named minecraft_server.jar");
            Console.Error.WriteLine("Please press any key to exit...");
            Console.ReadKey();
            Environment.Exit(1);
        }

        Directory.SetCurrentDirectory("./mc");
        if (Directory.Exists("./world") && !File.Exists("./world/__KEEP"))
        {
            Directory.Delete("./world", true);
        }

        string functionLocation = args.Where(x => x.StartsWith("-f")).First().Substring(2);
        string functionFolderLocation = "../" + args.Where(x => x.StartsWith("-d")).First().Substring(2);
        string? functionMacroParams;
        try
        {
            functionMacroParams = args.Where(x => x.StartsWith("-m")).First().Substring(2);
        }
        catch
        {
            functionMacroParams = null;
        }

        ProcessStartInfo psi = new ProcessStartInfo
        {
            RedirectStandardOutput = true,
            RedirectStandardInput = true,
            FileName = "java",
            Arguments = "-jar minecraft_server.jar --nogui"
        };
        Process? process = Process.Start(psi);
        if (process == null)
        {
            Console.Error.WriteLine($"Well shoot, guess the program didn't start!");
            Console.Error.WriteLine("Please press any key to exit...");
            Console.ReadKey();
            Environment.Exit(3);
        }
        StreamWriter mcin = process.StandardInput;
        StreamReader mcout = process.StandardOutput;

        string line = "";
        while (!Regex.IsMatch(line, "\\[..:..:..\\] \\[Server thread\\/INFO\\]: Done \\(.*\\)! For help, type \"help\"")) line = mcout.ReadLine() ?? "";
        
        if (args.Contains("-p"))
        {
            File.Create("./world/__KEEP").Dispose();
        }
        if (!Directory.Exists("./world/datapacks/MCFunkyLib"))
        {
            CopyDirectory("../MCFunkyLib", "./world/datapacks/MCFunkyLib", true);
        }

        if (Directory.Exists("./world/datapacks/To Run"))
            Directory.Delete("./world/datapacks/To Run", true);
        Directory.CreateDirectory("./world/datapacks/To Run");
        File.Copy("../base_pack.mcmeta", "./world/datapacks/To Run/pack.mcmeta");
        CopyDirectory(functionFolderLocation, "./world/datapacks/To Run/data", true);
       
        
        
        mcin.WriteLine("reload");
        mcin.WriteLine("data modify storage mcfunky:core startup set value 1");

        while (true)
        {
            line = mcout.ReadLine();
            if (Regex.IsMatch(line ?? "", "\\[..:..:..\\] \\[Server thread\\/INFO\\]: \\[Not Secure\\] \\[Server\\] @@@Loaded"))
                break;
        }

        mcin.WriteLine($"function {functionLocation}{(functionMacroParams != null ? " " : "")}{functionMacroParams ?? ""}");
        while (true)
        {
            line = mcout.ReadLine();
            bool serverMatch = Regex.IsMatch(line ?? "", "\\[..:..:..\\] \\[Server thread\\/INFO\\]: \\[Not Secure\\] \\[Server\\] .*");
            bool commandBlockMatch = Regex.IsMatch(line ?? "", "\\[..:..:..\\] \\[Server thread\\/INFO\\]: \\[Not Secure\\] \\[@\\] .*");
            if (serverMatch || commandBlockMatch)
            {
                string? directPrinted;
                if (serverMatch)
                    directPrinted = line?.Substring(line.IndexOf("ver] ") + 5);
                else
                    directPrinted = line?.Substring(line.IndexOf(" [@] ") + 5);
                string[]? parts = directPrinted?.Split('|');
                byte parsedOut;
                int parsedInt;
                if (parts == null) continue;
                if (parts.Length < 1) continue;
                switch (parts[0])
                {
                    case "out":
                        if (parts.Length < 2) break;
                        Console.Write(parts.Skip(1).Aggregate((s1, s2) => s1 + "|" + s2));
                        break;
                    case "outl":
                        if (parts.Length < 2) break;
                        Console.WriteLine(parts.Skip(1).Aggregate((s1, s2) => s1 + "|" + s2));
                        break;
                    case "err":
                        if (parts.Length < 2) break;
                        Console.Error.Write(parts.Skip(1).Aggregate((s1, s2) => s1 + "|" + s2));
                        break;
                    case "errl":
                        if (parts.Length < 2) break;
                        Console.Error.WriteLine(parts.Skip(1).Aggregate((s1, s2) => s1 + "|" + s2));
                        break;
                    case "inl":
                        mcin.WriteLine($"data modify storage mcfunky:io line_read set value \"{Console.ReadLine().Replace("\\","\\\\").Replace("\"","\\\"")}\"");
                        break;
                    case "outb":
                        if (parts.Length < 2) break;
                        if (byte.TryParse(parts[1], out parsedOut))
                        {
                            Console.OpenStandardOutput().WriteByte(parsedOut);
                        }
                        break;
                    case "errb":
                        if (parts.Length < 2) break;
                        if (byte.TryParse(parts[1], out parsedOut))
                        {
                            Console.OpenStandardError().WriteByte(parsedOut);
                        }
                        break;
                    case "inb":
                        mcin.WriteLine($"data modify storage mcfunky:io byte_read set value {Console.OpenStandardInput().ReadByte()}");
                        break;
                    case "control":
                        Thread input = new Thread(() =>
                        {
                            while (true)
                            {
                                string? line = Console.ReadLine();
                                if (line == null || line == ".") break;
                                mcin.WriteLine(line);
                            }
                        });
                        Thread output = new Thread(() =>
                        {
                            while (input.IsAlive)
                            {
                                string? line = mcout.ReadLine();
                                if (line != null)
                                    Console.WriteLine(line);
                            }
                        });
                        input.Start();
                        output.Start();
                        while (input.IsAlive) { }
                        mcin.WriteLine("data modify storage mcfunky:core endcontrol set value 1");
                        break;

                    case "exit":
                        mcin.WriteLine("stop");
                        if (parts.Length == 1)
                            Environment.Exit(0);
                        else if (parts.Length == 2)
                            if (int.TryParse(parts[1], out parsedInt))
                                Environment.Exit(parsedInt);
                            else
                            {
                                Console.Error.WriteLine($"'{parts[1]}' is not a valid integer (to use as exit code).");
                                Console.Error.WriteLine("Please press any key to exit...");
                                Console.ReadKey();
                                Environment.Exit(2);
                            }
                        break;
                                
                }
            }
        }
    }
}