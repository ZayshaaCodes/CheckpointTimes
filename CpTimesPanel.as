array<Column@> g_timesPanelColumns; 

[SettingsTab name="Panel Columns" order="1"]
void RenderSettings()
{
    UI::Text("Default Column Visibility:");

    bool change = false;
    if (UI::Checkbox("Show CP number", g_timesPanelColumnCpNumberEnabled) != g_timesPanelColumnCpNumberEnabled)
    {
        g_timesPanelColumnCpNumberEnabled = !g_timesPanelColumnCpNumberEnabled;
        change = true;
    }
    if (UI::Checkbox("Show Speed", g_timesPanelColumnSpeedEnabled) != g_timesPanelColumnSpeedEnabled)
    {
        g_timesPanelColumnSpeedEnabled = !g_timesPanelColumnSpeedEnabled;
        change = true;
    }
    if (UI::Checkbox("Show Time", g_timesPanelColumnTimeEnabled) != g_timesPanelColumnTimeEnabled)
    {
        g_timesPanelColumnTimeEnabled = !g_timesPanelColumnTimeEnabled;
        change = true;
    }
    if (UI::Checkbox("Show PB Split", g_timesPanelColumnPbSplitEnabled) != g_timesPanelColumnPbSplitEnabled)
    {
        g_timesPanelColumnPbSplitEnabled = !g_timesPanelColumnPbSplitEnabled;
        change = true;
    }
    if (UI::Checkbox("Show PB Split Speed", g_timesPanelColumnPbSplitSpeedEnabled) != g_timesPanelColumnPbSplitSpeedEnabled)
    {
        g_timesPanelColumnPbSplitSpeedEnabled = !g_timesPanelColumnPbSplitSpeedEnabled;
        change = true;
    }
    if (UI::Checkbox("Show PB Speed", g_timesPanelColumnPbSpeedEnabled) != g_timesPanelColumnPbSpeedEnabled)
    {
        g_timesPanelColumnPbSpeedEnabled = !g_timesPanelColumnPbSpeedEnabled;
        change = true;
    }
    if (UI::Checkbox("Show PB Time", g_timesPanelColumnPbTimeEnabled) != g_timesPanelColumnPbTimeEnabled)
    {
        g_timesPanelColumnPbTimeEnabled = !g_timesPanelColumnPbTimeEnabled;
        change = true;
    }
    if (UI::Checkbox("Show Target Split", g_timesPanelColumnTargetSplitEnabled) != g_timesPanelColumnTargetSplitEnabled)
    {
        g_timesPanelColumnTargetSplitEnabled = !g_timesPanelColumnTargetSplitEnabled;
        change = true;
    }
    if (UI::Checkbox("Show Target Time", g_timesPanelColumnTargetTimeEnabled) != g_timesPanelColumnTargetTimeEnabled)
    {
        g_timesPanelColumnTargetTimeEnabled = !g_timesPanelColumnTargetTimeEnabled;
        change = true;
    }
    
    if (change) {
        int i = 0;
        if (g_timesPanelColumnCpNumberEnabled) i++;
        if (g_timesPanelColumnSpeedEnabled) i++;
        if (g_timesPanelColumnTimeEnabled) i++;
        if (g_timesPanelColumnPbSplitEnabled) i++;
        if (g_timesPanelColumnPbSplitSpeedEnabled) i++;
        if (g_timesPanelColumnPbSpeedEnabled) i++;
        if (g_timesPanelColumnPbTimeEnabled) i++;
        if (g_timesPanelColumnTargetSplitEnabled) i++;
        if (g_timesPanelColumnTargetTimeEnabled) i++;
        if (i == 0) {
            g_timesPanelColumnTimeEnabled = true;
        }

        for (uint j = 0; j < g_timesPanelColumns.Length; j++) {
            g_timesPanelColumns[j].enabled = false;
        }
        _timesPanel.ConfigColumbs();
    }
}

class CpTimesPanel : ZUtil::UiPanel
{
    CpDataContext@ cpData;

    private array<dictionary> _tableData;
    private uint _rows = 0;
    bool doScroll = false;
     
    CpTimesPanel(CpDataContext@ dataManager) 
    {
        @cpData = dataManager;
        super("Cp Times", TimesPanel_position, TimesPanel_size);
        _tableData = array<dictionary>();

        ConfigColumbs();
        InitTableData(1);
    }

