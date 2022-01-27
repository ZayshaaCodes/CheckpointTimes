
namespace GeneralSettings{
    [Setting category="General" name="Save History Count" drag min=1 max=10]
    int historyCount = 3;

    [Setting category="General" name="Hide Panels With Interface"]
    bool HidePanelsWithInterface = true;
    [Setting category="General" name="Hide HUD With Interface"]
    bool HideHudWithInterface = false;
}

[Setting category="Cp Times Panel" name="Time Panel Visible"]
bool TimePanel_visible = true;

[Setting category="Cp Times Panel" name="Time Panel Position"]
vec2 TimePanel_position = vec2(1,400);

[Setting category="Cp Times Panel" name="Time Panel Font Size" drag min=10 max=50]
float TimePanel_fontSize = 20;
[Setting category="Cp Times Panel" name="Time Panel Max Lines" drag min=2 max=25]
int TimePanel_maxLines = 8;
[Setting category="Cp Times Panel" name="Time Panel BG Color" color]
vec4 TimePanel_bgColor = vec4(0,0,0,.5f);

[Setting category="History Panel" name="Hist Panel Visible"]
bool HistoryPanel_visible = true;
[Setting category="History Panel" name="Hist Panel Position"]
vec2 HistoryPanel_position = vec2(1,400);    
[Setting category="History Panel" name="Hist Panel Size"]
vec2 HistoryPanel_size = vec2(500,250);    

[Setting category="Last Split HUD" name="Split Hud Visible"]
bool SplitHud_visible = true;
[Setting category="Last Split HUD" name="Split Hud Move Hud"]
bool SplitHud_move = false;
[Setting category="Last Split HUD" name="Split Hud Position"]
vec2 SplitHud_position = vec2(.7f,1);
[Setting category="Last Split HUD" name="Split Hud Size"]
vec2 SplitHud_size = vec2(300,50);

[Setting category="Last Split HUD" name="Split Hud Font Size" drag min=10 max=100]
float SplitHud_fontSize = 40;

[Setting category="Last Split HUD" name="Split Hud TextShadow"]
bool SplitHud_shadow = true;
[Setting category="Last Split HUD" name="Split Hud Shadow Offset" drag min=0 max=5]
float SplitHud_shadowOffset = 2;