
class CpDataManager : ZUtil::IHandleGameStateEvents, ZUtil::IHandleCpEvents
{

    CpRunData@ bestRun = CpRunData();
    CpRunData@ currentRun = CpRunData();
    array<CpRunData> m_runHistory(0);

    uint currentCp = 0;
    uint mapCpCount = 0;
    int respawnsAtLastCP = 0;

    CpDataManager() {
        m_runHistory.Resize(GeneralSettings::historyCount);
    }

    void ResizeAllRundData(const int &in count){
        bestRun.Resize(count);
        currentRun.Resize(count);

        for (uint i = 0; i < m_runHistory.Length; i++)
            m_runHistory[i].Resize(count);
    }

    void ClearAllRunData(){
        bestRun.Clear();
        currentRun.Clear();
        for (uint i = 0; i < m_runHistory.Length; i++)
            m_runHistory[i].Clear();
    }

    void AppendRun(CpRunData@ run){
        for (uint i = m_runHistory.Length - 1; i >= 1 ; i--)
        {
            m_runHistory[i] = m_runHistory[i - 1];
        }
        m_runHistory[0] = run;
    }

    void OnSettingsChanged() 
    {
        if (m_runHistory.Length != uint(GeneralSettings::historyCount))
        {
            m_runHistory.Resize(GeneralSettings::historyCount);
            for (uint i = 0; i < m_runHistory.Length; i++)
            {
                m_runHistory[i].Resize(mapCpCount);
            }
        }
    }

    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){

        string trimmedName =  ZUtil::GetTrimmedMapName(map);
        print("Attempting to load data for: " + trimmedName);

        mapCpCount = ZUtil::GetEffectiveCpCount(map, arena); 
        ClearAllRunData();
        ResizeAllRundData(mapCpCount);

        LoadMapTimeData(map);
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
                    print("New best!");
                    auto temp = bestRun;
                    @bestRun = currentRun;
                    @currentRun = temp;
                    
                } 
                currentRun.ClearAll();
                
                SaveMapTimeData();
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
        cpTimesPanel.doScroll = true;
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

        for (uint i = 0; i < m_runHistory.Length; i++)
        {
            lastRunsArr.Add(m_runHistory[i].ToJsonObject());
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
        string trimmedName =  ZUtil::GetTrimmedMapName(map);
        
        if (IO::FileExists(path))
        {
            auto data = Json::FromFile(path);

            int fVer = 0;
            if (data.HasKey("FormatVer"))
                fVer = data["FormatVer"];

            print("Loading data (" + fVer + ") :" + trimmedName + "");

            if(fVer == 1) 
            {
                bestRun.FromJsonObject(data["BestRun"]);

                auto runHistory = data["RunHistory"];
                
                uint historyCount = Math::Min(runHistory.Length, GeneralSettings::historyCount);
                for (uint i = 0; i < historyCount; i++)
                {
                    m_runHistory[i].FromJsonObject(runHistory[i]);
                }
            } else if (fVer == 0){

                //getBestRunData
                auto times = data["BestTimes"];
                auto resets = data["ResetCounts"];
                
                for (uint i = 0; i < times.Length; i++)
                {
                    bestRun.times[i] = times[i];
                    if (times[i] != 0)
                        bestRun.position++;
                }

                if(int(resets.GetType()) == 4)
                {
                    // print("found reset counts");
                    for (uint i = 0; i < resets.Length; i++)
                    {
                        bestRun.resets[i] = resets[i];
                    }
                }
            }


        } 
    }

}