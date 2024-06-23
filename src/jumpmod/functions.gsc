// 22-10-2021: new namefix() function
namefix(playername)
{
    if(!isDefined(playername))
        return "";

    allowedchars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!'#[]<>/&()=?+`^~*-_.,;|$@:{}"; // " " (space) moved first as it is more frequent -- "�" removed, unknown what this char is?
    cleanedname = "";

    for(i = 0; i < playername.size; i++) {
        for(z = 0; z < allowedchars.size; z++) {
            if(playername[i] == allowedchars[z]) {
                cleanedname += playername[i];
                break;
            }
        }
    }

    return cleanedname;
}

_newspawn(spawnpoint, recursive)
{
    recursive = (bool)isDefined(recursive);
    if(!recursive)
        newspawn = [];

    for(i = 0; i < 360; i += 36) {
        angle = (0, i, 0);

        trace = bulletTrace(spawnpoint.origin, spawnpoint.origin + maps\mp\_utility::vectorscale(anglesToForward(angle), 48), true, self);
        if(trace["fraction"] == 1 && !positionWouldTelefrag(trace["position"]) && _canspawnat(trace["position"])) {
            _spawnpoint = spawnStruct();
            _spawnpoint.origin = trace["position"];
            _spawnpoint.angles = angle;
            return _spawnpoint;
        }

        if(!recursive) {
            _spawnpoint = spawnStruct();
            _spawnpoint.origin = trace["position"];
            _spawnpoint.angles = angle;
            newspawn[newspawn.size] = _spawnpoint;
        }

        wait 0.05;
    }

    if(!recursive) {
        self iPrintLn("^1ERROR:^7 Bad spawnpoint still finding new, please wait.");
        for(j = 0; j < newspawn.size; j++)
            _newspawn(newspawn[j], true);

        self iPrintLn("^1ERROR:^7 Bad spawnpoint pushing anyways...");
        return spawnpoint; // giving up, push anyways
    }
}

_canspawnat(position)
{
    position = position + (-16, -16, 0); // (-32, -32, 0)
    for(x = 0; x < 32; x++) {
        for(y = 0; y < 32; y++) {
            trace = bulletTrace(position + (x, y, 0), position + (x, y, 72), true, self);
            if(trace["fraction"] != 1)
                return false;
        }
    }

    return true;
}

strTok(text, separator) // From: _mm_mmm.gsc
{
    token = 0;
    tokens = [];

    for(i = 0; i < text.size; i++) {
        if(text[i] != separator) {
            if(!isDefined(tokens[token]))
                tokens[token] = "";

            tokens[token] += text[i];
        } else {
            if(isDefined(tokens[token]))
                token++;
        }
    }

    return tokens;
}

isOnLadder() { // Cheese :D
    if(!isDefined(self) || !isAlive(self) || self.sessionstate != "playing")
        return false;

    if(!self isOnGround() && self getCurrentWeapon() == "none")
        return true;

    return false;
}

getWeaponSlot(weapon)
{
    if(!isDefined(weapon) || weapon == "none")
        return "none";

    if(weapon == self getWeaponSlotWeapon("primary"))
        weaponSlot = "primary";
    else if(weapon == self getWeaponSlotWeapon("primaryb"))
        weaponSlot = "primaryb";
    else if(weapon == self getWeaponSlotWeapon("grenade"))
        weaponSlot = "grenade";
    else
        weaponSlot = "pistol";

    return weaponSlot;
}

array_shuffle(arr)
{
    if(!isDefined(arr))
        return undefined;

    for(i = 0; i < arr.size; i++) {
        _tmp = arr[i]; // Store the current array element in a variable
        rN = randomInt(arr.size); // Generate a random number
        arr[i] = arr[rN]; // Replace the current with the random
        arr[rN] = _tmp; // Replace the random with the current
    }

    return arr;
}

in_array(arr, needle)
{
    if(!isDefined(arr) || !isDefined(needle))
        return undefined;

    for(i = 0; i < arr.size; i++)
        if(arr[i] == needle)
            return true;

    return false;
}

array_remove(arr, str, r) // NEED URGENT OPTIMIZE - If set to true, it will remove previous element aswell.
{
    if(!isDefined(arr) || !isDefined(str))
        return undefined;

    if(!isDefined(r))
        r = false;

    x = 0;
    _tmpa = [];
    for(i = 0; i < arr.size; i++) {
        if(arr[i] != str) {
            _tmpa[x] = arr[i];
            x++;
        } else {
            if(r) {
                _tmpa[x - 1] = undefined;
                x--;
            }
        }
    }

    _tmp = _tmpa;

    if(r) {
        y = 0;
        _tmpb = [];
        for(i = 0; i < _tmpa.size; i++) {
            if(isDefined(_tmpa[i])) {
                _tmpb[y] = _tmpa[i];
                y++;
            }
        }

        _tmp = _tmpb;
    }

    return _tmp;
}

