// Auto-start, reset, and split upon entering each level (and optionally each boss)
// Supports steam version, patch 1.4.3 and 2.0. 

// Fastest/last patch with jeep backstab (2015-12-18 release)
// inside "TDH 1.1.7z" on speedrun.com or steam (steam://nav/console):
//   download_depot 405820 405822 305215209689250894 (Windows Files)
//   download_depot 405820 405821 7171797334604885018 (Game Files)
state("sobek", "1.4.3")
{
    string40 level: 0x27D764, 0x0, 0x0;
    string40 map: 0x27D740, 0x0;
    int health: 0x27DA3C, 0xE0;
    int level8BossHealth: 0x27DBD4, 0xE0;
    int warpId: 0x27DF64; // -1 before/after warp, ID during warp
    int levelKeysRemaining: 0x27D764, 0x40;
    // 0x27D74C, (0x40)+(levelID*0x60) = int Keys remaining for levelID  (0x38E408, 0xC8 for v2.0 lvl 1)
    // 0x27DA3C, 0x10 = position vector (float x, y, z)
    // 0x27DA60 / 0x27DA64 = last checkpoint (int id / int map)
}

// current patch (2018-06-21 release)
state("sobek", "2.0")
{
    string40 level: 0x3AE25C, 0x0;
    string40 map: 0x38E3FC, 0x0;
    int health: 0x390CF4, 0xE0;
    int level8BossHealth: 0x393118, 0xE0;
    int warpId: 0x393684; // untested
    int levelKeysRemaining: 0x38E428, 0x50; // untested
}

start 
{
    vars.mapSplits.Clear();
    vars.mapsVisited.Clear();
    vars.warpSplits.Clear();
    vars.warpsVisited.Clear();
    vars.trackMap("the hub", "the ancient city", 1);
    vars.trackMap("the hub", "the jungle", 1);
    vars.trackMap("the hub", "the ruins", 1);
    vars.trackMap("the hub", "the catacombs", 1);
    vars.trackMap("the hub", "the treetop village", 1);
    vars.trackMap("the hub", "the lost land", 1);
    vars.trackMap("the hub", "the final confrontation", 1);
    if (settings["split-longhunter"]) vars.trackMap("levels/level09.map", "levels/level48.map", 1);
    if (settings["split-mantis"]) vars.trackMap("levels/level12.map", "levels/level49.map", 1);
    if (settings["split-thunder"]) vars.trackMap("levels/level24.map", "levels/level03.map", 1);
    if (settings["split-campaigner"]) vars.trackMap("levels/level25.map", "levels/level00.map", 1);

    if (settings["split-warps-anyp"])
    {
        // level 1
        vars.trackWarp(10201, 1);
        vars.trackWarp(10207, 1);
        vars.trackWarp(10203, 1);
        vars.trackWarp(10205, 1);
        vars.trackWarp(10206, 1);
        vars.trackWarp(10208, 1);
        vars.trackWarp(10209, 1);
        vars.trackWarp(10210, 1);
        vars.trackWarp(10211, 1);

        // level 3
        vars.trackWarp(12041, 1);
        vars.trackWarp(12768, 1);
        vars.trackWarp(12041, 2);
        vars.trackWarp(12766, 1);
        vars.trackWarp(12045, 1);
        
        // level 2
        vars.trackWarp(11126, 1);

        // level 4
        vars.trackWarp(13735, 1);
        vars.trackWarp(13313, 1);
        vars.trackWarp(13450, 1);
        vars.trackMap("the hub", "the ruins", 2);
        vars.trackWarp(13731, 1);
        vars.trackWarp(13734, 1);

        // level 5
        vars.trackWarp(14567, 1);
        vars.trackWarp(14569, 1);

        // level 6
        vars.trackWarp(15436, 1);
        vars.trackWarp(15006, 1);
        vars.trackWarp(15004, 1);
        
        // level 7
        vars.trackWarp(17301, 1);
        vars.trackWarp(17304, 1);
        vars.trackWarp(17900, 1);
        // Don't split save/load menuing
        vars.trackWarp(17634, 1);
        vars.trackWarp(17501, 1);
        
        // level 8
        vars.trackWarp(18644, 1);
        vars.trackWarp(18645, 1);
        vars.trackWarp(18648, 1);
        // 18998 = thunder to hallway
    }

    return old.level == "title" && current.level == "the hub";
}

