

void Render()
{
    if (!CanShowTimes) return;

    if (!windowsVisible) return;


    CSmPlayer@ player = GetPlayer();
    if (player is null) return;

    _curCpIndex = GetFinished_CpCount(player) - 1; // minus to get the index of the current cp,

    if(_isRoyalMap)
    {
        DoRoyalLogic(player);
    } else {
        DoRaceLogic(player);
    }
    _lastCpIndex = _curCpIndex;

    DrawWindow(player);
}

void DrawWindow(CSmPlayer@ player)
{
    UI::SetNextWindowPos(0, 170);
    UI::SetNextWindowSize(280, Math::Min(_cpCount, 8) * 21 + 32);
    UI::Begin("CP Times", UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking);
    // UI::Text("" + curCpIndex + " | " + _highestCpIndex);

    // UI::Text(_playground.Arena.MapLandmarks[ player.CurrentLaunchedRespawnLandmarkIndex].Order + "");

    UI::BeginGroup();
    if(UI::BeginTable("table", 4, UI::TableFlags::SizingFixedFit)) {
        UI::TableSetupColumn("CP", UI::TableColumnFlags::WidthFixed, 20);
        UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 65);
        UI::TableSetupColumn("Best", UI::TableColumnFlags::WidthFixed, 65);
        UI::TableSetupColumn("Split", UI::TableColumnFlags::WidthFixed, 65);
        UI::TableHeadersRow();

        for (uint i = 0; i < curTimes.Length; i++)
        {
            UI::TableNextRow();
            UI::TableNextColumn();
            // CP text
            if (_isRoyalMap)
            {
                string letter = "";
                if (i == 0) letter = "\\$fffW";
                else if (i == 1) letter = "\\$0f0G";
                else if (i == 2) letter = "\\$55fB";
                else if (i == 3) letter = "\\$f00R";
                else if (i == 4) letter = "\\$888B";
                UI::Text( letter ); UI::NextColumn();
            } else {
                UI::Text((int(i) <= _curCpIndex ? "\\$3f3" : "") + (i == curTimes.Length - 1 ? "F" : "" + (i + 1))); UI::NextColumn();
            }
            UI::TableNextColumn();

            // Current Time Text
            UI::Text("" + (curTimes[i] == 0 ? "" : Time::Format(curTimes[i]))); UI::NextColumn();
            UI::TableNextColumn();

            // Best Time Text
            UI::Text("" + (bestTimes[i] == 0 ? "" :Time::Format(bestTimes[i]))); UI::NextColumn();
            UI::TableNextColumn();

            // Split Time Text
            int split = splitTimes[i];
            if (!_isRoyalMap && _curCpIndex < int(i))
            {
                UI::Text((split > 0 ? "\\$800+" : (split == 0 ? "\\$444" : "\\$080-")) + Time::Format(Math::Abs(split)));
                UI::NextColumn();
            } else{

                uint currentLaunchIndex = player.CurrentLaunchedRespawnLandmarkIndex;
                if (_curColor == i && currentLaunchIndex >= 5)
                    UI::Text((split > 0 ? "\\$800+" : (split == 0 ? "\\$444" : "\\$080-")) + Time::Format(Math::Abs(split)));
                else
                    UI::Text((split > 0 ? "\\$f00+" : (split == 0 ? "\\$444" : "\\$0f0-")) + Time::Format(Math::Abs(split)));
                UI::NextColumn();
            }
        }

        if (_doScroll)
        {
            float max = UI::GetScrollMaxY();
            auto dist = Math::Max(_curCpIndex - 3,0) / Math::Max(float(_cpCount - 5),1.0f) * max;
            UI::SetScrollY(dist);
            _doScroll = false;
        }

      UI::EndTable();
    }
    UI::EndGroup();

    UI::End();
}

