namespace ZUtil
{
    funcdef void MapLoadEvent(CGameCtnChallenge@, CSmArena@);
    funcdef void PlayerLoadEvent(CSmPlayer@);

    interface IHandleGameStateEvents{
        void OnMapLoaded(CGameCtnChallenge@, CSmArena@);
        void OnPlayerLoaded(CSmPlayer@);
    }

    class GameState
    {
        CSmPlayer@ player;
        bool hasPlayer;

        CSmArenaClient@ playground;
        CSmArena@ arena;
        bool hasPlayground;

        CGameCtnChallenge@ map;
        bool hasMap;
        bool isRoyalMap;
        string trimmedMapName;
        string coloredMapName;

        array<MapLoadEvent@> MapLoadEventCallbacks();
        array<PlayerLoadEvent@> PlayerLoadEventCallbacks();

        void RegisterMapLoadCallback(MapLoadEvent@ funcPtr){
            MapLoadEventCallbacks.InsertLast(funcPtr);
        }

        void RegisterPlayerLoadCallback(PlayerLoadEvent@ funcPtr){
            PlayerLoadEventCallbacks.InsertLast(funcPtr);
        }

        void RegisterLoadCallbacks(IHandleGameStateEvents@ iObj){
            MapLoadEventCallbacks.InsertLast(MapLoadEvent(iObj.OnMapLoaded));
            PlayerLoadEventCallbacks.InsertLast(PlayerLoadEvent(iObj.OnPlayerLoaded));
        }

        void Update(float dt){
            @playground = cast<CSmArenaClient>(g_app.CurrentPlayground);
            auto playgroundIsNull = playground is null;

            // Playground
            if (!hasPlayground && !playgroundIsNull)
            {
                print("");
                print("found playground: " + dt);
            } else if (hasPlayground && playgroundIsNull)
            {
                print("exit to menu: " + dt);
            }
            hasPlayground = !playgroundIsNull;

            if (hasPlayground)
            {
                // Map
                @map = playground.Map;
                @arena = playground.Arena;
                auto mapIsNull = map is null;
                if (!hasMap && !mapIsNull)
                {
                    hasMap = true;
                    isRoyalMap = map.MapType == "TrackMania\\TM_Royal";
                    trimmedMapName = Regex::Replace(map.MapInfo.NameForUi, """(\$[wnmoitsgzbWNMOITSGZB]|\$[0-9a-fA-F]{3})""", "");
                    
                    coloredMapName = playground.Map.MapInfo.NameForUi;
                    
                    
                    coloredMapName = Regex::Replace(coloredMapName, "\\$0[^0-9A-Fa-f]", "\\$");
                    coloredMapName = Regex::Replace(coloredMapName, "\\$[wnoitsgzbWNMOITSGZB]", "");
                    coloredMapName = Regex::Replace(coloredMapName, "\\$", "\\$");

                    print("found " + (isRoyalMap ? "royal" : "race") + " map: " + trimmedMapName);
                    for (uint i = 0; i < MapLoadEventCallbacks.Length ; i++)
                        MapLoadEventCallbacks[i](map, arena);
                }
                hasMap = !mapIsNull;
               
                // Player
                @player = ZUtil::GetLocalPlayer(playground);
                auto playerIsNull = !hasPlayground || player is null;
                if (!hasPlayer && !playerIsNull )
                {
                    hasPlayer = true;
                    print("found player: " + dt);
                    for (uint i = 0; i < PlayerLoadEventCallbacks.Length ; i++)
                        PlayerLoadEventCallbacks[i](player);
                }
                hasPlayer = hasPlayground && player !is null;
            } else {
                @player = null;
                @arena = null;
                @map = null;
                hasMap = false;
                hasPlayer = false;
            }
        }
    }
}