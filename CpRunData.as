class CpRunData 
{
    string playerName = "";
    array<int> times(0);
    array<float> speeds(0);
    array<int> resets(0);
    bool wasPB =false;

    CpRunData(int count){
        Resize(count);
    }

    void SetAllTimes(array<int> newTimes){
        //upper bounds check
        if (newTimes.Length != times.Length) return;
        

        for (uint i = 0; i < times.Length; i++)
        {
            times[i] = newTimes[i];
        }
    }

    void FromJsonObject(Json::Value obj, int CpCount)
    {
        auto jsonTimes = obj["times"];
        auto jsonResets = obj["resets"];
        // times.Resize(jsonTimes.Length);
        // resets.Resize(jsonResets.Length);

        uint loopCount = Math::Min(jsonTimes.Length, CpCount);

        for (uint i = 0; i < loopCount; i++)
        {
            times[i] = jsonTimes[i];
        }

        for (uint i = 0; i < loopCount; i++)
        {
            resets[i] = jsonResets[i];
        }

        if (obj.HasKey("speeds"))
        {
            auto jsonSpeeds = obj["speeds"];

            for (uint i = 0; i < loopCount; i++)
            {   
                speeds[i] = jsonSpeeds[i];
            }
        }

        // position = obj["position"];
        wasPB = obj["wasPB"];
    }

    Json::Value ToJsonObject()
    {
        auto obj = Json::Object();

        auto timesArr = Json::Array();
        auto resetsArr = Json::Array();
        auto speedsArr = Json::Array();

        for (uint i = 0; i < times.Length; i++)
        {
            timesArr.Add(times[i]);    
            resetsArr.Add(resets[i]);    
            speedsArr.Add(speeds[i]);    
        }

        obj["times"] = timesArr;
        obj["resets"] = resetsArr;
        obj["speeds"] = speedsArr;

        obj["wasPB"] = Json::Value(wasPB);

        return obj;
    }

    void Resize(int newSize) 
    {    
        times.Resize(newSize);
        resets.Resize(newSize);
        speeds.Resize(newSize);
    }

    void ClearAll(){
        ClearArray(times);
        ClearArray(resets);
        ClearArray(speeds);
        wasPB = false;
    }
    
    void ClearArray(array<int>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }

    void ClearArray(array<float>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }
    
    void To(CpRunData@ to){
        for (uint i = 0; i < times.Length; i++)
        {
            to.times[i] = times[i];
            to.resets[i] = resets[i];
            to.speeds[i] = speeds[i];
        }
        to.wasPB = wasPB;
    }
}