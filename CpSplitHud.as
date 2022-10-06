class CpSplitHud : ZUtil::NvgPanel, ZUtil::IHandleCpEvents, ZUtil::IHandleGameStateEvents

{

    int lastCpIndex;
    int lastLastCpIndex;

    int lastCpTime;
    int lastLastCpTime;

    int lastSplit;
    int lastLastSplit;

    float dist = 50;
    float t = 0;

    nvg::Font g_font;
    CpSplitHud(){
        super("Cp Hud", SplitHud_position, SplitHud_size);
        //m_moveHud = true;
        g_font = nvg::LoadFont("DroidSans-Bold.ttf");
        OnSettingsChanged();
    }

    void OnMapLoaded(CGameCtnChallenge@ map, CSmArena@ arena){       
        lastCpIndex = 0;
        lastLastCpIndex = 0;
        lastCpTime = 0;
        lastLastCpTime = 0;
        lastSplit = 0;
        lastLastSplit = 0;
    }

    void OnPlayerLoaded(CSmPlayer@ player){

    }

    void OnSettingsChanged() override {
        m_moveHud = SplitHud_move;
        m_pos = SplitHud_position;
        m_size = SplitHud_size;
    }

    void Update(float dt) override 
    {
        t -= dt / 500;
        if (t <= 0) t = 0;
    }

    void Render() override 
    {
        if(!g_gameState.hasMap || !SplitHud_visible ) return;
        
        if(GeneralSettings::HideHudWithInterface) {
            auto playground = GetApp().CurrentPlayground;
            if(playground is null || playground.Interface is null || Dev::GetOffsetUint32(playground.Interface, 0x1C) == 0) {
            return;
            }
        }
        // nvg::BeginPath();
        // nvg::FillColor(vec4(0,0,0,.85f));
        // nvg::Rect(m_pos.x, m_pos.y, m_size.x, m_size.y);
        // nvg::Fill();
        
        auto dv = dist * easeOutSine(t);

        vec3 tc = vec3(.5f,.5f,.5f);
        vec3 lc = vec3(.5f,.5f,.5f);
        string tsign = "";
        string lsign = "";

        if (lastSplit < 0){
            tsign = "-";
            tc = vec3(.1f,1,.1f);
        } else if (lastSplit > 0) {
            tsign = "+";
            tc = vec3(1,.1f,.1f);
        }
            
        if (lastLastSplit < 0) {
            lsign = "-";
            lc = vec3(.1f,1,.1f);
        } else if (lastLastSplit > 0) {
            lsign = "+";
            lc = vec3(1,.1f,.1f);
        }
        
        nvg::TextAlign(18);
		nvg::BeginPath();
		// nvg::FontFace(m_font);
		nvg::FontSize(SplitHud_fontSize);
        nvg::FontFace(g_font);

        auto shadow = SplitHud_shadow;
        auto offset = SplitHud_shadowOffset;
        if(shadow){
	    	nvg::FillColor(vec4(0,0,0,1-t));
            nvg::TextBox(m_pos.x + offset,m_pos.y + offset + m_size.y *.5f + dv * t ,m_size.x,tsign + Time::Format(Math::Abs(lastSplit)));
        }
		nvg::FillColor(vec4(tc.x,tc.y,tc.z,1-t));
        nvg::TextBox(m_pos.x,m_pos.y + m_size.y *.5f + dv * t ,m_size.x,tsign + Time::Format(Math::Abs(lastSplit)));

        if(shadow){
            nvg::FillColor(vec4(0,0,0,t));
            nvg::TextBox(m_pos.x + offset,m_pos.y + offset + m_size.y *.5f + dv - dist ,m_size.x,lsign +Time::Format(Math::Abs(lastLastSplit)));
        }
		nvg::FillColor(vec4(lc.x,lc.y,lc.z,t));
        nvg::TextBox(m_pos.x,m_pos.y + m_size.y *.5f + dv - dist ,m_size.x,lsign +Time::Format(Math::Abs(lastLastSplit)));
    }

    void OnMoveHud() override {
        SplitHud_position = m_pos;
        SplitHud_size = m_size;
    }

    void OnCpTimesCountChangeEvent(int c)
    {

    }

    void OnCPNewTimeEvent(int c, int time)
    {
        lastLastCpIndex = lastCpIndex;
        lastLastCpTime = lastCpTime;
        lastLastSplit = lastSplit;

        lastCpIndex = c;
        lastCpTime = time;
        auto bt = g_cpDataManager.bestRun.times[c];
        lastSplit = time - g_cpDataManager.bestRun.times[c];
        if (bt == 0)
        {
            lastSplit *= -1;
        }

        // print(Time::Format(lastCpTime) + " | " + Time::Format(lastCpSplit));
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