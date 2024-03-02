vec3 color_Light = vec3(1,1,1);

vec3 color_Pos = vec3(.2f,.8f,.2f);
vec3 color_Neg = vec3(.8f,.2f,.2f);

//will convert to "\\$FFF" format, 1 = F
array<string> charTable = { "0", "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "A" , "B" , "C" , "D" , "E" , "F" };
string ToHexString(vec3 color)
{
    string hex = "\\$";
    int r = int(color.x * 15);
    hex += charTable[r];
    int g = int(color.y * 15);
    hex += charTable[g];
    int b = int(color.z * 15);
    hex += charTable[b];
    return hex;
}