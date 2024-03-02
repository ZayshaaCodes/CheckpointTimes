
// namespace GeneralSettings{
//     [Setting category="General" name="Save History Count" drag min=1 max=10]
//     int historyCount = 3;

[Setting category="General" name="Hide Panels With Interface"]
bool HidePanelsWithInterface = true;
[Setting category="General" name="Hide HUD With Interface"]
bool HideHudWithInterface = false;

[Setting category="Cp Times Panel" name="Time Panel Visible"]
bool TimePanel_visible = true;
[Setting category="Cp Times Panel" name="Show Author Name"]
bool TimesPanel_showAuthor = true;
[Setting category="Cp Times Panel" name="Show Scrollbar"]
bool TimesPanel_showScrollbar = true;
[Setting category="Cp Times Panel" name="Default Position"]
vec2 TimesPanel_position = vec2(800, 600);
[Setting category="Cp Times Panel" name="Default Size"]
vec2 TimesPanel_size = vec2(500, 250);
[Setting category="Cp Times Panel" name="Font Size" drag min=10 max=100]
float TimesPanel_fontSize = 17;

[Setting category="Cp Times Panel" name="Cp Number" hidden]
bool g_timesPanelColumnCpNumberEnabled = true;
[Setting category="Cp Times Panel" name="Time" hidden]
bool g_timesPanelColumnTimeEnabled = true;
[Setting category="Cp Times Panel" name="Speed" hidden]
bool g_timesPanelColumnSpeedEnabled = false;
[Setting category="Cp Times Panel" name="PB Split" hidden]
bool g_timesPanelColumnPbSplitEnabled = true;
[Setting category="Cp Times Panel" name="PB Split Speed" hidden]
bool g_timesPanelColumnPbSplitSpeedEnabled = true;
[Setting category="Cp Times Panel" name="PB Speed" hidden]
bool g_timesPanelColumnPbSpeedEnabled = true;
[Setting category="Cp Times Panel" name="PB Time" hidden]
bool g_timesPanelColumnPbTimeEnabled = true;
[Setting category="Cp Times Panel" name="Target Split" hidden]
bool g_timesPanelColumnTargetSplitEnabled = true;
[Setting category="Cp Times Panel" name="Target Time" hidden]
bool g_timesPanelColumnTargetTimeEnabled = true;

[Setting category="CP Times HUD" name="Position"]
vec2 SplitHud_position = vec2(.5, 1.001);
[Setting category="CP Times HUD" name="Size"]
vec2 SplitHud_size = vec2(300, 32);
[Setting category="CP Times HUD" name="Font Size" drag min=10 max=100]
float SplitHud_fontSize = 26;
[Setting category="CP Times HUD" name="Good Color" color]
vec4 SplitHud_goodColor = vec4(0,0.8f,0,0.7f);
[Setting category="CP Times HUD" name="Bad Color" color]
vec4 SplitHud_badColor = vec4(0.8f,0,0,0.7f);
[Setting category="CP Times HUD" name="Neutral Color" color]
vec4 SplitHud_neutralColor = vec4(0,0,0,.5f);

[Setting category="CP Times HUD" name="Move HUD"]
bool SplitHud_move = false;
[Setting category="CP Times HUD" name="Visible"]
bool SplitHud_visible = true;