
class CpDataManager : ZUtil::IHandleGameStateEvents, ZUtil::IHandleCpEvents
{

    CpRunData@ bestRun = CpRunData();
    CpRunData@ currentRun = CpRunData();
    array<CpRunData> LastRunsData(0);

    int currentCp = 0;
    int mapCpCount = 0;
    int respawnsAtLastCP = 0;

    CpDataManager() {
        LastRunsData.Resize(g_saveCount);
    }

    void AppendRun(CpRunData@ run){
        for (uint i = LastRunsData.Length - 1; i >= 1 ; i--)
        {
            LastRunsData[i] = LastRunsData[i - 1];
        }
        LastRunsData[0] = run;
    }

    void OnSettingsChanged() 
    {
        if (LastRunsData.Length != g_saveCount)
        {
            print("resize");
            LastRunsData.Resize(g_saveCount);
            for (uint i = 0; i < LastRunsData.Length; i++)
            {
                LastRunsData[i].Resize(mapCpCount);
            }
        }
    }

    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){
        // print("Attempting to load data for: " + map.MapName);
        //load Run Data From File

        //LoadMapTimeData(map);

        mapCpCount = ZUtil::GetEffectiveCpCount(map, arena); 
        bestRun.Resize(mapCpCount);
        currentRun.Resize(mapCpCount);
        for (uint i = 0; i < LastRunsData.Length; i++)
        {
            LastRunsData[i].Resize(mapCpCount);
        }

        // LastRunsData[0].times[0] = 1000;
        // LastRunsData[0].times[1] = 2000;
        // LastRunsData[0].times[2] = 3000;
        // LastRunsData[0].times[3] = 4000;
        // LastRunsData[0].times[4] = 5000;
        
        // LastRunsData[1].times[0] = 4000;
        // LastRunsData[1].times[1] = 3000;
        // LastRunsData[1].times[2] = 2000;
        // LastRunsData[1].times[3] = 1000;
        // LastRunsData[1].times[4] = 0000;
        
        // curTimesCount = lastTimesCount = splitTimesCount = bestTimesCount = 0;
        currentCp = 0;
    }

    void OnPlayerLoaded(CSmPlayer@ player){
        
    }


    void OnCpTimesCountChangeEvent(int newCp)
    {   
        currentCp = newCp + 1;
        if (!g_gameState.isRoyalMap)
        {
            if (newCp == -1)
            {
                //print("Restart!");

                respawnsAtLastCP = 0;

                bool improvement = false;

                // if we've reached the same CP, 
                // and current time is higher, yay!
                //print(currentRun.times.Length + " | " + bestRun.times.Length + " | " + currentRun.position);
                if (currentRun.position > bestRun.position){
                    improvement = true;
                } 
                else if ((bestRun.position == currentRun.position)                         
                && (currentRun.position >= 0)                        
                && (currentRun.times[currentRun.position - 1] < bestRun.times[currentRun.position - 1]))
                {
                    improvement = true;
                }

                if (improvement) currentRun.wasPB = true;
                AppendRun(currentRun);

                if (improvement)
                {
                    //print("New best!");
                    auto temp = bestRun;
                    @bestRun = currentRun;
                    @currentRun = temp;
                    
                    SaveMapTimeData();
                } 
                currentRun.ClearAll();
            }
        }
    }

    void OnCPNewTimeEvent(int i, int newTime)
    {
        //print("new time: " +  i + " : " + newTime);
        if (newTime < 0)
        {
            print("invalid time: " + newTime);
            return;
        }
        
        if (!g_gameState.isRoyalMap)
        {
            auto resCount = g_gameState.player.Score.NbRespawnsRequested;

            //print(resCount - respawnsAtLastCP);

            currentRun.times[i] = newTime;
            currentRun.resets[i] = resCount - respawnsAtLastCP;
            currentRun.position++;

            respawnsAtLastCP = resCount;     
        } 
        
        // else {
        //     auto curLmIndex = g_gameState.player.CurrentLaunchedRespawnLandmarkIndex;
        //     auto curLandmark = g_gameState.arena.MapLandmarks[curLmIndex];
        //     // print( tostring(curLandmark.Order - 1));

        //     currentCp = curLandmark.Order - 1;
        //     if (currentCp > 4) currentCp = 4;
        //     splitTimesCount = currentCp;

        //     curTimes[currentCp] = newTime;
        //     currentRun.count++;
        //     splitTimes[currentCp] = int(bestTimes[currentCp]) - newTime;
        //     if (curTimes[currentCp] < bestTimes[currentCp] || bestTimes[currentCp] == 0)
        //     {
        //         bestTimes[currentCp] = curTimes[currentCp];
        //         bestResetCounts[currentCp] = resetCounts[currentCp];
        //         // SaveMapTimeData();
        //     }
        // }
        // doScroll = true;
        // startnew(FadeColorToWhite);
    }
    
    
    void SaveMapTimeData()
    {
        if (!g_gameState.hasMap) return;

        auto map = g_gameState.map;

        auto mapId = map.MapInfo.MapUid;
        auto path = GetJsonSavePath(map);

        auto obj = Json::Object();
        auto lastRunsArr = Json::Array();

        for (uint i = 0; i < LastRunsData.Length; i++)
        {
            lastRunsArr.Add(LastRunsData[i].ToJsonObject());
        }

        obj["FormatVer"] = Json::Value(1.0);

        obj["MapName"] = ZUtil::GetTrimmedMapName(map);
        obj["MapUid"] = mapId;
        obj["BestRun"] = bestRun.ToJsonObject();
        obj["RunHistory"] = lastRunsArr;

        Json::ToFile(path, obj);
    }
    
    string GetJsonSavePath(CGameCtnChallenge@ map){
        return g_saveFolderPath + "\\" + ZUtil::GetTrimmedMapName(map) + "-" + g_gameState.map.MapInfo.MapUid + ".json";
    }

    void LoadMapTimeData(CGameCtnChallenge@ map)
    {
        if (map is null) return;

        auto path = GetJsonSavePath(map);
        auto oldPath = g_saveFolderPath + "\\" + map.MapInfo.MapUid + ".json";
        
        string trimmedName =  ZUtil::GetTrimmedMapName(map);
        
        if (IO::FileExists(path))
        {
            print("Loading best time data for: " + trimmedName);
            LoadTimes(path);
        } 
    }

    void LoadTimes(string path){
        // auto data = Json::FromFile(path);
        // auto times`` = data["BestTimes"];
        // auto resCounts = data["ResetCounts"];

        // uint c = 0;
        // for (uint i = 0; i < times.Length; i++)
        // {
        //     int thisTime = times[i];
        //     if (thisTime != 0) c++;

        //     bestTimes[i] = thisTime;
        // }

        // if(int(resCounts.GetType()) == 4)
        // {
        //     print("found reset counts");
        //     for (uint i = 0; i < resCounts.Length; i++)
        //     {
        //         bestResetCounts[i] = resCounts[i];
        //     }
        // }

        // return c;
    }
}