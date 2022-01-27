CTrackMania@ g_app;
string g_saveFolderPath;
bool g_debugging = true; 

array<ZUtil::PluginPanel@> _panels(0);

CpDataManager@ g_cpDataManager;
CpEventManager@ g_cpEventManager;
ZUtil::GameState@ g_gameState;

CpTimesPanel@ cpTimesPanel;
CpSplitHud@ cpSplitHud;
CpTimesHistoryPanel@ cpHistoryPanel;

string color_Dark = "\\$333";
string color_Light = "\\$FFF";

string color_DarkPos = "\\$272-";
string color_DarkNeg = "\\$722+";

string color_LightPos = "\\$2D2-";
string color_LightNeg = "\\$D22+";

float g_dt;

Dev::HookInfo@ hook;

bool popup = true;

void RenderMenu()
{
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Cp Times", selected: TimePanel_visible, enabled: GetApp().Editor !is null))
	{
		TimePanel_visible = !TimePanel_visible;
	}
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff Cp Times History", selected: HistoryPanel_visible, enabled: GetApp().Editor !is null))
	{
		HistoryPanel_visible = !HistoryPanel_visible;
	}
}

[Setting category="Advanced Settings"]
void RenderSettings(){
    // AdvSettings::Render(speeder);
    if (g_gameState.hasMap)
    {
        if (UI::Button("Clear Current Map Data")){
            g_cpDataManager.ClearMapData();
        }
    }

}

void Main(){
    @g_app = cast<CTrackMania>(GetApp());

    g_saveFolderPath = IO::FromDataFolder("CheckpointTimes");
    
    if(!IO::FolderExists(g_saveFolderPath)) IO::CreateFolder(g_saveFolderPath);

    @cpTimesPanel = CpTimesPanel();
    @cpSplitHud = CpSplitHud();
    @cpHistoryPanel = CpTimesHistoryPanel();

    @g_cpDataManager = CpDataManager();
    @g_cpEventManager = CpEventManager();

    @g_gameState = ZUtil::GameState();

    g_cpEventManager.RegisterCallbacks(g_cpDataManager);    
    g_cpEventManager.RegisterCallbacks(cpSplitHud);    
    g_gameState.RegisterLoadCallbacks(g_cpDataManager);
    g_gameState.RegisterLoadCallbacks(cpSplitHud);

    _panels.InsertLast(cpTimesPanel);
    _panels.InsertLast(cpSplitHud);
    _panels.InsertLast(cpHistoryPanel);
    
    // if (g_debugging)
    // {
    //     auto DebugUiPanel = DebuggingUiPanel();
    //     _panels.InsertLast(DebugUiPanel);
    // }

    print("Cp Times Initialized!");
}

void Test(uint r12){
    print("test" + r12);
}

void OnDestroyed(){
    print("OnDestroyed");
    if (hook !is null)
    {
        Dev::Unhook(hook);
    }
}

void Update(float dt)
{
    g_dt = dt;
    g_gameState.Update(dt);
    g_cpEventManager.Update(g_gameState.player);

    for (uint i = 0; i < _panels.Length; i++) _panels[i].Update(dt);
}

void Render()
{
    //g_cpDataManager.Render(g_gameState.player);
    for (uint i = 0; i < _panels.Length; i++) _panels[i].InternalRender();
}


void OnSettingsChanged(){
    for (uint i = 0; i < _panels.Length; i++) _panels[i].OnSettingsChanged();
}


void RenderInterface()
{
    for (uint i = 0; i < _panels.Length; i++) _panels[i].RenderInterface();
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
