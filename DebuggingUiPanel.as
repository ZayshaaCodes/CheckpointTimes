
// [Setting category="General" name="Debugging"]
// bool Setting_General_Debugging = false;

auto base = Dev::BaseAddress();
auto baseEnd = Dev::BaseAddressEnd();

class DebuggingUiPanel : ZUtil::UiPanel
{
    
    DebuggingUiPanel()
    {
        super("Debugging", vec2(10,500), vec2(400,800));
        print(Text::FormatPointer(base));
        print(Text::FormatPointer(baseEnd));
        print(Text::FormatPointer(baseEnd - base));

        
    }

    void OnSettingsChanged() {}



    string input = "CGamePlayground";
    void Render() 
    {
        // if (!Setting_General_Debugging) return;
        UI::Begin("DebuggingUiPanel"); 
        

        if (UI::Button("Write Pointer Tree"))
        {

            auto app = GetApp();
            auto pg = cast<CGameCtnApp>(app).CurrentPlayground;
            auto ar = cast<CSmArenaClient>(pg).Arena;
            auto ply = ar.Players[0];

            array<CMwNod@> scannedNods = {app, pg, ar, ply, cast<CGamePlayground>(pg).GameTerminals[0].ControlledPlayer, cast<CGamePlayground>(pg).GameTerminals[0]};
            for (uint n = 0; n < scannedNods.Length; n++)
            {          
                auto nod= scannedNods[n];

                auto type = Reflection::TypeOf(nod);
                auto path =  IO::FromDataFolder("\\ptrs\\" + type.Name + ".ptrs");
                
                string s = "";
                do
                {                
                    auto members = type.Members;

                    print("[" + type.Name + "]");
                    s += "[" + type.Name + "]" + "\n";
                    for (uint i = 0; i < members.Length; i++)
                    {
                        auto member = members[i];
                        // auto memberType = Reflection::GetType(member.ID);
                        // print(tostring(member.Offset));
                        if (member.Offset != 65535)
                        {
                            auto val = Dev::GetOffsetUint64(nod, member.Offset);
                            if (val != 0 && (val - base) > (baseEnd - base))
                            {
                                // auto nod = Dev::GetOffsetNod(app, member.Offset);
                                // auto mtype = Reflection::TypeOf(nod);
                                auto mi = "   " + Text::FormatPointer(member.Offset).SubStr(14,4) + " | " + Text::FormatPointer(val) +  " : " + member.Name;
                                print(mi);
                                s += mi + "\n";
                            }
                        }
                    }   
                    @type = type.BaseType;
                } while(type !is null);


                IO::File f(path,IO::FileMode::Write);
                f.Write(s);
                f.Close();
            }

        }

        input = UI::InputText("className", input);
        UI::BeginChild("List");
        if (g_gameState.hasPlayer)
        {
            
            auto classInfo = Reflection::GetType(input);
            if (classInfo is null) 
            {
                UI::Text("No Class Info");
                UI::EndChild();
                UI::End();
                return;
            }

            auto members = classInfo.Members;
            UI::Text("Members: " + members.Length);
            for (uint i = 0; i < members.Length; i++)
            {
                if (members[i].Offset == 65535) continue;
                UI::Text(tostring(members[i].Name));
                UI::SetNextItemWidth(150);
                UI::InputText("off" + i, Text::FormatPointer(uint64(members[i].Offset)).SubStr(10));
                UI::SetNextItemWidth(150);
                UI::InputText("val" + i, Text::FormatPointer(Dev::GetOffsetUint64(GetApp().CurrentPlayground, members[i].Offset)));
                UI::Separator();
            }


        }
        UI::EndChild();
        
        UI::PopFont();

        UI::End();
        
    }

    void Update(float dt) {
        
        if(g_gameState.hasPlayground){
            auto ai = g_gameState.playground.ArenaInterface;
            auto ob = Dev::GetOffsetUint64(ai, 0xd0);
            auto v = Dev::ReadUInt16(ob + 0x30);
            if (v != 1)
            {
                // Dev::Write(ob + 0x30, 1);
            }
            // print(v);
        }

    }
}

// uint64 GetAddyObjMember(CMwNod@ nod, const string&in memberName)
// {
//     if (classInfo !is null)
//     {    
//         classInfo.GetM
//     }
// }
