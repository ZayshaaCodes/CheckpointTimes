class CpRunData 
{
    array<int> times(0);
    array<float> speeds(0);
    array<int> resets(0);

    int position = 0;
    bool wasPB =false;

    void Clear(){
        for (uint i = 0; i < times.Length; i++)
        {
            times[i] = 0;
            resets[i] = 0;
            speeds[i] = 0;
            position = 0;
            wasPB = false;
        }
    }

    void FromJsonObject(Json::Value obj, int CpCount)
    {
        auto jsonTimes = obj["times"];
        auto jsonResets = obj["resets"];

        // times.Resize(jsonTimes.Length);
        // resets.Resize(jsonResets.Length);

        position = 0;

        uint loopCount = Math::Min(jsonTimes.Length, CpCount);

        for (uint i = 0; i < loopCount; i++)
        {
            times[i] = jsonTimes[i];
            if (times[i] != 0)
                position++;
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
        // print(position);
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

        obj["position"] = Json::Value(position);
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
        Clear(times);
        Clear(resets);
        Clear(speeds);
        position = 0;
        wasPB = false;
    }
    
    void Clear(array<int>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }

    void Clear(array<float>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }
    
}