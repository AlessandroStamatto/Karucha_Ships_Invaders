local Japones = {} -- Japones module
----------------------------------------------------------------
-- Kana invaders
-- Alessandro Stamatto & Juvane Nunes
----------------------------------------------------------------

-- Imports
local ResourceManager = require "./code/resource_manager"
local ResourceDefinitions = require "./code/resource_definitions"
local Aux = require "./code/auxiliar"

-- Japonese Alphabet
local kana = {a="あ", i="い", u="う", e="え", o="お", ka="か", ki= "き", ku="く", ke="け", ko="こ", ga="が", gi="ぎ", gu="ぐ", ge="げ", go="ご", 
sa="さ", shi="し", su="す", se="せ", so="そ", za="ざ", ji="じ", zu="ず", ze="ぜ", zo="ぞ", ta="た", chi="ち", tsu="つ", te="て", to="と", 
da="だ", di="ぢ", du="づ", de="で", ["do"]="ど", na="な", ni="に", nu="ぬ", ne="ね", no="の", ha="は", hi="ひ", fu="ふ", he="へ", ho="ほ", 
ba="ば", bi="び", bu="ぶ", be="べ", bo="ぼ", pa="ぱ", pi="ぴ", pu="ぷ", pe="ぺ", po="ぽ", ma="ま", mi="み", mu="む", me="め", mo="も", ya="や", 
yu="ゆ", yo="よ", ra="ら", ri="り", ru="る", re="れ", ro="ろ", wa="わ", wo="を", n="ん",kya="きゃ", kyu="きゅ", kyo="きょ", gya="ぎゃ", gyu="ぎゅ", 
gyo="ぎょ", sha="しゃ", shu="しゅ", sho="しょ", ja="じゃ", ju="じゅ", jo="じょ", cha="ちゃ", chu="ちゅ", cho="ちょ", dya="ぢゃ", dyu="ぢゅ", dyo="ぢょ", 
nya="にゃ", nyu="にゅ", nyo="にょ", hya="ひゃ", hyu="ひゅ", hyo="ひょ", bya="びゃ", byu="びゅ", byo="びょ", pya="ぴゃ", pyu="ぴゅ", pyo="ぴょ", mya="みゃ", 
myu="みゅ", myo="みょ", rya="りゃ", ryu="りゅ", ryo="りょ", sushi="すし", shitake="したけ", sake="さけ", uchikake="うちかけ", hashi="はし", tokusatsu="とくさつ",
kimono="きもの", yukata="ゆかた", hakama="はかま", sashimi="さしみ", temaki="てまき", nori="のり", anime="あにめ", karaoke="からおけ", youkai="ようかい", kamakura="かまくら",
haori= "はおり", geta="げた", nigiri="にぎり", gohan="ごはん", sukiyaki="すきやき", manga="まんが", unkei="うんけい", enkuu="えんくう", gagaku="ががく",
yomesode="よめそで", furisode="ふりそで", irosode="いろそで", teriyaki="てりやき", shimeji="しめじ", origami="おりがみ", heion="へいあん", sudoku="すどく", yakuza="やくざ",
obi="おび", tabi="たび", jikatabi="じかたび", wasabi= "わさび", yakisoba="やきそば", tenpura="てんぷら", ikebana="いけばな", kabuki="かぶき", bugaku="ぶがく", samurai="さむらい",
iromuji="いろむじ",  juunihitoe="じゅうにひとえ", shoyo="しょよ", shari="しゃり", ukiyoe="うきよえ", joumon="じょうもん", geisha="げいしゃ", zori="ぞり", ohashori="おはしょり", gyudon="ぎゅどん",
shabushabu="しゃぶしゃぶ",  shodou="しょどう", kyougen="きょうげん", warashi="わらし", kyahan="きゃはん", wagashi="わがし", sakuramochi="さくらもち", shintou="しんとう", onnagata="おんあが",
happi="はっぴ", hippari="しっぱり", korokke="ころっけ", amanattou="あまなっとう", ningyoujoururi="にんぎょうじょうるり", kumadori="くまどり"
}
------- Reverse Table of kana
local rkana = {}
for romanjiKey, valueKana in pairs(kana) do rkana[valueKana] = romanjiKey end
local kanaTable = nil
-------------------------------------------------------------------------------------------------------------------------
-- Kana Levels
local kLevel = {}

