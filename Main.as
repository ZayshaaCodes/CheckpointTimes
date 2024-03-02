CTrackMania@ g_app;
string g_oldSaveFolderPath = IO::FromDataFolder("CheckpointTimes");
string g_saveFolderPath = IO::FromDataFolder("PluginStorage/CheckpointTimes");

bool g_debugging = false;

ZUtil::PanelManager@ _panelManager = ZUtil::PanelManager();
ZUtil::GameState@ g_gameState = ZUtil::GameState();

const MLFeed::HookRaceStatsEventsBase_V4@ theHook;
// const MLFeed::SharedGhostDataHook_V2@ theGhost;

float g_dt;
uint16 g_playersArrOffset = 0;

RaceEventsHandler@ g_raceEvents; 

MapInfo@ g_mapInfo = MapInfo();
CpDataContext@ g_cpData;

CpTimesPanel@ _timesPanel;
CpHud@ _hud;

string g_target = "";
string g_localPlayer = "";
string g_localPlayerTag = "";
 
UI::Font @g_font;
int g_fontface;

void Main(){

    if (!IO::FolderExists(g_saveFolderPath)) {
        IO::CreateFolder(g_saveFolderPath);
    }

    g_fontface = nvg::LoadFont("DroidSans-Bold.ttf");
    @g_font = UI::LoadFont("DroidSans-Bold.ttf", TimesPanel_fontSize, -1,-1, true, true, true);

    @theHook = MLFeed::GetRaceData_V4();
    @g_app = cast<CTrackMania>(GetApp());

    g_localPlayer = g_app.LocalPlayerInfo.Name;
    g_localPlayerTag = g_app.LocalPlayerInfo.ClubTag;

    
    @g_cpData = CpDataContext();

    @_timesPanel = CpTimesPanel(g_cpData);
    @_hud = CpHud();
    
    _panelManager.AddPanel(_timesPanel);
    _panelManager.AddPanel(_hud);

    @g_raceEvents = RaceEventsHandler();

    g_gameState.RegisterMapLoadCallback(@MapLoadEvent);
    g_gameState.RegisterPlayerLoadCallback(@PlayerLoadEvent);

    g_raceEvents.HookEvent("RaceStats_PlayerCP", OnCpEvent);
    g_raceEvents.HookEvent("GhostData", OnGhostEvent);
    // g_raceEvents.HookEvent("RaceStats_PlayerRaceTimes", OnRaceTimesEvent);

    print("Initialized!");
}

//{"zayshaa", "1", "39703", "16502", "2", "0,1963700"}
// name, cpNum, cpTime, pbTime, status, [?,startTime]
int lastCpNum = 0;
int lastResets = 0;
int lastStatus = 2;
bool isDriving = false;

bool respawned = true;
float respawnTimer = 0;
int totalLostTime = 0;

