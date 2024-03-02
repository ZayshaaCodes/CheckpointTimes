
class CpDataManager : ZUtil::IHandleGameStateEvents, ZUtil::IHandleCpEvents
{
    CpRunData@ bestRun = CpRunData();
    CpRunData@ previousBestRun = CpRunData();
    CpRunData@ currentRun = CpRunData();
    array<CpRunData> m_runHistory(0);

    uint currentCp = 0;
    uint mapCpCount = 0;
    int respawnsAtLastCP = 0;

    CpDataManager() {
        m_runHistory.Resize(GeneralSettings::historyCount);
    }

    void ResizeAllRunData(const int &in count){
        bestRun.Resize(count);
        currentRun.Resize(count);
        previousBestRun.Resize(count);

        for (uint i = 0; i < m_runHistory.Length; i++)
            m_runHistory[i].Resize(count);
    }

    void ClearAllRunData(){
        bestRun.Clear();
        currentRun.Clear();
        previousBestRun.Clear();

        for (uint i = 0; i < m_runHistory.Length; i++)
            m_runHistory[i].Clear();
    }

    void AppendRun(CpRunData@ run){

        auto lastrun = m_runHistory[0];
        if(run.position == 0) return;
        if(lastrun.position > 0 && lastrun.times[lastrun.position - 1] == run.times[0])
             return;

        if(m_runHistory[0].position > 1){
            for (uint i = m_runHistory.Length - 1; i >= 1 ; i--)
            {
                m_runHistory[i] = m_runHistory[i - 1];
            }    
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
        // print("Attempting to load data for: " + trimmedName);

        mapCpCount = ZUtil::GetEffectiveCpCount(map, arena); 
        // print(mapCpCount + " cps?");
        ResizeAllRunData(mapCpCount);
        ClearAllRunData();

        LoadMapTimeData(map);
        currentCp = 0;
    }

    void OnPlayerLoaded(CSmPlayer@ player){
        
    }

    void ClearMapData(){
        bestRun.Clear();
        currentRun.Clear();
        for (uint i = 0; i < m_runHistory.Length; i++)
        {
            m_runHistory[i].Clear();
        }
        SaveMapTimeData();
    }

    void OnCpTimesCountChangeEvent(int newCp)
    {   
        if (!g_gameState.isRoyalMap)
        {
            currentCp = newCp + 1;
            if (newCp == -1)
            {
                //print("Restart! " + currentRun.position);
                respawnsAtLastCP = 0;
                bool improvement = false;

                auto pos = currentRun.position - 1;

                if (currentRun.position > bestRun.position){
                    improvement = true;
                } 
                else if ((bestRun.position == currentRun.position)                         
                && (currentRun.position >= 0)
                && pos <= int(currentRun.times.Length) && pos >=  0
                && (currentRun.times[pos] < bestRun.times[pos]))
                {
                    improvement = true;
                }

                if (improvement) currentRun.wasPB = true;
                
                AppendRun(currentRun);

                if (improvement)
                {
                    print("New Personal Best! " + Time::Format(currentRun.times[pos]));
                    auto temp = bestRun;
                    @bestRun = currentRun;
                    @currentRun = temp;
                    
                } 
                currentRun.ClearAll();
                SaveMapTimeData();
            }
        }
    }

    int lastTime = 0;
    void OnCPNewTimeEvent(int i, int newTime)
    {
        if (newTime < 0)
        {
            //print("invalid time: " + newTime);
            return;
        }
        if (lastTime >= newTime)
        {
            
        }
        lastTime = newTime;        

		auto player = ZUtil::GetViewingPlayer();
        CSceneVehicleVis@ vis = null;
		auto sceneVis = g_app.GameScene;
		if (player !is null)
			@vis = VehicleState::GetVis(sceneVis, player);
		else 
			@vis = VehicleState::GetSingularVis(sceneVis);
		if (vis is null)
			return;

        
        auto speed=  vis.AsyncState.WorldVel.Length()* 3.6f;
        //print(speed);
        currentRun.speeds[i] = speed;
        
        if (!g_gameState.isRoyalMap)
        {
            auto resCount = g_gameState.player.Score.NbRespawnsRequested;

            //print(resCount - respawnsAtLastCP);

            currentRun.times[i] = newTime;
            currentRun.resets[i] = resCount - respawnsAtLastCP;
            currentRun.position++;

            respawnsAtLastCP = resCount;     
        } else { // royal map
            auto curLmIndex = g_gameState.player.CurrentLaunchedRespawnLandmarkIndex;
            auto curLandmark = g_gameState.arena.MapLandmarks[curLmIndex];

            int timeIndex = curLandmark.Order - 1;
            // print("new time: " + timeIndex + " : " + newTime);

            int oldTime = currentRun.times[timeIndex];
            if (oldTime != 0)
            {
                m_runHistory[0].times[timeIndex] = oldTime;
            }

            currentRun.times[timeIndex] = newTime;
            
            if (currentRun.times[timeIndex] < bestRun.times[timeIndex] || bestRun.times[timeIndex] == 0)
            {
                bestRun.times[timeIndex] = currentRun.times[timeIndex];
                bestRun.resets[timeIndex] = currentRun.resets[timeIndex];
                SaveMapTimeData();
            }


        }

        cpTimesPanel.doScroll = true;
    }
    
    
    void SaveMapTimeData()
    {
        if (!g_gameState.hasMap) return;

        auto map = g_gameState.map;

        auto mapId = map.MapInfo.MapUid;
        auto path = GetJsonSavePath(map);

        print(path);
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
                bestRun.FromJsonObject(data["BestRun"], mapCpCount);

                auto runHistory = data["RunHistory"];
                
                uint historyCount = Math::Min(runHistory.Length, GeneralSettings::historyCount);
                for (uint i = 0; i < historyCount; i++)
                {
                    m_runHistory[i].FromJsonObject(runHistory[i], mapCpCount);
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