--Game Global Variables
-- Contains all the constants used, like positions, colors RGB values and file paths.
-- Cointains all global variables, like game graphical layers and resource definitions.
-- Contains the only 2 global functions, they set game elements window position. 

-- World and screen measures
WorldX = 1024
WorldY = 768
ScreenX = WorldX
ScreenY = WorldY
TOP = WorldY / 2
BOT = -TOP
RIGHT = WorldX / 2
LEFT = -RIGHT

-- Resource variables
barWidth = 256
--laserHeight = 107 + 50 -- 24 is a Y center offset
kanjiFont = nil
hudFont = nil
numbersFont = nil
textFont = nil

--Layers
backgroundLayer = nil
midLayer = nil
hudLayer = nil

-- Colors
colorTable = {
  ["red"] = {0.75,0,0},
  ["blue"] = {0,0,0.75},
  ["green"] = {0,0.75,0},
  ["black"] = {0,0,0},  
  ["grey"] = {0.28235,0.28627,0.28627}, 
}

paused = false

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

achieved = { 
          karucha_newbie=0, hiragana_newbie=0, karucha_beginner=0,
          karucha_reckless=0, karucha_cautious=0, karucha_on_the_go=0,
          hiragana_on_the_go=0, hiragana_warrior=0, hiragana_lover=0,
          karucha_master=0, karucha_sensei=0, goujon_master=0,
          handakuten_sensei=0
        }

gameSave = {
          ["easy"] = 1, ["medium"] = 1, ["hard"] = 1, ["selected"] = "medium",
          ["sound"] = 1,
}

soundStopped = false

hitpath = ''
if seeHitbox 
    then hitpath = './images/seeHitbox.png'
    else hitpath = './images/hitbox.png'
