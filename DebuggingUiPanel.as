class DebuggingUiPanel : ZUtil::UiPanel 
{
    void OnSettingsChanged() {}
    void Render() {

        UI::Begin("DebuggingUiPanel");

        UI::Text("Hello World");

        UI::End();

    }
    void Update(float dt) {}
}