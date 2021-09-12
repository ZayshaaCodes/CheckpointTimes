namespace Sample
{
    ZUtil::CpDataManager@ cpDataManager;

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

    void Update(float dt){
        if (cpDataManager !is null)
        {
            cpDataManager.Update();
        }
    }

    void Render(){
        if (cpDataManager !is null)
        {
            cpDataManager.Render();
        }
    }
}
