
class CpTimesPanel : ZUtil::UiPanel , ZUtil::IHandleCpEvents, ZUtil::IHandleGameStateEvents
{
    // Todo: convert this to a single array of int3's
    // could either combine cur and last time 
    // or calc split times as it's displayed.
    array<int> curTimes(0);
    array<int> lastTimes(0);
    array<int> bestTimes(0);
    array<int> splitTimes(0);
    // storing the count independently from array size
    // in order to make all checkpoint indexes valid
    int curTimesCount;
    int lastTimesCount;
    int bestTimesCount;
    int splitTimesCount;

    int currentCp = -1;
    bool doScroll = false;

    CpTimesPanel()
    {
        super("Checkpoint Times", vec2(5,350), vec2(300,100));

        m_moveHud = true;
    }
    
    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){
        // already detects if it's royal

        
        auto newCount = ZUtil::GetEffectiveCpCount(map, arena); 
            curTimes.Resize(newCount);
            lastTimes.Resize(newCount);
            bestTimes.Resize(newCount);
            splitTimes.Resize(newCount);

        Clear(curTimes);
        Clear(lastTimes);
        Clear(bestTimes);
        Clear(splitTimes);
        
        curTimesCount = lastTimesCount = splitTimesCount = bestTimesCount = 0;
        currentCp = -1;

        LoadMapTimeData();
    }

    void Clear(array<int>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }

    void OnPlayerLoaded(CSmPlayer@ player){
        // print("OnPlayerLoaded");
    }

    void OnCpTimesCountChangeEvent(int newCp)
    {   
        if (!g_gameState.isRoyalMap)
        {
            currentCp = newCp;
            if (currentCp == -1)
            {
                // print("Restart!");
                bool improvement = false;

                if (curTimesCount > bestTimesCount){
                    improvement =  true;
                } 

                // if we've reached the same CP, 
                // and current time is higher, yay!
                else if ((bestTimesCount == curTimesCount) 
                        && (curTimesCount >= 0)
                        && (curTimes[curTimesCount - 1] < bestTimes[curTimesCount - 1]) ){
                    improvement =  true;
                }


                for (uint i = 0; i < curTimes.Length; i++)
                {  
                    lastTimes[i] = curTimes[i];
                    lastTimesCount = curTimesCount;
                    
                    curTimes[i] = 0;
                    if (int(i) >= curTimesCount )
                    {
                        splitTimes[i] = 0;
                    }
                }
                curTimesCount = 0;
                    
                if (improvement)
                {
                    print("New best! saving :)");
                    for (uint i = 0; i < lastTimes.Length; i++)
                    {
                        bestTimes[i] = lastTimes[i];
                        bestTimesCount = lastTimesCount;
                        // print("" + bestTimes[i]);
                    }
                    SaveMapTimeData();
                }
            }
        }
    }


    void OnCPNewTimeEvent(int i, int newTime)
    {
        if (!g_gameState.isRoyalMap)
        {
            curTimes[i] = newTime;
            curTimesCount++;
            splitTimes[i] = int(bestTimes[i]) - newTime;
            splitTimesCount++;
        } else {
            auto curLmIndex = g_gameState.player.CurrentLaunchedRespawnLandmarkIndex;
            auto curLandmark = g_gameState.arena.MapLandmarks[curLmIndex];
            // print( tostring(curLandmark.Order - 1));

            currentCp = curLandmark.Order - 1;
            if (currentCp > 4) currentCp = 4;
            splitTimesCount = currentCp;

            curTimes[currentCp] = newTime;
            curTimesCount++;
            splitTimes[currentCp] = int(bestTimes[currentCp]) - newTime;
            if (curTimes[currentCp] < bestTimes[currentCp] || bestTimes[currentCp] == 0)
            {
                bestTimes[currentCp] = curTimes[currentCp];
                SaveMapTimeData();
            }
        }
        doScroll = true;
        startnew(FadeColorToWhite);
    }
    
    // void OnSettingsChanged() override 
    // {

    // }

    // void Update(float dt) override 
    // {

    // }

    void Render() override 
    { 
        if(!g_gameState.hasMap) return;

        UI::SetNextWindowPos(int(m_pos.x), int(m_pos.y));
        UI::SetNextWindowSize(int(m_size.x), Math::Min(curTimes.Length, 8) * 25 + 33 + 25);
        UI::Begin("CP Times", UI::WindowFlags::NoTitleBar 
                    | UI::WindowFlags::NoCollapse 
                    | UI::WindowFlags::NoDocking);

        UI::Text(g_gameState.coloredMapName);

        UI::BeginChild("cpTimesList");
        if(UI::BeginTable("table", 4, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("CP", UI::TableColumnFlags::WidthFixed, 20);
            UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 65);
            UI::TableSetupColumn("Split", UI::TableColumnFlags::WidthFixed, 65);
            UI::TableSetupColumn("Best", UI::TableColumnFlags::WidthFixed, 65);
            UI::TableHeadersRow();

            for (uint i = 0; i < curTimes.Length; i++)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                // CP text
                if (g_gameState.isRoyalMap)
                {
                    string letter = "";
                    if (i == 0) letter = "\\$fffW";
                    else if (i == 1) letter = "\\$0f0G";
                    else if (i == 2) letter = "\\$55fB";
                    else if (i == 3) letter = "\\$f00R";
                    else if (i == 4) letter = "\\$888B";
                    UI::Text( letter ); UI::NextColumn();
                } else {
                    UI::Text( (i == curTimes.Length - 1 ? "F" : tostring(i + 1)) ); 
                }
                UI::TableNextColumn();

                // Current/Last Time Text
                string color;
                int displayTime = 0;
                if(int(i) == currentCp) {
                    string h = FloatToHex(fade);
                    color = "\\$" + h + "f" + h;
                    displayTime = curTimes[i];
                }
                else if(int(i) > currentCp) {
                    color = color_Dark;
                    displayTime = lastTimes[i];
                } else {
                    color = color_Light;
                    displayTime = curTimes[i];
                }
                UI::Text( color + (displayTime == 0 ? "" : Time::Format( displayTime )));
                UI::TableNextColumn();
                
                auto split = splitTimes[i];
                bool pastCur = int(i) > currentCp;
                string sColor;
                if (split > 0) {
                    sColor = pastCur ? color_DarkPos : color_LightPos;
                } else if (split < 0){
                    sColor = pastCur ? color_DarkNeg : color_LightNeg;
                } else{
                    sColor = color_Dark;
                }
                
                // Split Time Text
                UI::Text(sColor + Time::Format( Math::Abs(splitTimes[i])) ); 
                UI::TableNextColumn();

                // Best Time Text
                UI::Text("" + (bestTimes[i] == 0 ? "" :Time::Format(bestTimes[i])));
                UI::TableNextColumn();

            }

            if (doScroll)
            {
                float max = UI::GetScrollMaxY();
                auto dist = Math::Max(currentCp - 3,0) / Math::Max(float( curTimes.Length  - 5),1.0f) * max;
                UI::SetScrollY(dist);
                doScroll = false;
            }

        UI::EndTable();
        }
        UI::EndChild();

        UI::End();

    }

    
    void SaveMapTimeData()
    {
        if (!g_gameState.hasMap ) return;

        auto mapId = g_gameState.map.MapInfo.MapUid;
        auto path = GetJsonSavePath();

        auto obj = Json::Object();
        auto bestArr = Json::Array();

        for (uint i = 0; i < curTimes.Length; i++)
        {
            bestArr.Add(Json::Value(bestTimes[i]));
        }

        obj["MapName"] = g_gameState.trimmedMapName;
        obj["MapUid"] = mapId;
        obj["BestTimes"] = bestArr;

        Json::ToFile(path, obj);
    }
    
    string GetJsonSavePath(){
        return g_saveFolderPath + "\\" + g_gameState.trimmedMapName + "-" + g_gameState.map.MapInfo.MapUid + ".json";
    }

    void LoadMapTimeData()
    {
        if (!g_gameState.hasMap) return;

        auto path = GetJsonSavePath();
        auto oldPath = g_saveFolderPath + "\\" + g_gameState.map.MapInfo.MapUid + ".json";
        
        if (IO::FileExists(path))
        {
            print("Loading best time data for: " + g_gameState.trimmedMapName);

            bestTimesCount = LoadTimes(path);
            
        } else if (IO::FileExists(oldPath)) {
            print("Found old file for " + g_gameState.trimmedMapName + ", loading it and resaving with new file name format");
            bestTimesCount = LoadTimes(oldPath);
            IO::Delete(oldPath);
            SaveMapTimeData();
        }
    }

    uint LoadTimes(string path){
        auto data = Json::FromFile(path);
        auto times = data["BestTimes"];

        uint c = 0;
        for (uint i = 0; i < times.Length; i++)
        {
            int thisTime = times[i];
            if (thisTime != 0) c++;

            bestTimes[i] = thisTime;
        }

        return c;
    }
}