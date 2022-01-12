// [Setting]
// float g_fontSize = 20;

class CpTimesPanel : ZUtil::UiPanel , ZUtil::IHandleCpEvents, ZUtil::IHandleGameStateEvents
{
    // Todo: convert this to a single array of int3's
    // could either combine cur and last time 
    // or calc split times as it's displayed.
    array<int> curTimes(0);
    array<int> lastTimes(0);
    array<int> bestTimes(0);
    array<int> splitTimes(0);
    array<int> resetCounts(0);
    array<int> lastResetCounts(0);
    array<int> bestResetCounts(0);
    // storing the count independently from array size
    // in order to make all checkpoint indexes valid
    int curTimesCount;
    int lastTimesCount;
    int bestTimesCount;
    int splitTimesCount;

    int currentCp = -1;
    bool doScroll = false;

    int respawnsAtLastCP = 0;

    Resources::Font@ g_font;

    CpTimesPanel()
    {
        super("Checkpoint Times", vec2(1,400), vec2(380,100));

        @g_font = Resources::GetFont("DroidSans-Bold.ttf",20);
        m_moveHud = true;
    }
    
    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){
        // already detects if it's royal

        
        auto newCount = ZUtil::GetEffectiveCpCount(map, arena); 
            curTimes.Resize(newCount);
            lastTimes.Resize(newCount);
            bestTimes.Resize(newCount);
            splitTimes.Resize(newCount);
            resetCounts.Resize(newCount);
            lastResetCounts.Resize(newCount);
            bestResetCounts.Resize(newCount);

        Clear(curTimes);
        Clear(lastTimes);
        Clear(bestTimes);
        Clear(splitTimes);
        Clear(resetCounts);
        Clear(lastResetCounts);
        Clear(bestResetCounts);
        
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
                    lastResetCounts[i] = resetCounts[i];
                    lastTimesCount = curTimesCount;
                    
                    curTimes[i] = 0;
                    resetCounts[i] = 0;
                    if (int(i) >= curTimesCount )
                    {
                        splitTimes[i] = 0;
                    }
                }
                curTimesCount = 0;
                respawnsAtLastCP = 0;
                if (improvement)
                {
                    print("New best! saving :)");
                    for (uint i = 0; i < lastTimes.Length; i++)
                    {
                        bestTimes[i] = lastTimes[i];
                        bestResetCounts[i] = lastResetCounts[i];
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
        if (newTime < 0)
        {
            print("invalid time: " + newTime);
            return;
        }
        
        if (!g_gameState.isRoyalMap)
        {
            auto resCount = g_gameState.player.Score.NbRespawnsRequested;

            //print(resCount - respawnsAtLastCP);

            curTimes[i] = newTime;
            resetCounts[i] = resCount - respawnsAtLastCP;
            curTimesCount++;
            splitTimes[i] = int(bestTimes[i]) - newTime;
            splitTimesCount++;     

            respawnsAtLastCP = resCount;     
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
                bestResetCounts[currentCp] = resetCounts[currentCp];
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

        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,.4f));
        UI::SetNextWindowPos(int(m_pos.x), int(m_pos.y));
        UI::SetNextWindowSize(int(m_size.x), Math::Min(curTimes.Length, 8) * 29
         + 35 + 25);
        UI::Begin("CP Times", UI::WindowFlags::NoTitleBar 
                    | UI::WindowFlags::NoCollapse 
                    | UI::WindowFlags::NoDocking);
                    

        UI::PushFont(g_font);

        UI::Text("\\$s" + g_gameState.coloredMapName);
        
        UI::BeginChild("cpTimesList");
        if(UI::BeginTable("table", 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, 20);
            UI::TableSetupColumn("\\$sR", UI::TableColumnFlags::WidthFixed, 20);
            UI::TableSetupColumn("\\$sTime", UI::TableColumnFlags::WidthFixed, 80);
            UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, 85);
            UI::TableSetupColumn("\\$sBest", UI::TableColumnFlags::WidthFixed, 85);
            UI::TableHeadersRow();

            string color;

            for (uint i = 0; i < curTimes.Length; i++)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                // CP text
                if (g_gameState.isRoyalMap)
                {
                    string letter = "";
                    if (i == 0) letter = "\\$s\\$fffW";
                    else if (i == 1) letter = "\\$s\\$0f0G";
                    else if (i == 2) letter = "\\$s\\$55fB";
                    else if (i == 3) letter = "\\$s\\$f00R";
                    else if (i == 4) letter = "\\$s\\$888B";
                    UI::Text( letter ); UI::NextColumn();
                } else {
                    UI::Text( "\\$s" + (i == curTimes.Length - 1 ? "F" : tostring(i + 1)) ); 
                }
                UI::TableNextColumn();

                // Best Time Text
                int displayReset = 0;

                if(int(i) == currentCp) {
                    string h = FloatToHex(fade);
                    color = "\\$" + h + "f" + h;
                    displayReset = resetCounts[i];
                }
                else if(int(i) > currentCp) {
                    color = color_Dark;
                    displayReset = lastResetCounts[i];
                } else {
                    color = color_Light;
                    displayReset = resetCounts[i];
                }

                UI::Text("\\$s" + color + displayReset);
                UI::TableNextColumn();

                // Current/Last Time Text
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
                UI::Text( "\\$s" + color + (displayTime == 0 ? "" : Time::Format( displayTime )));
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
                UI::Text("\\$s" + sColor + Time::Format( Math::Abs(splitTimes[i])) ); 
                UI::TableNextColumn();

                // Best Time Text
                UI::Text("\\$s" + (bestTimes[i] == 0 ? "" : bestResetCounts[i] + " - " + Time::Format(bestTimes[i])));
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

        UI::PopFont();

        UI::End();
        UI::PopStyleColor();

    }

    
    void SaveMapTimeData()
    {
        if (!g_gameState.hasMap ) return;

        auto mapId = g_gameState.map.MapInfo.MapUid;
        auto path = GetJsonSavePath();

        auto obj = Json::Object();
        auto bestArr = Json::Array();
        auto resArr = Json::Array();

        for (uint i = 0; i < curTimes.Length; i++)
        {
            bestArr.Add(Json::Value(bestTimes[i]));
            resArr.Add(Json::Value(bestResetCounts[i]));
            //print(resetCounts[i]);
        }

        obj["MapName"] = g_gameState.trimmedMapName;
        obj["MapUid"] = mapId;
        obj["BestTimes"] = bestArr;
        obj["ResetCounts"] = resArr;

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
        auto resCounts = data["ResetCounts"];

        uint c = 0;
        for (uint i = 0; i < times.Length; i++)
        {
            int thisTime = times[i];
            if (thisTime != 0) c++;

            bestTimes[i] = thisTime;
        }

        if(int(resCounts.GetType()) == 4)
        {
            print("found reset counts");
            for (uint i = 0; i < resCounts.Length; i++)
            {
                bestResetCounts[i] = resCounts[i];
            }
        }

        return c;
    }
}