void OnCpEvent(MwFastBuffer<wstring> data)
{
    auto name = data[0];
    if (name != g_target) return;

    // print("OnCpEvent");
    //{"2364", "2364", "False", "0", "False", "0", "1", "1"}
    int cpNum = Text::ParseInt(data[1]);
    int cpTime = Text::ParseInt(data[2]);
    int pbTime = Text::ParseInt(data[3]);
    int status = Text::ParseInt(data[4]);
    array<string> other = string(data[5]).Split(",");
    int resets = Text::ParseInt(other[0]);
    int startTime = Text::ParseInt(other[1]);

    // print("name: " + name + " status: " + status + " cpNum: " + cpNum + " cpTime: " + cpTime + " pbTime: " + pbTime + " startTime: " + startTime + " resets: " + resets);
    if (status == 1 ) //spawning
    {
        if(!isDriving){
            // print("Spawn/Restart");
        }
        else {
            // print("Restart");
        }
        
        //if restarting after reaching a cp, copy the current run to the last run
        if(lastCpNum > 0)
        {
            g_cpData.curCp = 0;
        
            g_cpData.current.To(g_cpData.last);
            g_cpData.current.ClearAll();
            
            _timesPanel.UpdateAllRows(); 
            lastCpNum = 0;
            lastResets = 0;
            totalLostTime = 0;
        }
    }
    //Handle Driving Status: If the status is 2 (driving), different actions occur depending on the checkpoint number and the previous status:
    // If the status just changed to driving, a run has started
    // If the checkpoint number (cpNum) is greater than the last checkpoint (lastCpNum), the player has passed a checkpoint, or reached the finish line.
    if (status == 2){ //driving
        if (lastStatus != 2){
            // print("Go!");
        } else if (cpNum > lastCpNum){

            auto playerApi = cast<CSmScriptPlayer>(g_gameState.player.ScriptAPI);

            float speed = playerApi.Velocity.Length() * 3.6;

            g_cpData.curCp = cpNum; // 1 indexed, first cp will occupy row 0, cp 0 is basically the start line
            int cpIndex = cpNum - 1;
            
            g_cpData.current.speeds[cpIndex] = speed;
            g_cpData.current.times[cpIndex] = cpTime;

            _timesPanel.UpdateRow(cpIndex);
            _hud.OnCPNewTimeEvent(cpIndex, cpTime, int(speed));

            //check if it's the finish line
            if (cpNum == g_mapInfo.numCps){
                // BP CHECK 
                if (g_cpData.best.times[g_mapInfo.numCps-1] == 0 || cpTime < g_cpData.best.times[g_mapInfo.numCps-1]){
                    print("New PB!");
                    g_cpData.best.To(g_cpData.last);
                    g_cpData.last.wasPB = true;
                    g_cpData.current.To(g_cpData.best);
                    g_cpData.best.wasPB = true;

                    //special condition for speeds, if the best speeds are all zero, copy the current speeds into the current best
                    bool allZero = true;
                    for (uint i = 0; i < g_cpData.best.speeds.Length; i++){
                        if (g_cpData.best.speeds[i] != 0){
                            allZero = false;
                            break;
                        }
                    }
                    if (allZero){
                        for (uint i = 0; i < g_cpData.best.speeds.Length; i++){
                            g_cpData.best.speeds[i] = g_cpData.current.speeds[i];
                        }
                    }

                    g_cpData.last.To(g_cpData.current);

                    _timesPanel.UpdateAllRows();
                    SaveMapData();
                }
            } else {
                // print("Checkpoint! time: " + Time::Format(cpTime));
                _timesPanel.UpdateRow(cpIndex);
            }

        } else if (cpNum == lastCpNum && cpNum != 0) {
            int time = MLFeed::GameTime - startTime;
            int curLostTime = time - cpTime;
            if(!respawned) {
                respawnTimer = 0;
                respawned = true;
                // print("Respawn lost time: " + Time::Format(curLostTime+1000));
            } else { 
                // print("Double Respawn");
                respawned = false;
            } 
        }

        isDriving = true;
        lastCpNum = cpNum;
        lastResets = resets;
        lastStatus = status;
    }
    
}
//  0       1                2    3        4  
// {"#297", "fuckface", "0", "50655", "5887,9322,14538,18915,24225,29085,33618,36648,41207,45022,50655"}
// {"#287", "Personal best", "0", "27386", "6192,15168,27386" }
void OnGhostEvent(MwFastBuffer<wstring>data)
{   
    string name = data[1];
    auto finalTime = Text::ParseInt(data[3]);
    // print( "ghost name: " + name);
    if (name == "Personal best" || name == g_localPlayer)
    {
        // if it's the same final time, don't update
        if (g_cpData.best.times[g_cpData.best.times.Length -1] == finalTime) {
            // print("Same final time, not updating");
            return;
        }
        // if the time is greater than the current best, don't update
        if (g_cpData.best.times[g_cpData.best.times.Length -1] < finalTime
            && g_cpData.best.times[g_cpData.best.times.Length -1] != 0) {
            // print("Time is greater than current best, or, not updating");
            return;
        }

        //TODO: give an option to update it on demand instead of automatically
        // print("Updating best from ghost, speed and reset data is lost");

        array<string> cpTimeStrings = string(data[4]).Split(",");
        for (uint i = 0; i < uint(cpTimeStrings.Length); i++){
            g_cpData.best.times[i] = Text::ParseInt(cpTimeStrings[i]);
        }
        _timesPanel.UpdateAllRows();

        SaveMapData();

    } else {
        array<string> cpTimeStrings = string(data[4]).Split(",");
        for (uint i = 0; i < uint(cpTimeStrings.Length); i++){
            g_cpData.target.times[i] = Text::ParseInt(cpTimeStrings[i]);
        }
        g_cpData.target.playerName = name;
        _timesPanel.UpdateAllRows();
    }
}


void OnRaceTimesEvent(MwFastBuffer<wstring> data)
{
    auto name = data[0];
    if (name != g_target) return;
    // print("OnRaceTimesEvent");
    LogData(data);
}

void LogData(MwFastBuffer<wstring> data){
    string log = "{";
    for (uint i = 0; i < data.Length; i++){
        log += "'" + data[i] + "', ";
    }
    //remove the last ,
    log = log.SubStr(0, log.Length - 2);
    log += "}";
    // print(log);
}


void RenderMenu()
{
    // UI::MenuItem("test", "test", false, false)
    auto editor = g_app.Editor;
    auto label = "\\$2f9" + Icons::PuzzlePiece + "\\$fff Cp Times 2";
    // if (UI::MenuItem(label, "", !, @editor != null)) //
	// {
	// 	TimePanel_visible = !TimePanel_visible;
	// }

}

