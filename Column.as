
// funcdef string GetDisplayString(CpDataManager@);
funcdef int GetDisplayValue(CpDataContext@, int);

class Column
{
    string id;
    bool enabled;
    string name;
    int width = 100;

    bool darkenAfterCurrent = true;
    bool formatTime = false;
    bool lastCpFlag = false;
    
    string stylePrefix = "\\$s";

    bool signColors = false;
    bool forceSign = false;
    vec3 baseColor = vec3(1, 1, 1);
    vec3 negColor = vec3(1, 0, 0);
    vec3 posColor = vec3(0, 1, 0);

    GetDisplayValue@ displayValue;
    GetDisplayValue@ displayValueLast;

    Column(const string &in id, const string &in name, int width, bool enabled = true)
    {
        this.id = id;
        this.name = name;
        this.width = width;
        this.enabled = enabled;
    }

    // cpdata: the data context
    // i: the index of the row
    string GetDisplay(CpDataContext@ cpData, int rowIndex)
    { 
        int curCp = cpData.curCp;
        int value = 0;

        if(displayValue is null) return "nofunc";

        if (curCp <= rowIndex && displayValueLast !is null)
            value = displayValueLast(cpData, rowIndex);
        else
            value = displayValue(cpData, rowIndex);
        
        string valueString = "";
        if(formatTime)
            valueString = ZUtil::FormatTime(value, forceSign);
        else
            valueString = ZUtil::FormatInt(value, forceSign);

        string prefix = stylePrefix;
        vec3  color = baseColor;
        if(signColors)
        {
            if (value < 0)
                color = posColor;
            else if (value == 0)
                color = baseColor;
            else 
                color = negColor;
        }

        if (darkenAfterCurrent && curCp <= rowIndex)
        {
            color = color * .3;
        }

        if (lastCpFlag && rowIndex == g_mapInfo.numCps - 1)
        {
            valueString = Icons::FlagCheckered;
        }
      
        return prefix + ToHexString(color) + valueString;
    }
}
