CTrackMania@ g_app;
string g_saveFolderPath;
bool g_debugging = true;

array<ZUtil::PluginPanel@> _panels(0);

ZUtil::CpDataManager@ g_cpDataManager;
ZUtil::GameState@ g_gameState;

CpTimesPanel@ cpTimesPanel;

string color_DarkPos = "\\$272+";
string color_LightPos = "\\$0D0+";
string color_Dark = "\\$444";
string color_Light = "\\$FFF";
string color_DarkNeg = "\\$722-";
string color_LightNeg = "\\$D00-";

float g_dt;

void Main(){
    @g_app = cast<CTrackMania>(GetApp());

    g_saveFolderPath = IO::FromDataFolder("CheckpointTimes");
    
    if(!IO::FolderExists(g_saveFolderPath)) IO::CreateFolder(g_saveFolderPath);

    @cpTimesPanel = CpTimesPanel();

    @g_cpDataManager = ZUtil::CpDataManager();
    @g_gameState = ZUtil::GameState();

    g_cpDataManager.RegisterCallbacks(cpTimesPanel);
    g_gameState.RegisterLoadCallbacks(cpTimesPanel);

    _panels.InsertLast(cpTimesPanel);
    
    // auto DebugUiPanel = DebuggingUiPanel();
    // g_cpDataManager.RegisterCallbacks(DebugUiPanel);
    // _panels.InsertLast(DebugUiPanel);

    print("Cp Times Initialized!");
}

void Update(float dt)
{
    g_dt = dt;
    g_gameState.Update(dt);
    g_cpDataManager.Update(g_gameState.player);

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

