

CTrackMania@ g_app;
string g_saveFolderPath;
bool g_debugging = true;

array<ZUtil::PluginPanel@> _panels(0);

ZUtil::CpEventManager@ g_cpEventManager;
ZUtil::CpDataManager@ g_cpDataManager;
ZUtil::GameState@ g_gameState;

CpTimesPanel@ cpTimesPanel;
CpTimesHistoryPanel@ cpTimesHistoryPanel;

string color_DarkPos = "\\$272-";
string color_LightPos = "\\$0D0-";
string color_Dark = "\\$444";
string color_Light = "\\$FFF";
string color_DarkNeg = "\\$722+";
string color_LightNeg = "\\$D00+";

float g_dt;

bool popup = true;

void RenderMenu()
{
if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Cp Times History", selected: historyWindowVisible, enabled: GetApp().Editor !is null))
	{
		historyWindowVisible = !historyWindowVisible;
	}
}

void Main(){
    @g_app = cast<CTrackMania>(GetApp());

    g_saveFolderPath = IO::FromDataFolder("CheckpointTimes2");
    
    if(!IO::FolderExists(g_saveFolderPath)) IO::CreateFolder(g_saveFolderPath);

    @cpTimesPanel = CpTimesPanel();
    @cpTimesHistoryPanel = CpTimesHistoryPanel();

    @g_cpEventManager = ZUtil::CpEventManager();
    @g_cpDataManager = CpDataManager();
    @g_gameState = ZUtil::GameState();

    g_cpEventManager.RegisterCallbacks(g_cpDataManager);
    g_gameState.RegisterLoadCallbacks(g_cpDataManager);

    // g_gameState.RegisterLoadCallbacks(cpTimesPanel);
    // g_gameState.RegisterLoadCallbacks(cpTimesHistoryPanel);

    _panels.InsertLast(cpTimesPanel);
    _panels.InsertLast(cpTimesHistoryPanel);
    
    // if (g_debugging)
    // {
    //     auto DebugUiPanel = DebuggingUiPanel();
    //     _panels.InsertLast(DebugUiPanel);
    // }

    print("Cp Times Initialized!");

}

void OnDestroyed(){
  
}

void Update(float dt)
{
    g_dt = dt;
    g_gameState.Update(dt);
    g_cpEventManager.Update(g_gameState.player);

    for (uint i = 0; i < _panels.Length; i++) 
        _panels[i].Update(dt);
}

void Render()
{
    //g_cpEventManager.Render(g_gameState.player);
    for (uint i = 0; i < _panels.Length; i++) 
        _panels[i].InternalRender();
}


void OnSettingsChanged(){
    for (uint i = 0; i < _panels.Length; i++) 
        _panels[i].OnSettingsChanged();

    g_cpDataManager.OnSettingsChanged();
}


void RenderInterface()
{
    for (uint i = 0; i < _panels.Length; i++) 
        _panels[i].RenderInterface();
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

string ColorToHex(vec4 color){
    return "\\$" + FloatToHex(color.x) + FloatToHex(color.y) + FloatToHex(color.z);
}

//Todo: improve this...
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

