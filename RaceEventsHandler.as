funcdef void EventCallback(MwFastBuffer<wstring> data);

class RaceEventsHandler : MLHook::HookMLEventsByType {
    
    private dictionary _callbacks = dictionary();

    RaceEventsHandler() {
        super("RaceEventsHandler");
        startnew(CoroutineFunc(this.MainCoro));
    }

    void HookEvent(const string &in eventType, EventCallback@ callback) {
        if( _callbacks.Exists(eventType) ){
            error("RaceEventsHandler: HookEvent failed, event already exists: " + eventType);
            return;
        }

        MLHook::RegisterMLHook(this, eventType);
        @_callbacks[eventType] = callback;
    }

    // used to dispatch events every frame so we dont get frame drops when processing many events at once
    MLHook::PendingEvent@[] pending;
    void MainCoro() {
        
        while (true) {
            yield();
            while (pending.Length > 0) {
                ProcessEvent(pending[pending.Length - 1]);
                pending.RemoveLast();
            }
        }
    }

    void OnEvent(MLHook::PendingEvent@ event) override {
        pending.InsertLast(event);
    }

    int lastCp = 0;
    void ProcessEvent(MLHook::PendingEvent@ event) {
        string eventType = event.type;
        //remove the "MLHook_Event_" prefix
        eventType = eventType.SubStr(13);

        auto value = cast<EventCallback>(_callbacks[eventType]);
        value(event.data);
    }
}