
class CpTimesPanel : ZUtil::UiPanel , ZUtil::IHandleCpEvents
{
    ZUtil::CpDataManager@ _cpDataManager;

    array<int> curTimes(0);
    array<int> lastTimes(0);
    array<int> bestTimes(0);
    array<int> splitTimes(0);

    CpTimesPanel()
    {
        @_cpDataManager = ZUtil::CpDataManager(this);
    }

    void OnCpTimesCountChangeEvent(int i)
    {   
        
        print("OnCpTimesCountChangeEvent");
    }

    void OnCPNewTimeEvent(int i, int t)
    {
        print("OnCPNewTimeEvent");
    }
    
    void OnSettingsChanged() override 
    {
        // print("OnSettingsChanged");
    }

    void Render() override 
    {
        UI::Begin("CpTimesPanel");

        UI::Text("Hello World2");

        UI::End();
    }

    void Update(float dt) override 
    {
        auto playground = g_app.CurrentPlayground;
        if (playground is null) return;

        auto player = ZUtil::GetLocalPlayer(playground);
        if (player is null) return;

        _cpDataManager.Update(player);
        // print("Update");
    }
}