strip(s)
{
    if(s == "")
        return "";

    s2 = "";
    s3 = "";

    i = 0;
    while(i < s.size && s[i] == " ")
        i++;

    if(i == s.size)
        return "";

    for(; i < s.size; i++)
        s2 += s[i];

    i = (s2.size - 1);
    while(s2[i] == " " && i > 0)
        i--;

    for(j = 0; j <= i; j++)
        s3 += s2[j];

    return s3;
}

strTru(str, len, ind)
{
    if(!isDefined(ind))
        ind = " >";

    len = len + ind.size;
    if(str.size <= len)
        return str;

    len = len - ind.size;

    new = "";
    for(i = 0; i < len; i++)
        new = new + str[i];

    return new + ind;
}

playerByNum(num)
{
    if(validate_number(num)) {
        if(((int)num >= 0 || (int)num <= 64)) {
            player = GetEntByNum(num);
            if(isPlayer(player))
                return player;
        }
    }

    return undefined;
}

validate_number(input, isfloat)
{
    if(!isDefined(input))
        return false;

    input += ""; // convert to str

    if(!isDefined(isfloat))
        isfloat = false;

    hasdot = false;
    for(i = 0; i < input.size; i++) {
        switch(input[i]) {
            case "0": case "1": case "2":
            case "3": case "4": case "5":
            case "6": case "7": case "8":
            case "9":
            break;
            case ".": // 0.1..., no need for .1 etc yet... but could be validated by removing i == 0
                if(!isfloat || i == 0 || (i + 1) == input.size || hasdot)
                    return false;

                hasdot = true;
            break;
            case "-": // allow "negative" numbers
                if(i == 0 && input.size > 1) //if(i == 0 && input.size > 1 && input[i] == "-")
                    break;
            default:
                return false;
        }
    }

    return true;
}

mmlog(msg)
{
    logPrintConsole(msg + "\n");
    logPrint(msg + "\n");
}

monotone(str, loop)
{
    if(!isDefined(str))
        return "";

    _str = "";
    for(i = 0; i < str.size; i++) {
        if(str[i] == "^" &&
            ((i + 1) < str.size &&
                (validate_number(str[i + 1]))
            )) {
            i++;
            continue;
        }

        _str += str[i];
    }

    if(!isDefined(loop))
        _str = monotone(_str, true);

    return _str;
}

pmatch(s, p)
{
    if(p.size > s.size)
        return false;

    o = 0;
    while(o <= (s.size - p.size)) {
        for(i = 0; i < p.size; i++)
            if(p[i] != s[i + o])
                break;

        if(i == p.size)
            return true;

        o++;
    }

    return false;
}

array_join(arrTo, arrFrom)
{
    if(!isDefined(arrTo) || !isDefined(arrFrom))
        return undefined;

    for(i = 0; i < arrFrom.size; i++)
        arrTo[arrTo.size] = arrFrom[i];

    return arrTo;
}

getPlayersByName(n1)
{
    a = [];
    p = getOnlinePlayers();
    for(i = 0; i < p.size; i++) {
        n2 = monotone(p[i].name);
        n2 = strip(n2);
        if(n2.size >= n1.size) {
            if(pmatch(tolower(n2), tolower(n1)))
                a[a.size] = p[i];
        }
    }

    return a;
}

getOnlinePlayers() // get all online players, apparently getEntArray doesn't list 999/connecting players
{
    p = [];

    maxclients = GetCvarInt("sv_maxClients");
    if(maxclients < 0 || maxclients > 64)
        return p;

    for(i = 0; i < maxclients; i++) {
        player = GetEntByNum(i);
        if(isDefined(player))
            p[p.size] = player;
    }

    return p;
}

addBotClients()
{
    wait 1;

    for(;;) {
        iNumBots = getCvarInt("scr_numbots");
        if(iNumBots > 0)
            break;
        wait 1;
    }

    for(i = 0; i < iNumBots; i++) {
        bot = addtestclient();
        if(isPlayer(bot))
            bot.isbot = true;
        wait 0.25;
    }
}

aAn(word, upper)
{
    if(word.size < 1)
        return "";

    upper = (bool)isDefined(upper);
    switch(word[0]) {
        case "a": case "e": case "i": case "o": case "u":
        case "A": case "E": case "I": case "O": case "U":
            if(upper)
                return "An";
            return "an";
    }

    if(upper)
        return "A";
    return "a";
}

vectorScale(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}

// Spawn an object and attach a sound to it, POWERSERVER
PlaySoundAtLocation(sound, location, iTime)
{
    org = spawn("script_model", location);
    wait 0.05;
    org show();
    org playSound(sound);
    wait iTime;
    org delete();
    return;
}

numdigits(num)
{
    return (num + "").size;
}