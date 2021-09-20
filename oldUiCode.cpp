


uint mapCpCount = 0;
int currentCp = -1;
bool doScroll = false;
string mapName;


//in royal cpIndex is only ever 1 or 0;
void OnCpChange(int cpIndex){
    currentCp = cpIndex;
    if (cpIndex < 0)
    {
        bool improvement = false;
        
        //if we've reached a higher CP, yay!
        if (bl < cl){
            improvement =  true;
        } 
        // if we've reached the same CP, 
        // and last cur time is higher, yay!
        else if ( (bl == cl) && (curTimes[cl - 1] < bestTimes[cl - 1]) ){
            improvement =  true;
        }

        for (uint i = 0; i < curTimes.Length; i++)
        {  
            lastTimes[i] = curTimes[i];
            lastTimesCount = curTimesCount;
            
            curTimes[i] = 0;
            if (i >= cl)
            {
                splitTimes[i] = 0;
            }
        }

        if (improvement)
        {
            print("New best! saving :)");
            for (uint i = 0; i < lastTimes.Length; i++)
            {
                bestTimes[i] = lastTimes[i];
                // print("" + bestTimes[i]);
            }
            SaveMapTimeData();
        }
    }
}

void OnNewTime(int i, int newTime){
    // print("New time: " + i + " : " + Time::Format(newTime));
    curTimes[i] = newTime;
    splitTimes[i] = int(bestTimes[i]) - newTime;
    startnew(FadeColorToWhite);
    doScroll = true;
}

float g_dt;
void Update(float dt){
    g_dt = dt;
    auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
    auto player = ZUtil::GetPlayer(playground);
    if (!isMapLoaded)
    {   
        if (playground !is null && playground.Map !is null)
        {
            LoadMapTimeData(bestTimes);
            mapName = playground.Map.MapInfo.NameForUi;
            mapName = Regex::Replace(mapName, "\\$[wnoitsgz]", "");
            mapName = Regex::Replace(mapName, "\\$", "\\$");
            isMapLoaded = true;
        }
    } else {

        isMapLoaded = (playground !is null && playground.Map !is null);
    }

    if (isMapLoaded && _cpDataManager !is null)
    {
        _cpDataManager.Update(player);
    }
}

float fade = 0;
void FadeColorToWhite(){
    float t = 0;
    while(t < 1)
    {
        t += g_dt / 1000 / 2;

        fade = Math::Lerp(0.0f, 1.0f, t);

        yield();
    }
}

void Render()
{
    if(!isMapLoaded) return;

    UI::SetNextWindowPos(0, 150);
    UI::SetNextWindowSize(280, Math::Min(mapCpCount, 8) * 25 + 33 + 25);
    UI::Begin("CP Times", UI::WindowFlags::NoTitleBar 
                | UI::WindowFlags::NoCollapse 
                | UI::WindowFlags::NoDocking);

    UI::Text(mapName);

    UI::BeginGroup();
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
            if (isRoyalMap)
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
            auto dist = Math::Max(currentCp - 3,0) / Math::Max(float(mapCpCount - 5),1.0f) * max;
            UI::SetScrollY(dist);
            doScroll = false;
        }

      UI::EndTable();
    }
    UI::EndGroup();

    UI::End();

    // if (g_debugging)
    // {
    //     auto playground = cast<CSmArenaClient>(app.CurrentPlayground);
    //     auto player = ZUtil::GetPlayer(playground);
    //     _cpDataManager.Render(player);
    // }
}

array<string> letters = {"A","B","C","D","E","F"};
string FloatToHex(float v){
    auto i = int(Math::Floor(v * 16));
    i = Math::Clamp(i, 0, 15);
    if (i < 10)
    {
        return tostring(i);
    } 
    return letters[i - 10];
}

int LoadMapTimeData(array<int>@ arr){
    auto pg = cast<CSmArenaClient>(app.CurrentPlayground);
    if (pg is null) return 0;
    auto map = pg.Map;

    auto mapId = map.MapInfo.MapUid;
    auto name = map.MapInfo.NameForUi;

    mapCpCount = ZUtil::GetEffectiveCpCount(pg);
    bestTimes.Resize(mapCpCount);
    curTimes.Resize(mapCpCount);
    splitTimes.Resize(mapCpCount);
    lastTimes.Resize(mapCpCount);

    auto path = g_saveFolderPath + "\\" + mapId + ".json";
    if (IO::FileExists(path))
    {
        print("Loading best time data for: " + name);
        auto data = Json::FromFile(path);
        auto times =  data["BestTimes"];
        for (uint i = 0; i < times.Length; i++)
        {
            bestTimes[i] = int(times[i]);
        }
    }

    return 0;
}

void SaveMapTimeData()
{
    auto pg = cast<CSmArenaClient>(app.CurrentPlayground);
    if (pg is null) return;
    auto map = pg.Map;
    if (map is null) return;

    auto mapId = map.MapInfo.MapUid;
    auto path = g_saveFolderPath + "\\" + mapId + ".json";

    auto obj = Json::Object();
    auto bestArr = Json::Array();

    for (uint i = 0; i < curTimes.Length; i++)
    {
        bestArr.Add(Json::Value(bestTimes[i]));
    }

    obj["MapUid"] = mapId;
    obj["BestTimes"] = bestArr;

    Json::ToFile(path, obj);
}


bool windowsVisible = true;
void RenderMenu(){
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff CP Times", selected: windowsVisible, enabled: GetApp().CurrentPlayground !is null))
	{
		windowsVisible = !windowsVisible;
	}
}