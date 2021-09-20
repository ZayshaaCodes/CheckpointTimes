class DebuggingUiPanel : ZUtil::UiPanel, ZUtil::IHandleCpEvents
{

    
    DebuggingUiPanel()
    {
        super("Debugging", vec2(.5f,.5f), vec2(100,100));
    }

    void OnCpTimesCountChangeEvent(int i)
    {   
        print("DebuggingUiPanel.OnCpTimesCountChangeEvent");
    }

    void OnCPNewTimeEvent(int i, int t)
    {
        print("DebuggingUiPanel.OnCPNewTimeEvent");
    }

    void OnSettingsChanged() {}

    void Render() 
    {
        UI::Begin("DebuggingUiPanel");

        UI::End();
    }

    void Update(float dt) {}
}
