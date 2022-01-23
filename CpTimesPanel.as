// [Setting]
// float g_fontSize = 20;


class CpTimesPanel : ZUtil::UiPanel
{
    bool doScroll = false;
    Resources::Font@ g_font;
    bool resizeWindow = false;

    CpTimesPanel()
    {
        super("Checkpoint Times", TimePanel_position   , vec2(TimePanel_fontSize*19,100));

        @g_font = Resources::GetFont("DroidSans-Bold.ttf",TimePanel_fontSize);
        m_moveHud = true;
        m_size.x = TimePanel_fontSize * 19; 
    }
    
    void OnSettingsChanged() override 
    {
        @g_font = Resources::GetFont("DroidSans-Bold.ttf",TimePanel_fontSize);
        m_size.x = TimePanel_fontSize * 19;
        m_size.y = GetWindowHeight();
        resizeWindow = true;
    }

    // void Update(float dt) override 
    // {
        
    // }

    float GetWindowHeight(){
        return Math::Min(g_cpDataManager.mapCpCount, TimePanel_maxLines) * (TimePanel_fontSize + 9)
         + 2 * TimePanel_fontSize + 22;
    }

    void Render() override 
    { 
        if(!g_gameState.hasMap || !TimePanel_visible) return;

        if(GeneralSettings::HidePanelsWithInterface) {
            auto playground = GetApp().CurrentPlayground;
            if(playground is null || playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
            return;
            }
        }

        float fSize = TimePanel_fontSize;

        // g_cpDataManager
        UI::PushStyleColor(UI::Col::WindowBg, TimePanel_bgColor);
        // UI::SetNextWindowPos(int(TimePanel_position.x), int(TimePanel_position.y));
        UI::SetNextWindowSize(int(m_size.x), int(GetWindowHeight()));
        UI::Begin("CP Times", UI::WindowFlags::NoTitleBar 
                    | UI::WindowFlags::NoCollapse 
                    | UI::WindowFlags::NoDocking);

        if (resizeWindow)
        {
            UI::SetWindowSize(m_size);
            resizeWindow = false;
        }                    

        UI::PushFont(g_font);

        int currentCp = g_cpDataManager.currentCp;

        UI::PushStyleColor(UI::Col::Button, vec4(0,0,0,.25f));
        UI::Text("\\$s" + g_gameState.coloredMapName);// + " | " +  currentCp + "/" + g_cpDataManager.mapCpCount);
        UI::SameLine();
        UI::Dummy(vec2(5, fSize));
        UI::SameLine();
        auto cursorPos = UI::GetCursorPos();
        if (UI::Button("", vec2(m_size.x-cursorPos.x - fSize * .75f, fSize))){
            HistoryPanel_visible = !HistoryPanel_visible;
        }
        
        UI::PopStyleColor();
        
        if(UI::BeginTable("tableHeaders", 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, fSize);
            UI::TableSetupColumn("\\$sR", UI::TableColumnFlags::WidthFixed, fSize);
            UI::TableSetupColumn("\\$sTime", UI::TableColumnFlags::WidthFixed, fSize*4);
            UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, fSize* 4.5f);
            UI::TableSetupColumn("\\$sBest", UI::TableColumnFlags::WidthFixed, fSize * 5.5f);
            UI::TableHeadersRow();
            UI::EndTable();
        }

        UI::BeginChild("cpTimesList");
        if(UI::BeginTable("table", 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("", UI::TableColumnFlags::DefaultHide , fSize);
            UI::TableSetupColumn("", UI::TableColumnFlags::DefaultHide , fSize);
            UI::TableSetupColumn("", UI::TableColumnFlags::DefaultHide , fSize*4);
            UI::TableSetupColumn("", UI::TableColumnFlags::DefaultHide , fSize* 4.5f);
            UI::TableSetupColumn("", UI::TableColumnFlags::DefaultHide , fSize * 5.5f);
            // UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, fSize);
            // UI::TableSetupColumn("\\$sR", UI::TableColumnFlags::WidthFixed, fSize);
            // UI::TableSetupColumn("\\$sTime", UI::TableColumnFlags::WidthFixed, fSize*4);
            // UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, fSize* 4.5f);
            // UI::TableSetupColumn("\\$sBest", UI::TableColumnFlags::WidthFixed, fSize * 5.5f);
            // UI::TableHeadersRow();

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
                    displayReset = g_cpDataManager.m_runHistory[0].resets[i];
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
                    displayTime = g_cpDataManager.m_runHistory[0].times[i];
                    //displayTime = 0;
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

                int activeTime =  (pastCur ? g_cpDataManager.m_runHistory[0].times[i] : g_cpDataManager.currentRun.times[i]);

                int split = 0;
                if (activeTime != 0)
                    split = g_cpDataManager.bestRun.times[i] - activeTime;


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

            if (doScroll)
            {
                float max = UI::GetScrollMaxY();
                auto dist = Math::Max(currentRun.position - 3,0) / Math::Max(float(g_cpDataManager.mapCpCount - 5),1.0f) * max;
                UI::SetScrollY(dist);
                doScroll = false;
            }

            UI::EndTable();
        }
        UI::EndChild();
        UI::PopFont();

        TimePanel_position = UI::GetWindowPos();
        m_size = UI::GetWindowSize();

        UI::End();
        UI::PopStyleColor();

    }

    
}