    void ConfigColumbs(){

        //look for the settings file
        g_timesPanelColumns = {};

        float widthScaler = TimesPanel_fontSize / 19.0f;

        auto numCol = Column("num", "#", int(20 * widthScaler) , g_timesPanelColumnCpNumberEnabled);
        @numCol.displayValue = function(CpDataContext@ rd, int i){ 
            return i + 1; 
        };
        numCol.darkenAfterCurrent = false;
        numCol.lastCpFlag = true;
        g_timesPanelColumns.InsertLast(numCol);


        auto speedCol = Column("speed", Icons::Tachometer, int(50 * widthScaler), g_timesPanelColumnSpeedEnabled);
        @speedCol.displayValue = function(CpDataContext@ rd, int i){ 
            return int(rd.current.speeds[i]); 
        };
        @speedCol.displayValueLast = function(CpDataContext@ rd, int i){ 
            return int(rd.last.speeds[i]); 
        };
        g_timesPanelColumns.InsertLast(speedCol);

        auto timeCol = Column("time", Icons::ClockO, int(75 * widthScaler), g_timesPanelColumnTimeEnabled);
        @timeCol.displayValue = function(CpDataContext@ rd, int i){ 
            return rd.current.times[i]; 
        };
        @timeCol.displayValueLast = function(CpDataContext@ rd, int i){ 
            return rd.last.times[i]; 
        };
        timeCol.formatTime = true;
        //cyan
        timeCol.baseColor = vec3(0.0, 1.0, 1.0);
        g_timesPanelColumns.InsertLast(timeCol);
        
        auto pbSplitCol = Column("pbSplit", "PB Δ", int(75 * widthScaler), g_timesPanelColumnPbSplitEnabled);
        @pbSplitCol.displayValue = function(CpDataContext@ rd, int i){
            int split = rd.current.times[i] - rd.best.times[i];
            //if the best time is zero, negate result
            if (rd.best.times[i] == 0) return -split;
            if (rd.current.wasPB) return -split;
            return split;
        };
        @pbSplitCol.displayValueLast = function(CpDataContext@ rd, int i){ 
            int lastSplit = rd.last.times[i] - rd.best.times[i];
            if (rd.last.times[i] == 0) return 0;
            if (rd.best.times[i] == 0) return - lastSplit;
            if (rd.last.wasPB) return - lastSplit;

            return lastSplit;
        };
        pbSplitCol.formatTime = true;
        pbSplitCol.forceSign = true;
        pbSplitCol.signColors = true;
        g_timesPanelColumns.InsertLast(pbSplitCol);

        auto pbSplitSpeedCol = Column("pbSplitSpeed", Icons::Tachometer + " Δ", int(50 * widthScaler), g_timesPanelColumnPbSplitSpeedEnabled);
        @pbSplitSpeedCol.displayValue = function(CpDataContext@ rd, int i){ 
            int splitSpeed = int(rd.current.speeds[i]) - int(rd.best.speeds[i]);
            if (rd.current.wasPB) return -splitSpeed;
            return splitSpeed; 
        };
        @pbSplitSpeedCol.displayValueLast = function(CpDataContext@ rd, int i){ 
            //if last speed is zero , just return zero
            int splitSpeed = int(rd.last.speeds[i]) - int(rd.best.speeds[i]);
            if (rd.last.speeds[i] == 0) return 0;
            if (rd.last.wasPB) return -splitSpeed;
            return splitSpeed;

        };
        pbSplitSpeedCol.signColors = true;
        vec3 temp = pbSplitSpeedCol.negColor;
        pbSplitSpeedCol.negColor = pbSplitSpeedCol.posColor;
        pbSplitSpeedCol.posColor = temp;
        g_timesPanelColumns.InsertLast(pbSplitSpeedCol);
        
        auto pbSpeedCol = Column("pbSpeed", "PB " + Icons::Tachometer, int(50 * widthScaler), g_timesPanelColumnPbSpeedEnabled);
        @pbSpeedCol.displayValue = function(CpDataContext@ rd, int i){ 
            return int(rd.best.speeds[i]); 
        };
        g_timesPanelColumns.InsertLast(pbSpeedCol);

        Column@ pbTimeCol = Column("pbTime", "PB " + Icons::ClockO, int(75 * widthScaler),    g_timesPanelColumnPbTimeEnabled);
        @pbTimeCol.displayValue = function(CpDataContext@ rd, int i){ 
            return rd.best.times[i]; 
        };
        pbTimeCol.formatTime = true;
        //cyan
        pbTimeCol.baseColor = vec3(0.0, 1.0, 1.0);
        pbTimeCol.darkenAfterCurrent = false;
        g_timesPanelColumns.InsertLast(pbTimeCol);

        auto targetSplitCol = Column("targetSplit", "Tar Δ", int(75 * widthScaler), g_timesPanelColumnTargetSplitEnabled);
        @targetSplitCol.displayValue = function(CpDataContext@ rd, int i){ 
            if (rd.target.times[i] == 0) return 0;
            int split  = rd.current.times[i] - rd.target.times[i];
            if (rd.current.wasPB) return -split;
            return split;
        };
        @targetSplitCol.displayValueLast = function(CpDataContext@ rd, int i){ 
            if (rd.last.times[i] == 0) return 0;
            int split = rd.last.times[i] - rd.target.times[i];
            if (rd.last.wasPB) return -split;
            return split;
        };
        targetSplitCol.formatTime = true;
        targetSplitCol.signColors = true;
        g_timesPanelColumns.InsertLast(targetSplitCol);

        auto targetTimeCol = Column("targetTime", "Tar " + Icons::ClockO, int(75 * widthScaler), g_timesPanelColumnTargetTimeEnabled);
        @targetTimeCol.displayValue = function(CpDataContext@ rd, int i){ 
            return rd.target.times[i]; 
        };
        targetTimeCol.formatTime = true;
        targetTimeCol.darkenAfterCurrent = false;
        //yellow
        targetTimeCol.baseColor = vec3(1.0, 1.0, 0.0);
        g_timesPanelColumns.InsertLast(targetTimeCol);

        isLoad = true;
    }