bosses = {
          "sushi", "shitake", "sake", 
          "uchikake", "hashi", "tokusatsu",
          "kimono", "yukata", "hakama", "sashimi",
          "temaki", "nori", "anime", "karaoke",
          "youkai", "kamakura", "haori", "geta",
          "nigiri", "gohan", "sukiyaki", "manga",
          "unkei", "enkuu", "gagaku", "yomesode",
          "furisode", "irosode", "teriyaki", "shimeji",
          "origami", "heion", "sudoku", "yakuza", "obi",
          "tabi", "jikatabi", "wasabi", "yakisoba", "tenpura",
          "ikebana", "kabuki", "bugaku", "samurai", "iromuji",
          "juunihitoe", "shoyo", "shari", "ukiyoe", "joumon",
          "geisha", "zori", "ohashori", "gyudon", "shabushabu",
          "shodou", "kyougen", "warashi", "kyahan", "wagashi",
          "sakuramochi", "shintou", "onnagata", "happi", "hippari",
          "korokke", "amanattou", "ningyoujoururi", "kumadori"
        }
bossTable = {}
for _, boss in ipairs (bosses) do bossTable[ kana[boss] ] = true end

local tableOf = {}
local runningLevel = 1
local fromThisLevel = true

-- Input buffer, will hold keys pressed until enter/spacebar...
local input = ""
-- lastKana will hold nil or the last valid kana typed
local lastKana = nil

function Japones:setupLevel(lvl)
    kanaTable = kLevel[lvl]
    runningLevel = lvl
    --Configure input textbox
    self.jInput = MOAITextBox.new()
    self.jInput:setFont(hudFont)
    self.jInput:setYFlip(true)
    self.jInput:setRect(-200, -75, 200, 75)
    self.jInput:setColor (0, 0, 0)
    self.jInput:setLoc (0, 0)
    self.jInput:setAlignment(MOAITextBox.CENTER_JUSTIFY)
    hudLayer:insertProp (self.jInput)
    input = ""

    kLevel[1] = {"あ", "い", "う", "え", "お"}
    kLevel[2] = {"か", "き", "く", "け", "こ"}
    kLevel[3] = {"さ", "し", "す", "せ", "そ", 
                "すし", "さけ", "したけ"}    
    kLevel[4] = {"た", "ち", "つ", "て", "と"}
    kLevel[5] = {"な", "に", "ぬ", "ね", "の"}
    kLevel[6] = {"は", "ひ", "ふ", "へ", "ほ", 
                "うちかけ", "はし", "とくさつ"}
    kLevel[7] = {"ま", "み", "む", "め", "も"}
    kLevel[8] = {"や", "ゆ", "よ"}
    kLevel[9] = {"ら", "り", "る", "れ", "ろ", "きもの", "ゆかた", "はかま",
                "さしみ", "てまき", "のり", "あにめ", "からおけ", "ようかい", "かまくら"}
    kLevel[10] = {"わ", "を", "る"} 
    kLevel[11] = {"ん", "を", "れ"} 
    kLevel[12] = {"が", "ぎ", "ぐ", "げ", "ご", "はおり", "げた", "にぎり", "ごはん", 
                "すきやき", "まんが", "うんけい", "えんくう", "ががく"}
    kLevel[13] = {"ざ", "じ", "ず", "ぜ", "ぞ"}
    kLevel[14] = {"だ", "ぢ", "づ", "で", "ど"}
    kLevel[15] = {"よめそで", "ふりそで", "いろそで", "てりやき", "しめじ", "おりがみ", 
                "へいあん", "すどく", "やくざ"}
    kLevel[16] = {"ば", "び", "ぶ", "べ", "ぼ"}
    kLevel[17] = {"ぱ", "ぴ", "ぷ", "ぺ", "ぽ"}
    kLevel[18] = {"きゃ", "きゅ", "きょ", "おび", "たび", "じかたび", "わさび", "やきそば", 
                "てんぷら", "いけばな", "かぶき", "ぶがく", "さむらい"}
    kLevel[19] = {"ぎゃ", "ぎゅ", "ぎょ"}
    kLevel[20] = {"しゃ", "しゅ", "しょ"}
    kLevel[21] = {"じゃ", "じゅ", "じょ", "いろむじ", "じゅうにひとえ", "しょよ", "しゃり", "うきよえ",
                 "じょうもん", "げいしゃ"}
    kLevel[22] = {"ちゃ", "ちゅ", "ちょ"}
    kLevel[23] = {"ぢゃ", "ぢゅ", "ぢょ"}
    kLevel[24] = {"にゃ", "にゅ", "にょ", "ぞり", 
                "おはしょり", "ぎゅどん", "しゃぶしゃぶ", "しょどう", "きょうげん"}
    kLevel[25] = {"ひゃ", "ひゅ", "ひょ"}
    kLevel[26] = {"びゃ", "びゅ", "びょ"}
    kLevel[27] = {"ぴゃ", "ぴゅ", "ぴょ", "わらし", "きゃはん", "わがし", "きゃはん", 
                 "わがし", "さくらもち", "しんとう", "おんあが"}
    kLevel[28] = {"みゃ", "みゅ", "みょ"}
    kLevel[29] = {"りゃ", "りゅ", "りょ"}
    kLevel[30] = {"はっぴ", "しっぱり", "ころっけ", "あまなっとう", 
                 "にんぎょうじょうるり", "くまどり"} 