void DoRoyalLogic(CSmPlayer@ player)
{
    uint currentLaunchIndex = player.CurrentLaunchedRespawnLandmarkIndex;
    auto landmarks = _playground.Arena.MapLandmarks;
    _curColor = landmarks[currentLaunchIndex].Order;
    return;
    if (_curCpIndex > _lastCpIndex) // NewCp
    {
        print("Finised color: " + currentLaunchIndex);
        int currentTime = GetCpFinTime(player, 0);
        curTimes[currentLaunchIndex] = currentTime;
        int curBestTime = bestTimes[currentLaunchIndex];
        if (curBestTime == 0 || curBestTime > currentTime)
        {
            bestTimes[currentLaunchIndex] = currentTime;
            splitTimes[currentLaunchIndex] = currentTime - curBestTime;
        } else {
            splitTimes[currentLaunchIndex] = currentTime - curBestTime;
        }
    }
    if (currentLaunchIndex >= 5) {

        auto ps = GetApp().PlaygroundScript;
        auto now = ( ps !is null )? ps.Now : 0;
        if (int(now) < player.StartTime)
        {
            curTimes[_curColor] = 0;
        } else {
            curTimes[_curColor] = now - player.StartTime;
        }
    }

    if (_lastColor != _curColor)
    {
        print("Color Change: " + _curColor);
    }

    _lastColor = _curColor;
}

void DoRaceLogic(CSmPlayer@ player){
    if (_curCpIndex > _lastCpIndex) // NewCp
    {
        curTimes[_curCpIndex] = GetCpFinTime(player, _curCpIndex);
        splitTimes[_curCpIndex] = curTimes[_curCpIndex] - bestTimes[_curCpIndex];
        if (bestTimes[_curCpIndex] == 0)
            splitTimes[_curCpIndex] = 0;
        _doScroll = true;
        if (_curCpIndex > _highestCpIndex)
        {
            _highestCpIndex = _curCpIndex;
            _isNewPb = true;
        }
    }
    if (_curCpIndex < _lastCpIndex) // Reset
    {
        _doScroll = true;
        // print("reset!");
        //checking if we've reached a higher cp than before, or reached the finish
        if (_isNewPb || _lastCpIndex == int(curTimes.Length - 1) || _lastCpIndex == _highestCpIndex){

            if(curTimes[_highestCpIndex] < bestTimes[_highestCpIndex] || bestTimes[_highestCpIndex] == 0){
            // print("New Best");
                for (uint i = 0; i < curTimes.Length; i++)
                {
                    bestTimes[i] = curTimes[i];
                }
            }
            _isNewPb = false;
        }

        for (uint i = _lastCpIndex +1 ; i < splitTimes.Length; i++)
        {
            splitTimes[i] = 0;
        }

        for (uint i = 0; i < curTimes.Length; i++)
        {
            lastTimes[i] = curTimes[i];
            curTimes[i] = 0;
        }
        _lastCpIndex = -1;
    }
}
g40
int iSel = 0;
void RenderInterface2(){
    auto app = GetApp();
    if (app.CurrentPlayground is null) return;
    auto ArenaNod = cast<CSmArenaClient>(app.CurrentPlayground).Arena;

    if (ArenaNod.Players.Length == 0) return;
    auto player = cast<CSmPlayer>(ArenaNod.Players[0]);

    auto ArenaNodType = Reflection::TypeOf(ArenaNod);
    auto playerType = Reflection::TypeOf(player);

    UI::Begin("mem info");

    auto members = playerType.get_Members();

    auto CPTimesArrayPtr = Dev::GetOffsetUint64(player, 0x688 - 0x10);
    auto count = Dev::GetOffsetUint16(player, 0x680);
    UI::InputText(count + "", Text::FormatPointer(CPTimesArrayPtr));

    for (uint i = 0; i < count; i++)
    {
        auto t = Dev::ReadInt32(CPTimesArrayPtr + i * 0x20 + 0x3c) - player.StartTime;
        auto s = Time::Format(t);
        UI::Text(s) ;
    }

    auto playerArrPtr = Dev::GetOffsetUint64(ArenaNod, ArenaNodType.GetMember("Players").Offset);
    auto scoreOffset = playerType.GetMember("Score").Offset - 0x680;

    UI::InputText("!Score Offset: ", Text::FormatPointer(uint64(scoreOffset)));


    for (uint i = 0; i < members.Length; i++)
    {
        UI::Text(Text::FormatPointer(uint64(members[i].Offset)).SubStr(12) + " : " + members[i].get_Name());
    }


    UI::End();
}
