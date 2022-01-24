class CpRunData 
{
    array<int> times(0);
    array<int> resets(0);

    int position = 0;
    bool wasPB =false;

    void Clear(){
        for (uint i = 0; i < times.Length; i++)
        {
            times[i] = 0;
            resets[i] = 0;
            position = 0;
            wasPB = false;
        }
    }

    void FromJsonObject(Json::Value obj)
    {
        auto jsonTimes = obj["times"];
        auto jsonResets = obj["resets"];

        times.Resize(jsonTimes.Length);
        resets.Resize(jsonResets.Length);

        position = 0;

        for (uint i = 0; i < jsonTimes.Length; i++)
        {
            times[i] = jsonTimes[i];
            if (times[i] != 0)
                position++;
        }

        for (uint i = 0; i < jsonResets.Length; i++)
        {
            resets[i] = jsonResets[i];
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

        for (uint i = 0; i < times.Length; i++)
        {
            timesArr.Add(times[i]);    
            resetsArr.Add(resets[i]);    
        }

        obj["times"] = timesArr;
        obj["resets"] = resetsArr;

        obj["position"] = Json::Value(position);
        obj["wasPB"] = Json::Value(wasPB);

        return obj;
    }

    void Resize(int newSize) 
    {    
            times.Resize(newSize);
            resets.Resize(newSize);
    }

    void ClearAll(){
        Clear(times);
        Clear(resets);
        position = 0;
        wasPB = false;
    }
    
    void Clear(array<int>@ arr){
        for (uint i = 0; i < arr.Length; i++) arr[i] = 0;
    }
    
}