end

function Japones:kanaToText(kana)
    return rkana[kana]
end

-- Returns a random kana, removing it from the table
-- as to never choose a kana already in screen
function Japones:randomKana(prop)
    kanaTable = kLevel[runningLevel]
    if fromThisLevel or runningLevel == 1 or runningLevel % 15 == 0 then
        fromThisLevel = false
        prop:setColor (unpack(colorTable["grey"]))
    else
        kanaTable = kLevel[math.random(1, runningLevel)]
        prop:setColor (unpack(colorTable["red"]))
        fromThisLevel = true
    end

    if #kanaTable == 0 then
        return nil
    end
    -- while #kanaTable == 0 do -- correção temporaria
    --     kanaTable = kLevel[math.random(1, runningLevel)]
    --     print ("level empty, getting kana from another level!")
    -- end

    local ind = math.random(#kanaTable)
    local k = kanaTable[ind]

    if Japones:isBoss(k) and runningLevel % 3 ~= 0 then return nil end

    tableOf[k] = kanaTable
    table.remove(kanaTable, ind)
    return k
end

-- When the kana leaves screen (destroyed) then
-- this function is called to place the kana back
function Japones:addKana(k)
    table.insert(tableOf[k], k)
end

function Japones:getKana()
    local temp = lastKana
    lastKana = nil
    return temp
end

-- Handles the input
function Japones:initialize ()

  MOAIInputMgr.device.keyboard:setCallback(
    function(key,down)
        if down==true then
            -- If a non letter key is pressed
            -- we check if it forms a Kana, and
            -- then resets the input buffer
            if not (key >= 65 and key <= 122) then
                if key == 8 then
                    input = string.sub(input, 0, #input-1)
                    -- print (input)
                elseif key == 27 then
                    paused = true
                else
                    if kana[input] ~= nil then
                        lastKana = (kana[input])
                    end
                    input = ""
                end
            -- Otherwise we accumulate the letter on the input buffer
            else
                if (#input < 12) then
                    input = input .. string.char(tostring(key))
                    input = input:lower()
                end
                
            end
            self:updatejInput(input)
        end
    end
    )
end

function Japones:updatejInput (tx)
    self.jInput:setString(tx)
    --self.jInput:setAlignment(CENTER_JUSTIFY, CENTER_JUSTIFY)
    setWinPos (self.jInput, 500, 800)
end

function Japones:isBoss(kan)
    if (bossTable[kan] == true) then
        return true
    else
        return false
    end
end

return Japones