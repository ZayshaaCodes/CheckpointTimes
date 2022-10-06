class CpTimesHistoryPanel : ZUtil::UiPanel, ZUtil::IHandleGameStateEvents
{

    UI::Font@ g_font;
    CpTimesHistoryPanel(){
        super("Checkpoint Times Histor", HistoryPanel_position, HistoryPanel_size);
        @g_font = UI::LoadFont("DroidSans-Bold.ttf");
    }


    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){

    }

    void OnPlayerLoaded(CSmPlayer@ player){
        // print("OnPlayerLoaded");
    }


    void Render() override
    {
        if (!g_gameState.hasMap || !HistoryPanel_visible) return;

        if(GeneralSettings::HidePanelsWithInterface) {
            auto playground = GetApp().CurrentPlayground;
            if(playground is null || playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
            return;
            }
        }

        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,.75f));
        UI::PushStyleColor(UI::Col::FrameBg , vec4(0,0,0,0));
        // UI::SetNextWindowSize(int(m_size.x), int(m_size.y));
        UI::Begin("Previous Runs", HistoryPanel_visible);
                    //UI::WindowFlags::AlwaysAutoResize |
                    //UI::WindowFlags::NoCollapse);


        UI::PushFont(g_font);

        // UI::Text("\\$s" + g_gameState.coloredMapName);

        DrawRunHistoryTable();

        UI::PopFont();
        HistoryPanel_position = UI::GetWindowPos();
        HistoryPanel_size = UI::GetWindowSize();
        UI::End();
        UI::PopStyleColor();
        UI::PopStyleColor();
    }

    void DrawRunHistoryTable(){

        uint runCount = g_cpDataManager.m_runHistory.Length;

        UI::PushStyleColor(UI::Col::TableRowBg , vec4(0,1,0,.75f));
        
        if(UI::BeginTable("histTableHeader", runCount * 3 + 1, UI::TableFlags::SizingFixedFit))
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, 20);
            for (uint i = 0; i < runCount; i++)
            {
                string headerColor = ColorToHex(UI::HSV(float(i) / (runCount),.5f,1));
                UI::TableSetupColumn(headerColor + "\\$s" + i, UI::TableColumnFlags::WidthFixed, 20);
                UI::TableSetupColumn(headerColor + "\\$sTime", UI::TableColumnFlags::WidthFixed, 85);
                UI::TableSetupColumn(headerColor + "\\$sSplit", UI::TableColumnFlags::WidthFixed, 85);
            }
            UI::TableHeadersRow();

            UI::EndTable();
        }

        UI::BeginChild("cpHistTimesList");
        if(UI::BeginTable("histTable", runCount * 3 + 1, UI::TableFlags::SizingFixedFit))
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, 20);
            for (uint i = 0; i < runCount; i++)
            {
                string headerColor = ColorToHex(UI::HSV(float(i) / (runCount),.5f,1));
                UI::TableSetupColumn(headerColor + "" + i, UI::TableColumnFlags::WidthFixed, 20);
                UI::TableSetupColumn(headerColor + "", UI::TableColumnFlags::WidthFixed, 85);
                UI::TableSetupColumn(headerColor + "", UI::TableColumnFlags::WidthFixed, 85);
            }

                UI::TableNextColumn();
            string color;
            for (uint i = 0; i < g_cpDataManager.mapCpCount; i++)
            {
                DrawCpNumber(i);
                UI::TableNextColumn();

                for (uint ri = 0; ri < runCount; ri++)
                {
                    auto run = g_cpDataManager.m_runHistory[ri];
                    int cpTime = run.times[i];
                    bool hasTime = cpTime != 0;

                    // Resets Text
                    UI::Text("\\$s" + (hasTime ? color_Light + run.resets[i] : ""));
                    UI::TableNextColumn(); 

                    // Time Text
                    UI::Text( "\\$s" + (hasTime ? color_Light + Time::Format(cpTime) : ""));
                    UI::TableNextColumn();

                    // Split Time Text
                    int split =  g_cpDataManager.bestRun.times[i] - run.times[i];
                    string sColor;
                    if (split > 0) {
                        sColor = color_LightPos;
                    } else if (split < 0){
                        sColor = color_LightNeg;
                    } else{
                        sColor = color_Dark;
                    }
                    UI::Text("\\$s" + (hasTime ? sColor + Time::Format( Math::Abs(split)) : ""));
                    UI::TableNextColumn();

                    // UI::SetNextItemWidth(500);
                    // UI::PushID("time" + i);
                    // auto res = UI::InputText("", Time::Format(run.times[i]));
                    // UI::PopID();

                    // Split Time Text

                }
            }

            UI::EndTable();
        }
        UI::EndChild();
        UI::PopStyleColor();

    }

    void DrawCpNumber(uint i){
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
    }
}