// [Setting]
// float g_fontSize = 20;


class CpTimesPanel : ZUtil::UiPanel
{
    bool doScroll = false;
    Resources::Font@ g_font;

    CpTimesPanel()
    {
        super("Checkpoint Times", CPTimesPanelPosition, vec2(380,100));

        @g_font = Resources::GetFont("DroidSans-Bold.ttf",20);
        m_moveHud = true;
    }
    
    // void OnSettingsChanged() override 
    // {

    // }

    // void Update(float dt) override 
    // {
        
    // }

    void Render() override 
    { 
        if(!g_gameState.hasMap) return;

        // g_cpDataManager
        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,.4f));
        UI::SetNextWindowPos(int(m_pos.x), int(m_pos.y));
        UI::SetNextWindowSize(int(m_size.x), Math::Min(g_cpDataManager.mapCpCount, 8) * 29
         + 35 + 25);
        UI::Begin("CP Times", UI::WindowFlags::NoTitleBar 
                    | UI::WindowFlags::NoCollapse 
                    | UI::WindowFlags::NoDocking);
                    

        UI::PushFont(g_font);

        int currentCp = g_cpDataManager.currentCp;

        UI::Text("\\$s" + g_gameState.coloredMapName + " | " +  currentCp + "/" + g_cpDataManager.mapCpCount);
        
        UI::BeginChild("cpTimesList");
        if(UI::BeginTable("table", 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, 20);
            UI::TableSetupColumn("\\$sR", UI::TableColumnFlags::WidthFixed, 20);
            UI::TableSetupColumn("\\$sTime", UI::TableColumnFlags::WidthFixed, 80);
            UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, 85);
            UI::TableSetupColumn("\\$sBest", UI::TableColumnFlags::WidthFixed, 85);
            UI::TableHeadersRow();

            string color;

            auto currentRun = g_cpDataManager.currentRun;

            for (uint i = 0; i < g_cpDataManager.mapCpCount; i++)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                // CP text
                if (g_gameState.isRoyalMap)
                {
                    string letter = "";
                    if (i == 0) letter = "\\$s\\$fffW";
                    else if (i == 1) letter = "\\$s\\$0f0G";
                    else if (i == 2) letter = "\\$s\\$55fB";
                    else if (i == 3) letter = "\\$s\\$f00R";
                    else if (i == 4) letter = "\\$s\\$888B";
                    UI::Text( letter ); UI::NextColumn();
                } else {
                    UI::Text( "\\$s" + (i == g_cpDataManager.mapCpCount - 1 ? "F" : tostring(i + 1)) ); 
                }
                UI::TableNextColumn();

                // Current Resets Text
                int displayReset = 0;
                if(int(i) < currentCp) {
                    color = color_Light;
                    displayReset =  g_cpDataManager.currentRun.resets[i];
                }
                else if(int(i) >= currentCp) {
                    color = color_Dark;
                    displayReset = 0;
                } 
                // else { 
                //     string h = FloatToHex(fade);
                //     color = "\\$" + h + "f" + h;
                //     displayReset = g_cpDataManager.currentRun.resets[i];                    
                // }

                UI::Text("\\$s" + color + displayReset);
                UI::TableNextColumn();

                // Current/Last Time Text
                int displayTime = 0;
                if(int(i) < currentCp) {
                    color = color_Light;
                    displayTime = currentRun.times[i];
                    
                } else if(int(i) >= currentCp) {
                    color = color_Dark;
                    // displayTime = lastTimes[i];
                    displayTime = 0;
                } 
                // else {
                //     string h = FloatToHex(fade);
                //     color = "\\$" + h + "f" + h;
                //     displayTime = curTimes[i];
                // }
                UI::Text( "\\$s" + color + (displayTime == 0 ? "" : Time::Format( displayTime )));
                UI::TableNextColumn();
                
                // Split Time Text

                int pos = currentRun.position;

                bool pastCur = int(i) >= currentCp;

                int split = pastCur ? 0 : g_cpDataManager.bestRun.times[i] - g_cpDataManager.currentRun.times[i];
                if (pastCur) split = 0;

                string sColor;
                if (split > 0) {
                    sColor = pastCur ? color_DarkPos : color_LightPos;
                } else if (split < 0){
                    sColor = pastCur ? color_DarkNeg : color_LightNeg;
                } else{
                    sColor = color_Dark;
                }                
                UI::Text("\\$s" + sColor + Time::Format( Math::Abs(split)) ); 
                UI::TableNextColumn();

                // Best Time Text
                int bestTime = g_cpDataManager.bestRun.times[i];
                UI::Text("\\$s" + (bestTime == 0 ? "" : g_cpDataManager.bestRun.resets[i] + " - " + Time::Format(bestTime)));
                UI::TableNextColumn();
            }

            // if (doScroll)
            // {
            //     float max = UI::GetScrollMaxY();
            //     auto dist = Math::Max(currentCp - 3,0) / Math::Max(float( curTimes.Length  - 5),1.0f) * max;
            //     UI::SetScrollY(dist);
            //     doScroll = false;
            // }

        UI::EndTable();
        }
        UI::EndChild();

        UI::PopFont();

        CPTimesPanelPosition = UI::GetWindowPos();

        UI::End();
        UI::PopStyleColor();

    }

    
}