[SettingsTab name="Advanced Settings"]
void settings()
{
    if (!g_gameState.hasMap) return;

    // button to set the lats runs speeds as the best speeds
    if (UI::Button("Set Best Speeds to Last Run")){
        for (uint i = 0; i < g_cpData.best.speeds.Length; i++){
            g_cpData.best.speeds[i] = g_cpData.last.speeds[i];
        }
        _timesPanel.UpdateAllRows();
        SaveMapData();
    }
    // button to set current speeds
    if (UI::Button("Set Best Speeds to Current Run")){
        for (uint i = 0; i < g_cpData.best.speeds.Length; i++){
            g_cpData.best.speeds[i] = g_cpData.current.speeds[i];
        }
        _timesPanel.UpdateAllRows();
        SaveMapData();
    }

    // clear the current pb
    if (UI::Button("Clear Current PB")){
        g_cpData.best.ClearAll();
        _timesPanel.UpdateAllRows();
        SaveMapData();
    }


    // if(g_timesPanelColumns.Length>0){
    //     for (uint i = 0; i < g_timesPanelColumns.Length; i++){
    //         g_timesPanelColumns[i].enabled = UI::Checkbox(g_timesPanelColumns[i].name, g_timesPanelColumns[i].enabled);
    //     }
    // }
}

string GetJsonSavePath(const string &in path, CGameCtnChallenge@ map){
    return path + "\\" + ZUtil::GetTrimmedMapName(map) + "-" + g_gameState.map.MapInfo.MapUid + ".json";
}

void MapLoadEvent(CGameCtnChallenge@ challenge, CSmArena@ arena)
{
    string trimmedName = ZUtil::GetTrimmedMapName(challenge);
    string coloredName = challenge.MapInfo.NameForUi;

    g_mapInfo.numCps = ZUtil::GetEffectiveCpCount(challenge, arena);
    print("Map Load Event: " + ColoredString(coloredName + "$z") + " | numCps: " + g_mapInfo.numCps);
    g_mapInfo.name = trimmedName;
    g_mapInfo.coloredName = g_gameState.coloredMapName;
    g_mapInfo.author = challenge.MapInfo.AuthorNickName;
    _timesPanel.InitTableData(g_mapInfo.numCps);

    string path = GetJsonSavePath(g_saveFolderPath, challenge);

    if (!IO::FileExists(path)){
        path = GetJsonSavePath(g_oldSaveFolderPath, challenge);
        if (!IO::FileExists(path)){
            print("No save file found for this map");
            //clear out the data
            g_cpData.best.ClearAll();
            g_cpData.current.ClearAll();
            g_cpData.target.ClearAll();
            _timesPanel.UpdateAllRows();
            return;
        }
    }
    print("Loading cp data from save folder.");
    Json::Value mapRunData = Json::FromFile(path);
    // print("format Version: " + int(mapRunData["FormatVer"]));
    g_cpData.best.FromJsonObject(mapRunData["BestRun"], g_mapInfo.numCps);
    g_cpData.last.ClearAll();
    g_cpData.current.ClearAll();
    g_cpData.target.ClearAll();
    g_cpData.target.playerName = "";
    _timesPanel.UpdateAllRows();
}

void SaveMapData(){
    string path = GetJsonSavePath(g_saveFolderPath, g_gameState.map);
    print("Saving to: " + path);
    Json::Value mapRunData = Json::Object();
    mapRunData["FormatVer"] = 1;
    mapRunData["BestRun"] = g_cpData.best.ToJsonObject();
    Json::ToFile(path, mapRunData);
}

void PlayerLoadEvent(CSmPlayer@ player)
{
    string name = player.User.Name;
    // print("PlayerLoadEvent: " + name);
    g_target = name;
}

void OnDestroyed(){
    MLHook::UnregisterMLHookFromAll(g_raceEvents);
}

void Update(float dt)
{   
    if (respawned) {
        respawnTimer += dt;
        if (respawnTimer >= 1000) {
            respawned = false;
        }
    }
    g_dt = dt;
    _panelManager.Update(dt);
    g_gameState.Update(dt);
}

// void OnMouseButton(bool down, int button, int x, int y)
// {
//     print("OnMouseButton");
//     //print the location
//     print("x: " + x + " y: " + y);
// }


void Render()
{
    if (g_gameState.hasMap)
    {
        _panelManager.Render();
    }
}


void OnSettingsChanged(){
    _panelManager.OnSettingsChanged();

    // auto curFontSize = g_font.FontSize;
    // if (curFontSize != TimesPanel_fontSize){
    //     @g_font = UI::LoadFont("DroidSans-Bold.ttf", TimesPanel_fontSize, -1,-1, true, true, true);
    // }
}


void RenderInterface()
{
    //call panel manager to render all panels
    _panelManager.RenderInterface();
}

class MapInfo{
    string name;
    string coloredName;
    string author;
    int numCps;
}
