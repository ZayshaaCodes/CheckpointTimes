class CpDataContext{
    CpRunData@ current;
    CpRunData@ last;
    CpRunData@ best;
    CpRunData@ target;

    int curCp = 0;

    CpDataContext(){
        @current = CpRunData(1);
        @last = CpRunData(1);
        @best = CpRunData(1);
        @target = CpRunData(1);
    }


    void CopyFromTo(CpRunData@ a, CpRunData@ b){
        for(uint i = 0; i < a.times.Length; i++){
            b.times[i] = a.times[i];
            b.speeds[i] = a.speeds[i];
            b.resets[i] = a.resets[i];
        }
    }

    int GetPbSplit (const uint &in cp){
        return current.times[cp] - best.times[cp];
    }

    int GetLastToPbSplit (const uint &in cp){
        return last.times[cp] - best.times[cp];
    }

    int GetTargetSplit (const uint &in cp){
        return current.times[cp] - target.times[cp];
    }

    int GetPbSplitSpeed (const uint &in cp){
        return int(current.speeds[cp] - best.speeds[cp]);
    }
    
    void Resize(const uint &in size){
        current.Resize(size);
        last.Resize(size);
        best.Resize(size);
        target.Resize(size);
    }

        void Cycle(){
        //if currents last value is better than best last value, set best to current also
        // best = 0 : cur -> best
        @last = @current;
        @current = CpRunData(current.times.Length + 1);
        curCp = 0;
    }
}
