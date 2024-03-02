namespace ZUtil
{
    
    string GetTrimmedMapName (CGameCtnChallenge@ map){
        // null checks
        if (map is null) return "";
        if (map.MapInfo is null) return "";
        if (map.MapInfo.NameForUi == "") return "";

        auto s = Regex::Replace(map.MapInfo.NameForUi, """\$[0-9a-fA-F]{3}""", "");
        s = Regex::Replace(s, """[\|\"\']""", "");
        return Regex::Replace(s, """\$[wnmoitsgzbWNMOITSGZB]""", "");
    }

    CSmPlayer@ GetLocalPlayer(CGamePlayground@ playground)
    {   
        if(playground is null) return null;
        if (playground.GameTerminals.Length < 1) return null;
        return cast<CSmPlayer>(playground.GameTerminals[0].ControlledPlayer);
    }

#if TMNEXT
    CSmPlayer@ GetViewingPlayer()
    {
        auto playground = GetApp().CurrentPlayground;
        if (playground is null || playground.GameTerminals.Length != 1) {
            return null;
        }
        return cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
    }
#elif TURBO
    CGameMobil@ GetViewingPlayer()
    {
        auto playground = cast<CTrackManiaRace>(GetApp().CurrentPlayground);
        if (playground is null) {
            return null;
        }
        return playground.LocalPlayerMobil;
    }
#elif MP4
    CGamePlayer@ GetViewingPlayer()
    {
        auto playground = GetApp().CurrentPlayground;
        if (playground is null || playground.GameTerminals.Length != 1) {
            return null;
        }
        return playground.GameTerminals[0].GUIPlayer;
    }
#endif

    uint GetEffectiveCpCount(CSmArenaClient@ playground){
        if (playground !is null)
        {
            return GetEffectiveCpCount(playground.Map, cast<CSmArena>(playground.Arena));
        }
        return 0;
    }

    uint GetEffectiveCpCount( CGameCtnChallenge@ map, CSmArena@ arena)
    {    
        if (arena is null || map is null) return 0;

        auto landmarks = arena.MapLandmarks;

        if (landmarks.Length == 0) return 0;

        if (map.MapType == "TrackMania\\TM_Royal") return 5;

        auto lapCount = map.TMObjective_IsLapRace ? map.TMObjective_NbLaps : uint(1);
        array<int> orders(0);
        uint _cpCount = 1; // starting at 1 because there is always a finish

        // if a cp has an order > 0, it may be a linked CP, so we increment that index and count them later
        for (uint i = 0; i < landmarks.Length; i++)
        {
            auto lm = landmarks[i];

            auto tag = lm.Tag;
            if (lm.Tag == "Checkpoint" || lm.Tag == "LinkedCheckpoint" || lm.Tag == "")
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
        // print("cps: " + _cpCount * lapCount);
        return _cpCount * lapCount;

    }

    
    string FormatTime(int val, bool forceSign) 
    {
        auto formattedString = Time::Format(Math::Abs(val));
        if (val < 0) {
            return "-" + formattedString;
        }
        else if (val > 0 && forceSign) {
            return "+" + formattedString;
        } else 
        {
            return formattedString;
        }
    }

    string FormatInt(int val, bool forceSign) 
    {
        if (val > 0 && forceSign) {
            return "+" + val;
        }
        return "" + val;
    }
}