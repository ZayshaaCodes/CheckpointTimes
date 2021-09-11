array<int> curTimes(0);
array<int> lastTimes(0);
array<int> bestTimes(0);

uint _cpCount = 0;
bool _dirty = true;
int lastCpIndex = -1;
int highestCpIndex = -1;
bool isNewPb = false;
bool doScroll = false;
CSmArenaClient@ _playground;

// void Main(){
// }

// void Update(float dt){

// }

CSmPlayer@ GetPlayer()
{    
    if(_playground is null) return null;
    if (_playground.GameTerminals.Length < 1) return null;
    return cast<CSmPlayer>((_playground.GameTerminals[0].ControlledPlayer));
}

uint GetLandmarkCount(){    
    auto arena = cast<CSmArena>(_playground.Arena);
    auto map = _playground.Map;
    auto landmarks = arena.MapLandmarks;

    auto lapCount = _playground.Map.TMObjective_IsLapRace ? _playground.Map.TMObjective_NbLaps : uint(1);

    array<int> orders(0);
    uint _cpCount = 1; // starting at 1 because there is always a finish

    // if a cp has an order > 0, it may be a linked CP, so we increment that index and count them later
    for (uint i = 0; i < landmarks.Length; i++)
    {
        auto lm = landmarks[i];
        auto tag = lm.Tag;
        if (lm.Tag == "Checkpoint" )
        {
            if (lm.Order == 0)
            {
                _cpCount++;
            }else{
                if (lm.Order >= orders.Length) orders.Resize(lm.Order + 1);
                orders[lm.Order]++;
            }
        }            
    }

    for (uint i = 0; i < orders.Length; i++)
    {
        if (orders[i] > 0)
        {
            _cpCount++;
        }
    }
    // print(lapCount);
    return _cpCount * lapCount;
}

void Render()
{
    if (!windowsVisible) return;
    auto cur_playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    if (_playground !is cur_playground)
    {
        @_playground = cur_playground;
        _cpCount = 0;
        
        curTimes.Resize(_cpCount);
        lastTimes.Resize(_cpCount);
        bestTimes.Resize(_cpCount);
    }
    if (_playground !is null)
    {   
        if (_cpCount == 0) _cpCount = GetLandmarkCount();
        if (_cpCount == 0) return;
        
        curTimes.Resize(_cpCount);
        lastTimes.Resize(_cpCount);
        bestTimes.Resize(_cpCount);
    }

    auto player = GetPlayer();
    if (player is null) return;
    

    int curCpIndex = GetFinished_CpCount(player) - 1; // minus to get the index of the current cp, 
    if (curCpIndex > lastCpIndex)
    {
        curTimes[curCpIndex] = GetCpFinTime(player, curCpIndex);
        doScroll = true;
        if (curCpIndex > highestCpIndex)
        {
            highestCpIndex = curCpIndex;
            isNewPb = true;
        }
    }
    if (curCpIndex < lastCpIndex)
    {
        doScroll = true;
        print("reset!");
        //checking if we've reached a higher cp than before, or reached the finish
        if (isNewPb || lastCpIndex == int(curTimes.Length - 1) || lastCpIndex == highestCpIndex){
            
            if(curTimes[highestCpIndex] < bestTimes[highestCpIndex] || bestTimes[highestCpIndex] == 0){
            print("New Best");
                for (uint i = 0; i < curTimes.Length; i++)
                {
                    bestTimes[i] = curTimes[i];
                }
            }
            isNewPb = false;
        }

        for (uint i = 0; i < curTimes.Length; i++)
        {
            lastTimes[i] = curTimes[i];
            curTimes[i] = 0;
        }
        lastCpIndex = -1;
    }


    UI::SetNextWindowPos(0, 170);
    UI::SetNextWindowSize(340, 200);
    UI::Begin("CP Times", UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize);
    // UI::Text("" + curCpIndex + " | " + highestCpIndex);
    UI::Columns(4, "cps");


    UI::SetNextItemWidth(20);
    UI::Text("CP"); UI::NextColumn();
    UI::Text("Time"); UI::NextColumn();
    // UI::Text("Last"); UI::NextColumn();
    UI::Text("Best"); UI::NextColumn();
    UI::Text("Split"); UI::NextColumn();

    for (uint i = 0; i < curTimes.Length; i++)
    {
        UI::Separator();
        UI::Text((i == uint(curCpIndex) ? "*" : "") + (i == curTimes.Length - 1 ? "F" : "" +i)); UI::NextColumn();
        UI::Text("" + (curTimes[i] == 0 ? "" : Time::Format(curTimes[i]))); UI::NextColumn();
        // UI::Text("" + (lastTimes[i] == 0 ? "-- : -- : --" :Time::Format(lastTimes[i]))); UI::NextColumn();
        UI::Text("" + (bestTimes[i] == 0 ? "" :Time::Format(bestTimes[i]))); UI::NextColumn();
        if (uint(curCpIndex) < i)
        {
            UI::Text(""); UI::NextColumn();           
        } else{
            int split = curTimes[i] - bestTimes[i];
            UI::Text((split > 0 ? "\\$f00+" : (split == 0 ? "\\$888" : "\\$0f0-")) + Time::Format(Math::Abs(split))); UI::NextColumn();
        }
    }

    if (doScroll)
    {
        float max = UI::GetScrollMaxY();
        auto dist = Math::Max(curCpIndex - 3,0) / Math::Max(float(_cpCount - 5),1.0f) * max;
        UI::SetScrollY(dist);
        doScroll = false;
    }

    UI::End();
    lastCpIndex = curCpIndex;
}