end 
------------------------------------------------
-- Resources for Kana Invaders game
------------------------------------------------
resource_definitions = {

  hud = {
    type = "image", 
    fileName = './images/level/hud.png', 
    width = 1024, height = 1024,
    position = {0, 0}
  },
 
  manha = {
    type = "image", 
    fileName = './images/level/manha.png', 
    width = 1024, height = 1024,
    position = {0, 0}
  },

  tarde = {
    type = "image", 
    fileName = './images/level/tarde.png', 
    width = 1024, height = 1024,
    position = {0, 0}
  },

  noite = {
    type = "image", 
    fileName = './images/level/noite.png', 
    width = 1024, height = 1024,
    position = {0, 0}
  },

  barra = {
    type = "image", 
    fileName = './images/level/barra.png', 
    width = 256, height = 32,
    position = {229, 11},
  },

  raio = {
    type = "image", 
    fileName = './images/effects/raio.png', 
    width = 256, height = 1024,
  },

  capturaNave = {
    type = "image", 
    fileName = './images/effects/capturaNave.png', 
    width = 256, height = 256,
  },

  cannon = {
    type = "image", 
    fileName = './images/elements/cannon.png', 
    width = 64, height = 64,
    position = {465, 649},
  },

  ship = {
    type = "image", 
    fileName = './images/elements/nave.png', 
    width = 256, height = 256,
  },

  paraquedas = {
    type = "image", 
    fileName = './images/elements/paraquedas.png', 
    width = 512, height = 512,
  },

  bonus = {
    type = "image", 
    fileName = './images/effects/bonus.png', 
    width = 64, height = 64,
    position = {363, 23},
  },

  nextLevel = {
    type = "image", 
    fileName = './images/menu/nextLevel.png', 
    width = 256, height = 64,
    position = {750, 70},
  },

  replayLevel = {
    type = "image", 
    fileName = './images/menu/replayLevel.png', 
    width = 256, height = 64,
    position = {28, 70},
  },
  
  kanjiFont = {
    type = "font",
    fileName = './fonts/jap.ttc',
    glyphs = "あいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもやゆよらりるれろわをんゃゅょ" ..
             "♥!–❅★☁" ..
             "0123456789" ..
             "abcdefghijklmnopqrstuvwxyz" ..
             "ABCDEFGHIJKLMNOPQRSTUVXWYZ!. ",
    fontSize = 16,
    dpi = 160
  },

  hudFont = {
    type = "font",
    fileName = './fonts/menu&barra_arial.ttf',
    glyphs = "abcdefghijklmnopqrstuvwxyz" ..
             "ABCDEFGHIJKLMNOPQRSTUVXWYZ!. ",
    fontSize = 14,
    dpi = 160
  },

  numbersFont = {
    type = "font",
    fileName = './fonts/numeros_mool.ttf',
    glyphs = "0123456789",
    fontSize = 24,
    dpi = 160
  },

  textFont = {
    type = "font",
    fileName = './fonts/texto_janda.ttf',
    glyphs = "0123456789" ..
             "abcdefghijklmnopqrstuvwxyz" ..
             "ABCDEFGHIJKLMNOPQRSTUVXWYZ!. ",
    fontSize = 14,
    dpi = 160
  },

  levelTheme = {
    type = "sound",
    fileName = "./sounds/levelTheme.mp3",
    loop = true,
    volume = 0.7
  },

  shotSound = {
    type = "sound",
    fileName = "./sounds/shot.mp3",
    loop = false,
    volume = 1
  },

  explosionSound = {
    type = "sound",
    fileName = "./sounds/explosion.mp3",
    loop = false,
    volume = 1
  },

  bonusSound = {
    type = "sound",
    fileName = "./sounds/bonus.mp3",
    loop = false,
    volume = 1
  },

  -- Menu:

  menuBackground = {
    type = "image", 
    fileName = './images/menu/menuBackground.png', 
    width = 1024, height = 1024,
  },

  about = {
    type = "image", 
    fileName = './images/menu/about.png',  
    width = 1024, height = 1024,
  },

  top10 = {
    type = "image", 
    fileName = './images/menu/top10.png',  
    width = 1024, height = 1024,
  },

  levels = {
    type = "image", 
    fileName = './images/menu/levels.png',  
    width = 1024, height = 1024,
  },

  levelShip = {
    type = "image", 
    fileName = './images/menu/levelShip.png',  
    width = 46, height = 28
  },

  selectedGreen = {
    type = "image", 
    fileName = './images/menu/selectedGreen.png',  
    width = 32, height = 32
  },

  selectedRed = {
    type = "image", 
    fileName = './images/menu/selectedRed.png',  
    width = 36, height = 36
  },

  unselected = {
    type = "image", 
    fileName = './images/menu/unselected.png',  
    width = 32, height = 32
  },

  configurations = {
    type = "image", 
    fileName = './images/menu/configurations.png',  
    width = 1024, height = 1024,
  },

  achievements = {
    type = "image", 
    fileName = './images/menu/achievements.png',  
    width = 1024, height = 1024,
  },

  help = {
    type = "image", 
    fileName = './images/menu/help.png',  
    width = 1024, height = 1024,
  },

  hitbox = {
    type = "image", 
    fileName = hitpath, 
    width = 512, height = 48,
  },

  backgroundMusic = {
    type = "sound",
    fileName = "./sounds/menuTheme.mp3",
    loop = true,
    volume = 0.76
  },

  hud = {
    type = "image", 
    fileName = './images/level/hud.png', 
    width = 1024, height = 1024,
    position = {0, 0}
  },
}

for i=1, 6 do
  resource_definitions["1_" .. tostring(i)] = 
  {
    type = "image", 
    fileName = './images/story/1_' .. tostring(i) .. '.png', 
    width = 1024, height = 1024,
  }
end

for _ , boss in ipairs (bosses) do
  resource_definitions[boss] = {
    type = "image", 
    fileName = './images/bosses/' .. boss .. '.png', 
    width = 96, height = 96,
  }
end

function setDefaultPos (prop, definitionName, optionalZ)
  local xwin, ywin = unpack (resource_definitions[definitionName].position)
  local halfWidth = resource_definitions[definitionName].width / 2
  local halfHeight = resource_definitions[definitionName].height / 2
  xwin = xwin + halfWidth
  ywin = ywin + halfHeight
  local x, y = hudLayer:wndToWorld (xwin, ywin)
  if optionalZ == nil then
    prop:setLoc (x, y)
  else
    prop:setLoc (x, y, z)
  end
  prop.defaultX = x
  prop.defaultY = y
end

function setWinPos (prop, xwin, ywin)
  local x, y = hudLayer:wndToWorld (xwin, ywin)
  prop:setLoc (x, y)
end