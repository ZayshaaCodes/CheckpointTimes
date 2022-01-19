class CpRunData 
{
    array<int> times(0);
    array<int> resets(0);

    int position = 0;
    bool wasPB =false;

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