reset 
{
    return settings["reset-title"] && old.level != "title" && current.level == "title";
}

split 
{
    bool isLevelSplit = vars.isMapSplit(old.level, current.level);
    bool isMapSplit = vars.isMapSplit(old.map, current.map);
    bool isWarpSplit = settings["split-warps-anyp"] && old.warpId == -1 && current.warpId != -1 && vars.isWarpSplit(current.warpId, current.levelKeysRemaining);
    bool isFinalSplit = current.health > 0 && current.health <= 250 && // don't split if we died
                        (old.level8BossHealth > 0 && current.level8BossHealth == 0) &&
                        current.map == "levels/level00.map";

    return isLevelSplit || isMapSplit || isWarpSplit || isFinalSplit;
}

init
{
    int memSize = modules.First().ModuleMemorySize;
    version = memSize == 3047424 ? "1.4.3" : "2.0";
}

startup 
{
    vars.mapSplits = new Dictionary<string, Dictionary<string, List<int>>>();
    vars.mapsVisited = new Dictionary<string, Dictionary<string, int>>();
    vars.warpSplits = new Dictionary<int, List<int>>();
    vars.warpsVisited = new Dictionary<int, int>();

    settings.Add("split-boss", false, "Split Boss Entrances");
    settings.Add("split-longhunter", false, "Longhunter", "split-boss");
    settings.Add("split-mantis", false, "Mantis", "split-boss");
    settings.Add("split-thunder", false, "Thunder", "split-boss");
    settings.Add("split-campaigner", false, "Campaigner", "split-boss");
    settings.Add("subsplits", false, "Warp Subsplits");
    settings.Add("split-warps-anyp", false, "Split Blue Planes (Any% Route)", "subsplits");
    settings.Add("misc", true, "Misc");
    settings.Add("reset-title", true, "Reset on Titlescreen", "misc");
    settings.SetToolTip("reset-title", "Disable this if you don't want the timer to reset if you game over");

    vars.trackMap = (Action<string, string, int>)((from, to, visit) =>
    {
        if (!vars.mapSplits.ContainsKey(from)) vars.mapSplits[from] = new Dictionary<string, List<int>>();
        if (!vars.mapSplits[from].ContainsKey(to)) vars.mapSplits[from][to] = new List<int>();
        vars.mapSplits[from][to].Add(visit);
    });

    vars.isMapSplit = (Func<string, string, bool>)((from, to) =>
    {
        if (from == to) return false;

        // Track visit count to maps to prevent splitting on re-entry
        if (!vars.mapsVisited.ContainsKey(from)) vars.mapsVisited[from] = new Dictionary<string, int>();
        int visitCount = 0;
        vars.mapsVisited[from].TryGetValue(to, out visitCount);
        vars.mapsVisited[from][to] = ++visitCount;

        return vars.mapSplits.ContainsKey(from) &&
               vars.mapSplits[from].ContainsKey(to) &&
               vars.mapSplits[from][to].Contains(visitCount);
    });

    vars.trackWarp = (Action<int, int>)((warpId, visit) => 
    {
        if (!vars.warpSplits.ContainsKey(warpId)) vars.warpSplits[warpId] = new List<int>();
        vars.warpSplits[warpId].Add(visit);
    });

    vars.isWarpSplit = (Func<int, int, bool>)((warpId, keysRemaining) => 
    {
        // Edge case: always ignore the portal after double jump in treetop village unless we've picked up the key
        if (warpId == 15004 && keysRemaining != 1) return false;

        // Track visit count
        int visitCount = 0;
        vars.warpsVisited.TryGetValue(warpId, out visitCount);
        vars.warpsVisited[warpId] = ++visitCount;

        return vars.warpSplits.ContainsKey(warpId) && 
               vars.warpSplits[warpId].Contains(visitCount);
    });

    vars.debug = (Action<string>)((msg) => print("[Turok ASL] " + msg));
}
