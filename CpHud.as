
// this basicly just draws the split time and speed for the last cp, when a new cp is hit, it lerps the values out of the screen.
class CpHud : ZUtil::NvgPanel
{
    float dist = 50;
    float t = 0;

    array<SplitHudElement@> splitHudElements;

    SplitHudElement@ timeHudElement;
    SplitHudElement@ speedHudElement;

    CpHud(){
        super("Cp Hud", SplitHud_position, SplitHud_size);
        //m_moveHud = true;
        
        auto split = .625;
        @timeHudElement = SplitHudElement(vec4(0,0,split,1.0));
        timeHudElement.renderAsTime = true;
        //invert the colors for time
        @speedHudElement = SplitHudElement(vec4(split,0,1.0,1.0));

        splitHudElements.InsertLast(timeHudElement);
        splitHudElements.InsertLast(speedHudElement);

        OnSettingsChanged();
    }

    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){    
    }

    void OnPlayerLoaded(CSmPlayer@ player){

    }

    void OnSettingsChanged() override {
        m_moveHud = SplitHud_move;
        m_pos = SplitHud_position;
        m_size = SplitHud_size;
    }

    // Decreases the value of 't' over time, gradually fading out the HUD display.
        /**
         * Updates the HUD display by decreasing the value of 't' over time.
         * This function is for lerping into a new state when a new time is
         *
         * @param dt The time elapsed since the last update.
         */
        void Update(float dt) override 
        {
            t -= dt / 500;
            if (t <= 0) t = 0;
    }

    void Render() override 
    {
        if(!g_gameState.hasMap || !SplitHud_visible ) return;
        
        if(HideHudWithInterface) {
            auto playground = GetApp().CurrentPlayground;
            if(playground is null || playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
            return;
            }
        }
        
        auto verticalShift = dist * easeOutSine(t);

        nvg::TextAlign(18);
		nvg::BeginPath();
        nvg::FontFace(g_fontface);
		nvg::FontSize(SplitHud_fontSize);

        for(uint i = 0; i < splitHudElements.Length; i++)
        {
            splitHudElements[i].Render(m_pos, m_size);
        }

    }

    void OnMoveHud() override {
        SplitHud_position = m_pos;
        SplitHud_size = m_size;
    }

    void OnCPNewTimeEvent(int c, int time, int speed)
    {   
        // print(speed);

        timeHudElement.SetDisplayValue(time - g_cpData.best.times[c]);
        speedHudElement.SetDisplayValue(int(speed - g_cpData.best.speeds[c]));
        
        dist = 50;
        t = 1;
    }

    float BezierBlend(float t)
    {
        return t * t * (3.0f - 2.0f * t);
    }
    
    float easeOutSine(float t ) {
        return 1 + Math::Sin( 1.5707963f * (--t) );
    }
}

class SplitHudElement
{
    int currentSplit;
    int lastSplit;

    vec4 currentColor;
    vec4 lastColor;

    bool renderAsTime = false;

    vec4 rect;

    float t; // value that will lerp back to 0 when it's value is not zero (can be positive or negative, depending on the direction of the animation)
    float shiftDistance = 50;

    SplitHudElement(vec4 rect)
    {
        this.rect = rect;
        currentSplit = 0;
        lastSplit = 0;
    }

    void SetDisplayValue(int value)
    {
        lastSplit = currentSplit;
        currentSplit = value;
    }

    void Render(vec2 panelPos, vec2 PanelSize)
    {
        float left = panelPos.x + rect.x * PanelSize.x; //left side of the panel
        float bottom = panelPos.y + rect.y * PanelSize.y; //bottom side of the panel
        float yMiddle = (panelPos.y + PanelSize.y) * .5f; //vertical center of the panel
        float width = (panelPos.x + rect.z * PanelSize.x) - left; //width
        float height = (panelPos.y + rect.w * PanelSize.y) - bottom; //height
        
        vec4 negativeColor = SplitHud_badColor;
        vec4 positiveColor = SplitHud_goodColor;
        vec4 neutralColor = SplitHud_neutralColor;

        //set the color of the rectangle based on the value of the current split, renderAsTime will invert the colors
        if(currentSplit > 0) currentColor = renderAsTime ? negativeColor : positiveColor;
        else if(currentSplit < 0) currentColor = renderAsTime ? positiveColor : negativeColor;
        else currentColor = neutralColor;

        nvg::BeginPath(); //draw a rectangle with some 2 px margins on all sides
        nvg::RoundedRect(left + 2, bottom + 2, width - 4, height - 4, 2);
        nvg::FillColor(currentColor);
        nvg::Fill();

        string s = currentSplit + "";

        if(renderAsTime)
        {
            s = ZUtil::FormatTime(currentSplit, true);
        }

        nvg::FillColor(vec4(0,0,0,1));
        nvg::TextBox(left + 2,yMiddle+3 ,width, s);

        nvg::FillColor(vec4(1,1,1,1));
        nvg::TextBox(left,yMiddle+2,width, s);



    }
}