    void UpdateAllRows(){
        for (uint i = 0; i < _rows; i++) {
            UpdateRow(i);
        }
    }

    void UpdateRow(uint i){

        for (uint j = 0; j < g_timesPanelColumns.Length; j++) {
            auto column = g_timesPanelColumns[j];
            auto display = column.GetDisplay(cpData, i);
            _tableData[i][column.id] = display;
        }
        doScroll = true;
    }

    void InitTableData(uint rowCount)  
    {
        cpData.Resize(rowCount);
        _tableData.Resize(rowCount);
        _rows = rowCount;

        for (uint i = 0; i < rowCount; i++) {
            dictionary row = dictionary();
        
            for (uint j = 0; j < g_timesPanelColumns.Length; j++) {
                row[g_timesPanelColumns[j].id] = "*"; //placeholder, end user should never see this
            }
            _tableData[i] = row;
        }
        UpdateAllRows();
    }

    void SetColData(array<string> data, const string &in colName) {

        uint count = uint(Math::Min(data.Length, _rows));

        for (uint i = 0; i < count; i++) {
            auto row = _tableData[i];

            //bounds check
            row[colName] = data[i];
        }
    }

    void SetTableData(const uint &in row, const string &in colName, const string &in data) {
        if (row >= _rows) return;

        auto rowData = _tableData[row];
        rowData[colName] = data;
    }