uint GetFinished_CpCount(CSmPlayer@ player){    
    return Dev::GetOffsetUint16(player, 0x680);
}

int GetCpFinTime(CSmPlayer@ player, uint i){
    auto CPTimesArrayPtr = Dev::GetOffsetUint64(player, 0x688 - 0x10);
    auto count = GetFinished_CpCount(player);
    if(i >= count) return -1;

    return Dev::ReadInt32(CPTimesArrayPtr + i * 0x20 + 0x3c) - player.StartTime;
}

// int iSel = 0;
// void RenderInterface(){

//     return;
//     auto app = GetApp();
//     if (app.CurrentPlayground is null) return;
//     auto ArenaNod = cast<CSmArenaClient>(app.CurrentPlayground).Arena;
    
//     if (ArenaNod.Players.Length == 0) return;
//     auto player = cast<CSmPlayer>(ArenaNod.Players[0]);

//     auto ArenaNodType = Reflection::TypeOf(ArenaNod);
//     auto playerType = Reflection::TypeOf(player);

//     UI::Begin("mem info");

//     auto members = playerType.get_Members(); 

//     auto CPTimesArrayPtr = Dev::GetOffsetUint64(player, 0x688 - 0x10);
//     auto count = Dev::GetOffsetUint16(player, 0x680);
//     UI::InputText(count + "", Text::FormatPointer(CPTimesArrayPtr));

//     for (int i = 0; i < count; i++)
//     {        
//         auto t = Dev::ReadInt32(CPTimesArrayPtr + i * 0x20 + 0x3c) - player.StartTime;
//         auto s = Time::Format(t);
//         UI::Text(s) ;
//     }

//     auto playerArrPtr = Dev::GetOffsetUint64(ArenaNod, ArenaNodType.GetMember("Players").Offset);

//     UI::InputText("first player ptr", Text::FormatPointer(Dev::ReadUInt64(playerArrPtr)));


//     for (uint i = 0; i < members.Length; i++)
//     {
//         UI::Text(members[i].Offset + " : " + members[i].get_Name());    
//     }


//     UI::End();
// }

bool windowsVisible = true;
void RenderMenu(){
    if (UI::MenuItem("\\$2f9" + Icons::PuzzlePiece + "\\$fff CP Times", selected: windowsVisible, enabled: GetApp().CurrentPlayground !is null))
	{
		windowsVisible = !windowsVisible;
	}
}

// void RenderMenuMain(){
    
// }

// void RenderSettings(){
    
// }

// bool OnKeyPress(bool down, VirtualKey key){    
//     return false;
// }

// bool OnMouseButton(bool down, int button, int x, int y){
//     return false;
// }

// void OnMouseMove(int x, int y){

// }

// void OnSettingsChanged(){

// }

// void OnSettingsSave(Settings::Section& section){

// }

// void OnSettingsLoad(Settings::Section& section){

// }

// void OnLoadCallback(CMwNod@ nod){

// }

// void OnDisabled(){

// }

// void OnDestroyed(){

// }