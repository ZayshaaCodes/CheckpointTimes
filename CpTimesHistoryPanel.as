class CpTimesHistoryPanel : ZUtil::UiPanel, ZUtil::IHandleGameStateEvents
{

    Resources::Font@ g_font;
    CpTimesHistoryPanel(){
        super("Checkpoint Times Histor", CPTimesHistoryPanelPosition, vec2(600,650));
        @g_font = Resources::GetFont("DroidSans-Bold.ttf",20);
    }


    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){

    }

    void OnPlayerLoaded(CSmPlayer@ player){
        // print("OnPlayerLoaded");
    }


    void Render() override
    {
        if (!historyWindowVisible) return;
        if(!g_gameState.hasMap) return;
        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,.75f));
        UI::PushStyleColor(UI::Col::FrameBg , vec4(0,0,0,0));
        UI::SetNextWindowPos(int(m_pos.x), int(m_pos.y));
        UI::SetNextWindowSize(int(m_size.x), int(m_size.y));
        UI::Begin("Previous Runs", historyWindowVisible,
                    UI::WindowFlags::AlwaysAutoResize
                    | UI::WindowFlags::NoCollapse);


        UI::PushFont(g_font);

        // UI::Text("\\$s" + g_gameState.coloredMapName);

        DrawRunHistoryTable();

        UI::PopFont();
        CPTimesHistoryPanelPosition = UI::GetWindowPos();
        UI::End();
        UI::PopStyleColor();
        UI::PopStyleColor();
    }

    void DrawRunHistoryTable(){

        int runCount = g_cpDataManager.LastRunsData.Length;

        UI::PushStyleColor(UI::Col::TableRowBg , vec4(0,1,0,.75f));
        if(UI::BeginTable("histTable", runCount * 2 + 1, UI::TableFlags::SizingFixedFit))
        {
            UI::TableSetupColumn("\\$sCP", UI::TableColumnFlags::WidthFixed, 20);
            for (uint i = 0; i < runCount; i++)
            {
                string headerColor = ColorToHex(UI::HSV(float(i) / (runCount),1,1));
                UI::TableSetupColumn(headerColor + "\\$s" + i, UI::TableColumnFlags::WidthFixed, 20);
                UI::TableSetupColumn(headerColor + "\\$sTime", UI::TableColumnFlags::WidthFixed, 100);
                // UI::TableSetupColumn("\\$sSplit", UI::TableColumnFlags::WidthFixed, 85);
            }

            // UI::TableSetupColumn("\\$sBest", UI::TableColumnFlags::WidthFixed, 85);
            UI::TableHeadersRow();
            UI::TableNextColumn();

            string color;
            for (uint i = 0; i < g_cpDataManager.mapCpCount; i++)
            {
                DrawCpNumber(i);
                UI::TableNextColumn();

                for (uint ri = 0; ri < runCount; ri++)
                {
                    auto run = g_cpDataManager.LastRunsData[ri];
                    int cpTime = run.times[i];
                    bool hasTime = cpTime != 0;

                    // CP Number text

                    // Resets Text
                    UI::Text("\\$s" + (hasTime ? color_Light + run.resets[i] : ""));
                    UI::TableNextColumn();

                    // Time Text
                    UI::Text( "\\$s" + (hasTime ? color_Light + Time::Format(cpTime) : ""));
                    UI::TableNextColumn();

                    // UI::SetNextItemWidth(500);
                    // UI::PushID("time" + i);
                    // auto res = UI::InputText("", Time::Format(run.times[i]));
                    // UI::PopID();

                    // Split Time Text

                    // int split = pastCur ? 0 : g_cpDataManager.bestRun.times[i] - g_cpDataManager.currentRun.times[i];
                    // string sColor;
                    // if (split > 0) {
                    //     sColor = pastCur ? color_DarkPos : color_LightPos;
                    // } else if (split < 0){
                    //     sColor = pastCur ? color_DarkNeg : color_LightNeg;
                    // } else{
                    //     sColor = color_Dark;
                    // }
                    // UI::Text("\\$s" + sColor + Time::Format( Math::Abs(split)) );
                    // UI::TableNextColumn();
                }
            }

            UI::EndTable();
        }
        UI::PopStyleColor();

    }

    void DrawCpNumber(int i){
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