    bool isLoad = true;
    bool mouseDown = false;
    void Render() override 
    {
        if (!TimePanel_visible) return;

        // if(tableData is null || tableData.GetKeys().Length == 0) {
        //     return;
        // }

        if(HidePanelsWithInterface) {
            auto playground = GetApp().CurrentPlayground;
            if(playground is null || playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
            return;
            }
        }
        //print the window pos and size

        uint colCount = g_timesPanelColumns.Length;


        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0, 0.4));
        UI::PushFont(g_font);
        UI::Begin("Cp Times", UI::WindowFlags::NoTitleBar 
                    | UI::WindowFlags::NoCollapse 
                    | UI::WindowFlags::NoDocking);


        // todo: mouse drag splits
        // print("CpTimesPanel: " + UI::GetWindowPos().x + " " + UI::GetWindowPos().y + " " + UI::GetWindowSize().x + " " + UI::GetWindowSize().y);
        
        // auto windowPos = UI::GetWindowPos();
        // auto pos = UI::GetMousePos();
        // auto loaclPos =  pos - windowPos;

        // if(UI::IsMouseClicked(UI::MouseButton::Right))
        // {
        //     print("right mouse clicked");
        //     print("mouse pos: " + loaclPos.x + " " + loaclPos.y);
        //     mouseDown = true;
        // }

        // if(mouseDown)
        // {
        //     print("mouse pos: " + loaclPos.x + " " + loaclPos.y);
        // }

        // if(mouseDown && !UI::IsMouseDown(UI::MouseButton::Right))
        // {
        //     print("right mouse released");
        //     print("mouse pos: " + loaclPos.x + " " + loaclPos.y);
        //     mouseDown = false;
        // }

        string author = "";
        if(TimesPanel_showAuthor)
            author = ColoredString("$z$bbb$s$n") + " " + g_mapInfo.author;

        UI::Text(g_mapInfo.coloredName + author);


        //list the target player's name on the right
        if (cpData.target.playerName != "") {
            UI::SameLine();
            UI::Text(ColoredString("$z$o$s") + "  Target: " + cpData.target.playerName);
        }
        

        if (UI::BeginTable("Cptimes_Panel_Header", colCount, UI::TableFlags::ContextMenuInBody | UI::TableFlags::Hideable)){
            for (uint i = 0; i < colCount; i++) {
                auto val = g_timesPanelColumns[i];
                UI::TableSetupColumn(val.name, UI::TableColumnFlags::WidthFixed, val.width);            
            }
            UI::TableHeadersRow();
            
            if (isLoad){
                for (uint i = 0; i < colCount; i++) {
                    UI::TableSetColumnEnabled(i, g_timesPanelColumns[i].enabled);
                }
                isLoad = false;
            } else {
                for (uint i = 0; i < colCount; i++) 
                {
                    UI::TableNextColumn();
                    g_timesPanelColumns[i].enabled = UI::TableGetColumnFlags() & UI::TableColumnFlags::IsVisible != 0;
                }
            }

            UI::EndTable();
        }

        // //move the cursor up to close the gap between the header and the table
        auto cursorPos = UI::GetCursorPos();
        UI::SetCursorPos(vec2(cursorPos.x, cursorPos.y - 8));

        UI::BeginChild("Cptimes_PanelChild",vec2(), false, TimesPanel_showScrollbar ? UI::WindowFlags::NoScrollbar : 0);
        if (UI::BeginTable("Cptimes_Panel_Table", colCount, UI::TableFlags::Hideable))
        {
            for (uint i = 0; i < colCount; i++) {
                auto val = g_timesPanelColumns[i];
                UI::TableSetupColumn(val.name, UI::TableColumnFlags::WidthFixed, val.width);            
            }
            for (uint i = 0; i < colCount; i++) {
                UI::TableSetColumnEnabled(i, g_timesPanelColumns[i].enabled);
            }

            for (uint i = 0; i < _tableData.Length; i++) {
                auto rowData = cast<dictionary>(_tableData[i]);

                for(uint j = 0; j < colCount; j++) {
                    UI::TableNextColumn();
                    auto val = string(rowData[g_timesPanelColumns[j].id]);
                    UI::Text(val);
                }
            }


            UI::EndTable();
        }
        if (doScroll)
        {
            float max = UI::GetScrollMaxY();
            auto dist = Math::Max(cpData.curCp - 3,0) / Math::Max(float(g_mapInfo.numCps - 5),1.0f) * max;
            UI::SetScrollY(dist);
            doScroll = false;
        }
        UI::EndChild();
        UI::End();
        UI::PopFont();
        UI::PopStyleColor();
    }

    void OnSettingsChanged() override {
        
    }

    
}

// TODO: make a way to re-order the columns
// [SettingsTab name="cp Times Panel settings"]
// void CpTimesPanelSettings()
// 
//  if( UI::BeginChild("CpTimesPanelSettings")){
//      //render everything to re-order the list, on the left is a up and down button, the right will show the name of the column
//      for (int i = 0; i < keys.Length; i++) {
//          // UI::BeginGroup();
//          // UI::PushID("^" + i);
//          // if (UI::Button("", vec2(20, 15))) {
//          //     if (i > 0) {
//          //         auto temp = _timesPanelColumns[i];
//          //         _timesPanelColumns[i] = _timesPanelColumns[i - 1];
//          //         _timesPanelColumns[i - 1] = temp;
//          //     }
//          // }
//          // UI::PopID();
//          // UI::PushID("v" + i);
//          // if (UI::Button("", vec2(20, 15))) {
//          //     if (i < keys.Length - 1) {
//          //         auto temp = _timesPanelColumns[i];
//          //         _timesPanelColumns[i] = _timesPanelColumns[i + 1];
//          //         _timesPanelColumns[i + 1] = temp;
//          //     }
//          // }
//          // UI::PopID();
//          // UI::EndGroup( 
//          UI::PushID(i);
//          //render the name centered to the right of the buttons
//          UI::Text(keys[i]);
//          UI::SameLine(    
//          auto cursorPos = UI::GetCursorPos();
//          UI::SetCursorPos(vec2(100, cursorPos.y)  
//          auto oldVal = int(_timesPanelColumns[keys[i]]);
//          //width 200
//          UI::PushItemWidth(200);
//          auto newVal =  UI::InputInt("##" + i, oldVal);
//          UI::PopItemWidth();
//          if (newVal != oldVal) {
//              _timesPanelColumns[keys[i]] = newVal;
//           
//          UI::PopID();
//        
//      UI::EndChild();
//  }   
// }

