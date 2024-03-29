namespace ZUtil
{
	class PluginPanel
	{
		string m_name;
		vec2 m_pos;
		vec2 m_size;
		bool m_moveHud;

		PluginPanel(const string &in name, const vec2 &in settingPos, const vec2 &in settingSize){
			m_name = name;
			m_pos = settingPos;
			m_size = settingSize;
		}

		void OnSettingsChanged() {}
		void Render() {}
		void InternalRender() {Render();}
		void Update(float dt) {}
		void RenderInterface() {}
		void OnMoveHud() {}
	}

	class NvgPanel : PluginPanel
	{
		void InternalRender() override
		{
			nvg::Save();
			vec2 screenSize = vec2(Draw::GetWidth(), Draw::GetHeight());
			vec2 pos = m_pos * (screenSize - m_size);
			nvg::Translate(pos.x, pos.y);
			Render();
			nvg::ResetTransform();
			nvg::Restore();
		}

		NvgPanel(const string &in name, const vec2 &in settingPos, const vec2 &in settingSize){
			super(name, settingPos, settingSize);
		}

		void RenderInterface() override
		{
			if (m_moveHud) 
			{
				vec2 screenSize = vec2(Draw::GetWidth(), Draw::GetHeight());
				vec2 pos = m_pos * (screenSize - m_size);

        		UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,.1f));
				UI::SetNextWindowSize(int(m_size.x), int(m_size.y), UI::Cond::Appearing);
				UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::Appearing);

				UI::Begin(Icons::ArrowsAlt + " Locator: " + m_name, m_moveHud, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoSavedSettings);
				auto lastSize = m_size;
				auto lastPos = m_pos;
				m_size = UI::GetWindowSize();
				m_pos = UI::GetWindowPos() / (screenSize - m_size);
				if (lastSize.x != m_size.x 
				 || lastSize.y != m_size.y
				 || lastPos.x != m_pos.x
				 || lastPos.y != m_pos.y)
				{
					OnMoveHud();
				}
				UI::End();
				UI::PopStyleColor();
			}
		}
	}

	class UiPanel : PluginPanel
	{
		UiPanel(const string &in name, const vec2 &in settingPos, const vec2 &in settingSize){
			super(name, settingPos, settingSize);
		}

		void InternalRender() override {
			// UI::SetNextWindowSize(int(m_size.x), int(m_size.y), UI::Cond::Appearing);
			// UI::SetNextWindowPos(int(m_pos.x), int(m_pos.y), UI::Cond::Appearing);
			Render();
		}
	}
}
