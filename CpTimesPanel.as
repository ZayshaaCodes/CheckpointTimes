class CpTimesPanel : ZUtil::UiPanel
{
    bool doScroll = false;
    UI::Font@ g_font;
    bool resizeWindow = false;

    CpTimesPanel()
    {
        super("Checkpoint Times", TimePanel_position   , vec2(TimePanel_fontSize*(TimePanel_showSpeeds ? 24 : 19),100));

        @g_font = UI::LoadFont("DroidSans-Bold.ttf", TimePanel_fontSize);
        m_moveHud = true;
        m_size.x = TimePanel_fontSize * (TimePanel_showSpeeds ? 24 : 19); 
    }
    
    void OnSettingsChanged() override 
    {
        @g_font = UI::LoadFont("DroidSans-Bold.ttf", TimePanel_fontSize);
        m_size.x = TimePanel_fontSize * (TimePanel_showSpeeds ? 24 : 19);
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
        UI::Text("\\$s" + g_gameState.coloredMapName + " \\$fff| " + currentCp);// + " | " +  currentCp + "/" + g_cpDataManager.mapCpCount);
        UI::SameLine();
        UI::Dummy(vec2(5, fSize));
        UI::SameLine();
        auto cursorPos = UI::GetCursorPos();
        if (UI::Button("", vec2(m_size.x-cursorPos.x - fSize * .75f, fSize))){
            HistoryPanel_visible = !HistoryPanel_visible;
        }

        UI::PopStyleColor();
        
        if(UI::BeginTable("tableHeaders", TimePanel_showSpeeds ? 6 : 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("\\$s#",    UI::TableColumnFlags::WidthFixed, fSize);
            UI::TableSetupColumn("\\$sR",     UI::TableColumnFlags::WidthFixed, fSize);
            if(TimePanel_showSpeeds)
                UI::TableSetupColumn("\\$sSpeed",  UI::TableColumnFlags::WidthFixed, fSize * 2.5f);
            UI::TableSetupColumn("\\$sTime",  UI::TableColumnFlags::WidthFixed, fSize * 4);
            UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, fSize * 4.5f);
            UI::TableSetupColumn("\\$sBest",  UI::TableColumnFlags::WidthFixed, fSize * (TimePanel_showSpeeds ? 7.5f : 5.5f));
            UI::TableHeadersRow();
            UI::EndTable();
        }

        UI::BeginChild("cpTimesList");
        if(UI::BeginTable("table", TimePanel_showSpeeds ? 6 : 5, UI::TableFlags::SizingFixedFit)) 
        {
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, fSize);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, fSize);
            if(TimePanel_showSpeeds)
                UI::TableSetupColumn("",  UI::TableColumnFlags::WidthFixed, fSize * 2.5f);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, fSize * 4);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, fSize * 4.5f);
            UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, fSize * (TimePanel_showSpeeds ? 7.5f : 5.5f));

            string color;

            auto currentRun = g_cpDataManager.currentRun;

            // print(g_cpDataManager.mapCpCount + " | " + g_cpDataManager.currentRun.times.Length + " | " + g_cpDataManager.currentRun.resets.Length);

            for (uint i = 0; i < g_cpDataManager.mapCpCount; i++)
            {
                UI::TableNextRow();
                UI::TableNextColumn();

                UI::PushFont(g_font);
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

                
                int displayReset = 0;
                if (g_gameState.isRoyalMap){
                    int time = g_cpDataManager.currentRun.times[i];
                    if(time != 0) {
                        color = color_Light;
                    } else {
                        color = color_Dark;
                    }
                } else {
                    // Current Resets Text
                    if(int(i) < currentCp) {
                        color = color_Light;
                        displayReset =  g_cpDataManager.currentRun.resets[i];
                    }
                    else if(int(i) >= currentCp) {
                        color = color_Dark;
                        displayReset = g_cpDataManager.m_runHistory[0].resets[i];
                    } 
                }
               
                UI::Text("\\$s" + color + displayReset);
                UI::TableNextColumn();
                color = color_Light;
                
                int curTime = currentRun.times[i];
                // --------- Current/Last Time Text
                int displayTime = 0;
                int lastTime = g_cpDataManager.m_runHistory[0].times[i];

                if(int(i) < currentCp || (g_gameState.isRoyalMap && curTime != 0)) {
                    color = color_Light;
                    displayTime = curTime;
                    
                } else if(int(i) >= currentCp) {
                    color = color_Dark;
                    displayTime = lastTime;
                } 

                if(TimePanel_showSpeeds)
                {                    
                    int displaySpeed = 0;
                    string speedColor = color_Light;
                    if(int(i) < currentCp || (g_gameState.isRoyalMap && curTime != 0)) {
                        displaySpeed = int(Math::Round(g_cpDataManager.currentRun.speeds[i] - g_cpDataManager.bestRun.speeds[i]));
                        speedColor = displaySpeed > 0 ? color_LightPosNs : (displaySpeed < 0 ? color_LightNegNs : color_Light);
                        
                    } else if(int(i) >= currentCp) {
                        displaySpeed = int(Math::Round(g_cpDataManager.m_runHistory[0].speeds[i] - g_cpDataManager.bestRun.speeds[i]));
                        speedColor = displaySpeed > 0 ? color_DarkPosNs : (displaySpeed < 0 ? color_DarkNegNs  : color_Dark);
                    } 
                    UI::Text("\\$s" + speedColor + displaySpeed);
                    UI::TableNextColumn();
                }

                UI::Text( "\\$s" + (displayTime == 0 ? "" : color + Time::Format( displayTime )));
                UI::TableNextColumn();
                
                // -------Split Time Text
                int split = 0;
                string sColor;
                bool splitActive = false;
                
                //if it's a normal map, if the current cp count is greater than the currently drawing index
                // show the split between the current run and the best run
                // otherwise show the split between best run and the last run in the history;
                if (!g_gameState.isRoyalMap){
                    bool pastCur = int(i) >= currentCp;
                    int activeTime =  (pastCur ? g_cpDataManager.m_runHistory[0].times[i] : g_cpDataManager.currentRun.times[i]);
                    splitActive = !pastCur;
                    if (activeTime != 0)
                        split = g_cpDataManager.bestRun.times[i] - activeTime;
                } else {// if it's a royal map, show a split if there's a current time and a beset time for this cp
                    if (g_cpDataManager.currentRun.times[i] != 0 && g_cpDataManager.bestRun.times[i] != 0)
                    {
                        split = g_cpDataManager.bestRun.times[i] - g_cpDataManager.currentRun.times[i];
                        splitActive = true;
                    }
                }

                if (split > 0)
                    sColor = splitActive ? color_LightPos : color_DarkPos;
                else if (split < 0)
                    sColor = splitActive ? color_LightNeg : color_DarkNeg;
                 else
                    sColor = color_Dark;

                UI::Text("\\$s" + sColor + Time::Format( Math::Abs(split))); 
                UI::TableNextColumn();
                
                UI::PopFont();

                // Best Time Text
            int bestTime = g_cpDataManager.bestRun.times[i];
                string speedText = "";
                if(TimePanel_showSpeeds){
                    speedText = "\\$333 | \\$FFF" + int(g_cpDataManager.bestRun.speeds[i]);
                }
                if (!g_gameState.isRoyalMap)
                {
                    auto resetCount = g_cpDataManager.bestRun.resets[i];
                    color = "\\$F80";
                    color = resetCount > 1 ? "\\$F00" : color;
                    string resetText = (resetCount > 0) ? (color + resetCount + "\\$FFF") : "" + resetCount;
                    UI::Text("\\$s" + (bestTime == 0 ? "" : resetText + "\\$333 | \\$FFF" + Time::Format(bestTime) + speedText));
                } else {
                    UI::Text("\\$s" + (bestTime == 0 ? "" : Time::Format(bestTime) + speedText));
                }
                
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
