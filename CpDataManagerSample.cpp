namespace Sample
{
    ZUtil::CpDataManager@ cpDataManager;

    CSmPlayer@ player;
    CSmArenaClient@ playground;

    void Main(){
        @cpDataManager = ZUtil::CpDataManager();
        @cpDataManager.countChangeCallback = @OnCpChange;
        @cpDataManager.newTimeCallback = @OnNewTime;
    }

    void OnCpChange(int i){
        print("Change to: " + i);
        if (i < 0)
        {
            print("Restart!");
        }
    }

    void OnNewTime(int i, int newTime){
        print("New time: " + i + " : " + Time::Format(newTime));
    }

    void Update(float dt)
    {
        @playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        @player = ZUtil::GetPlayer(playground);
        if (player is null) return;

        if (cpDataManager !is null)
        {
            cpDataManager.Update(player);
        }
    }

    array<int> times(200);
    void Render(CSmPlayer@ player, CSmArenaClient@ playground)
    {
        auto i = cpDataManager.GetAllCpTimes(player, times);

        if (cpDataManager !is null)
        {
            cpDataManager.Render(player);
        }
    }
}
