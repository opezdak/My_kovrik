display.setDefault("background",0,0.05,0.1)

textmultiplier = system.getPreference("app","textmultiplier","number") or 1
system.setPreferences("app",{textmultiplier=textmultiplier})
font = native.systemFont
cx = display.contentCenterX
cy = display.contentCenterY
sx = display.contentWidth
sy = display.contentHeight

local json = require("json")
local physics = require("physics")
physics.start()

for i = 0, 38 do
	display.newRect(550,i*50,sx,4):setFillColor(0.1,0.15,0.2)
end
for i = 0, 22 do
	display.newRect(i*50,950,4,sy):setFillColor(0.15,0.2,0.25)
end

local unlocked = json.decode(system.getPreference("app","unlocks") or json.encode({1}))
system.setPreferences("app",{unlocks=json.encode(unlocked)})
local skin = system.getPreference("app","savedskin","number") or 1
system.setPreferences("app",{savedskin=skin})
local player = display.newGroup()
player.x, player.y = 125, 950
local playerfire = display.newImage("Photos/fire.png",0,-35)
playerfire.fill.effect = "filter.blurHorizontal"
playerfire.alpha = 0
player:insert(playerfire)
local playerskins = {
	{"Photos/wavedefault.png",45,"Базовая волна","Открыта по умолчанию",1,{0,1,1},2},
	{"Photos/wave.png",40,"Улыбашка","Открывается за 75 очков",1,{0.2,0,1},2.3},
	{"Photos/wavepro.png",45,"Жирная волна","Открывается за 150 очков",1,{0.8,0,1},2},
	{"Photos/wavehitbox.png",0,"Точный хитбокс","Открывается за 225 очков",1.2,{1,0,0.7},2},
	{"Photos/wavea.png",40,"Волна абдула","Открывается с шансом 5% при старте",1.1,{1},2},
	{"Photos/wavep.png",40,"Волна пурсара","Открывается при смерти на 0 очках",1.1,{1},2},
	{"Photos/wavek.png",40,"Волна кимыра","Открывается при смерти об границу карты",0.95,{1},2},
	{"Photos/wavead.png",40,"Волна адского","Открывается при наличии 3 и более волн",1.1,{1},2},
	{"Photos/wave67.png",0,"Смехуятинка","Открывается при смерти на любом мемном числе",0.38,{1},2},
	{"Photos/wavecursed.png",90,"Острая волна","Открывается при смерти об фиолетовое глитч препятствие",1,{1,0.8,1},2},
}
for i, ii in ipairs(playerskins) do
	table.insert(ii,1,display.newImage(ii[1]))
	ii[1].alpha = 0
	ii[1].fill.effect = "filter.hue"
	player:insert(ii[1])
end
local playerhitbox = display.newRect(125,950,50,50)
playerhitbox.alpha = 0
physics.addBody(playerhitbox, "dynamic", {isSensor = true})
playerhitbox.gravityScale = 0
playerhitbox.isFixedRotation = true
playerhitbox.isSleepingAllowed = false
playerhitbox.ID = "player"

for i = 0, 1 do
	local border = display.newRect(cx,i*2200-150,sx,300)
	border.alpha = 0
	physics.addBody(border,"static", {isSensor = true})
	border.ID = "sideshazard"
end

local size = {}
local hazards = {}

local function spawnhazards()
	size = {{700},{700}}
	local what1 = 700
	local what2 = 700
	for _ = 1, 10 do
		local rand = math.random(-1,1)
		if rand < 0 then
			if what2 > 100 then
				what1 = what1 + 100
				what2 = what2 - 100
			end
		elseif rand > 0 then
			if what1 > 100 then
				what1 = what1 - 100
				what2 = what2 + 100
			end
		end
		table.insert(size[1],what1)
		table.insert(size[2],what2)
	end
	
	hazards = {}
	for i = 0, (#size[1]+#size[2])/2-1 do
		table.insert(hazards,display.newRect(150+i*350,50+size[1][i+1]/2,150,size[1][i+1]))
		table.insert(hazards,display.newRect(150+i*350,1850-size[2][i+1]/2,150,size[2][i+1]))
	end
	for _, ii in ipairs(hazards) do
		physics.addBody(ii,"static", {isSensor = true})
		ii.ID = "hazard"
	end
	player:toFront()
end

local playermove = false 
local fallspeed = 0
local speed = 0
local function move(event)
	for i = 1, #hazards, 2 do
		local what1 = hazards[i]
		local what2 = hazards[i+1]
		
		if what1 and what2 then
			what1.x = what1.x - speed
			what2.x = what2.x - speed
		
			if what1.x <= -300 and what2.x <= -300 then
				local prev = i-2
				if prev < 1 then prev = #hazards - 1 end
				
				what1.x = what1.x + (#hazards/2)*350
				what2.x = what2.x + (#hazards/2)*350
				
				local new1 = hazards[prev].height
				local new2 = hazards[prev+1].height
				
				local rand = math.random(-1,1)
				if rand < 0 then
					if new2 > 100 then
						new1 = new1 + 100
						new2 = new2 - 100
					end
				elseif rand > 0 then
					if new1 > 100 then
						new1 = new1 - 100
						new2 = new2 + 100
					end
				end
				
				physics.removeBody(what1)
				physics.removeBody(what2)
				
				what1.height = new1
				what1.y = 50 + what1.height/2
				
				what2.height = new2
				what2.y = 1850 - what2.height/2
				
				physics.addBody(what1,"static",{isSensor = true})
				physics.addBody(what2,"static",{isSensor = true})
				if math.random(1,500) == 1 then
					what1.ID = "glitchhazard"
					what1:setFillColor(1,0.5+0.5*math.min(1,prepoints/7500),1)
				else
					what1.ID = "hazard"
					what1:setFillColor(1)
				end
				if math.random(1,500) == 1 then
					what2.ID = "glitchhazard"
					what2:setFillColor(1,0.5+0.5*math.min(1,prepoints/7500),1)
				else
					what2.ID = "hazard"
					what2:setFillColor(1)
				end
			end
		end
	end
	
	if fallspeed ~= 0 then
		if playermove then
			player.y = player.y - fallspeed
			playerhitbox.y = playerhitbox.y - fallspeed
			for _, ii in ipairs(playerskins) do
				ii[1].rotation = -ii[3]
			end
		else
			player.y = player.y + fallspeed
			playerhitbox.y = playerhitbox.y + fallspeed
			for _, ii in ipairs(playerskins) do
				ii[1].rotation = ii[3]
			end
		end
	end
end
	
local function playermovefunc(event)
	if event.phase == "began" or event.phase == "moved" then
		playermove = true
	else
		playermove = false
	end
end

local achtlist = {}
local achtdoing = false
local function achievement(unlock,always)
	timer.performWithDelay(100,function()
		for _, i in ipairs(unlocked) do
			if i == unlock and not always then
				return
			end
		end
		if not playerskins[unlock] then
			return
		end
		if achtdoing then
			table.insert(unlocked,unlock)
			system.setPreferences("app",{unlocks=json.encode(unlocked)})
			table.insert(achtlist,unlock)
			return
		end
		achtdoing = true
		local acht = display.newGroup()
		acht.x, acht.y = cx,sy+250
		local box = display.newRoundedRect(acht,0,0,700,400,50)
		box:setFillColor(unpack(playerskins[unlock][7]))
		box.strokeWidth = 15
		local darkcol = {}
		for _, i in ipairs(playerskins[unlock][7]) do
			table.insert(darkcol,i/playerskins[unlock][8])
		end
		box:setStrokeColor(unpack(darkcol))
		local achttext = display.newText(acht,"Новая волна!",0,-132,font,75*textmultiplier)
		achttext:setFillColor(unpack(darkcol))
		local sep = display.newLine(acht,-350,-75,350,-75)
		sep.strokeWidth = 15
		sep:setStrokeColor(unpack(darkcol))
		local sep0 = display.newLine(acht,0,-75,0,200)
		sep0.strokeWidth = 15
		sep0:setStrokeColor(unpack(darkcol))
		local achtname = display.newText(acht,playerskins[unlock][4],-175,8,font,43*textmultiplier)
		achtname:setFillColor(unpack(darkcol))
		local icon = display.newImage(acht,playerskins[unlock][2],-175,88)
		icon.width, icon.height = icon.width*playerskins[unlock][6],icon.height*playerskins[unlock][6]
		icon.fill.effect = "filter.grayscale"
		local desctext = display.newText({parent=acht,text=playerskins[unlock][5],x=175,y=62,width=300,font=font,fontSize=45*textmultiplier,align="center"})
		desctext:setFillColor(unpack(darkcol))
		local move = -50
		local function movie()
			move = move + 2
			if acht and acht.y then
				acht.y = acht.y + move/1.2
				acht:toFront()
			end
		end
		timer.performWithDelay(15,movie,25)
		timer.performWithDelay(375,function()
			timer.performWithDelay(50,function()
				if acht then acht:toFront() end
			end,32)
		end)
		timer.performWithDelay(2000,function()
			timer.performWithDelay(15,movie,25)
			timer.performWithDelay(500,function()
				display.remove(acht)
				if #unlocked >= 3 then achievement(8) end
				achtdoing = false
				if #achtlist ~= 0 then
					achievement(achtlist[1],true)
					table.remove(achtlist,1)
				end
			end)
		end)
		
		table.insert(unlocked,unlock)
		system.setPreferences("app",{unlocks=json.encode(unlocked)})
	end)
end

if not system.getPreference("app","maxpoints","number") then
	system.setPreferences("app",{maxpoints = 0})
end
local gameovergroup = display.newGroup()
local points = 0
prepoints = 0
local cheatspeed = 1
local ptlabel = display.newRoundedRect(gameovergroup,cx,125,800,100,25)
ptlabel.strokeWidth = 10
ptlabel:setFillColor(0,0.78,1)
ptlabel:setStrokeColor(0,0.312,0.4)
ptlabel.alpha = 0.7
local ptsfire = display.newImageRect(gameovergroup,"Photos/fire0.png",775,100)
ptsfire.x, ptsfire.y = cx, 24
ptsfire.fill.effect = "filter.blurHorizontal"
ptsfire.alpha = 0
local ptstext = display.newText(gameovergroup,"Очки: "..points,cx,125,font,64*textmultiplier)
ptstext:setFillColor(0,0.312,0.4)
ptstext.alpha = 0.7
local ptstatsswitch = display.newRect(gameovergroup,cx+350,125,80,80)
ptstatsswitch.alpha = 0.01
local ptstats = display.newPolygon(gameovergroup,cx+350,125,{0,-22,27,0,0,22})
ptstats:setFillColor(0,0.312,0.4)
ptstats.alpha = 0.7
local ptsmaxtext = display.newText(gameovergroup,"Рекорд: "..system.getPreference("app","maxpoints","number"),cx,110,font,42*textmultiplier)
ptsmaxtext:setFillColor(0,0.312,0.4)
ptsmaxtext.alpha = 0
local leaderboard = display.newRoundedRect(gameovergroup,cx,263,800,91,25)
leaderboard.strokeWidth = 10
leaderboard:setFillColor(0,0.78,1)
leaderboard:setStrokeColor(0,0.312,0.4)
leaderboard.alpha = 0
local leaders = display.newText(gameovergroup,"",cx,795,750,1000,font,43*textmultiplier)
leaders:setFillColor(0,0.312,0.4)
leaders.alpha = 0
local leadert = display.newText(gameovergroup,"Список рекордов",cx,263,font,55*textmultiplier)
leadert:setFillColor(0,0.312,0.4)
leadert.alpha = 0
local function ptgain()
	fallspeed = 8 + prepoints/1000
	speed = 8 + prepoints/1000
	
	for _, ii in ipairs(playerskins) do
		ii[1].fill.effect.angle = -math.min(prepoints,15000)/90
	end
	playerfire.alpha = math.max(0,math.min((prepoints-12500)/5000,1))
	if prepoints >= 12500 then
		playerfire.fill.effect.blurSize = math.abs(math.cos(prepoints/50)*35)+5
	end
	ptsfire.alpha = math.max(0,math.min((prepoints-12500)/5000,1))
	if prepoints >= 12500 then
		ptsfire.fill.effect.blurSize = math.abs(math.cos(prepoints/50)*35)+5
	end
	
	local function stupid(x,xx)
		return math.max(0, math.min(1, 2 - math.abs((((((math.min(prepoints,15000) - 15000)/90) + x) % 360) / 60) - 3))) * xx
	end
	ptlabel:setFillColor(stupid(180,1),stupid(60,1),stupid(300,1))
	ptlabel:setStrokeColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	ptstext:setFillColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	ptstats:setFillColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	ptsmaxtext:setFillColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	leaderboard:setFillColor(stupid(180,1),stupid(60,1),stupid(300,1))
	leaderboard:setStrokeColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	leaders:setFillColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))
	leadert:setFillColor(stupid(180,0.4),stupid(60,0.4),stupid(300,0.4))

	prepoints = prepoints + cheatspeed
	points = math.floor(prepoints/50)
	if system.getPreference("app","maxpoints","number") < points then
		system.setPreferences("app",{maxpoints = points})
	end
	ptstext.text = "Очки: "..points
	ptsmaxtext.text = "Макс. очки: "..system.getPreference("app","maxpoints","number")
end

local function ptstatsfunc(event)
	if event.phase == "began" then
		if ptstats.rotation == 0 then
			ptstats.rotation = 90
			ptsmaxtext.alpha = 0.7
			ptlabel.height = 136
			ptlabel.y = 143
			ptstext.y = 161
			leaderboard.alpha = 0.7
			leadert.alpha = 0.7
			leaders.alpha = 0.7
		else
			ptstats.rotation = 0
			ptsmaxtext.alpha = 0
			ptlabel.height = 100
			ptlabel.y = 125
			ptstext.y = 125
			leaderboard.alpha = 0
			leadert.alpha = 0
			leaders.alpha = 0
		end
	end
end
local function ptstatsgame(arg)
	if arg == true then
		ptstats.alpha = 0
		ptstatsswitch.alpha = 0
		ptsmaxtext.alpha = 0
		ptlabel.height = 100
		ptlabel.y = 125
		ptstext.y = 125
		leaderboard.alpha = 0
		leadert.alpha = 0
		leaders.alpha = 0
	elseif arg == false then
		ptstats.alpha = 0.7
		ptstatsswitch.alpha = 0.01
		if ptstats.rotation == 90 then
			ptsmaxtext.alpha = 0.7
			ptlabel.height = 136
			ptlabel.y = 143
			ptstext.y = 161
			leaderboard.alpha = 0.7
			leadert.alpha = 0.7
			leaders.alpha = 0.7
		end
	end
end

local function leaderboardset(event)
	if (event.isError) then
		leaders.text = "Ошибка: "..event.response.."\n"
	else
		leaders.text = ""
		local response = json.decode(event.response) or {}
		for i = 1, 10 do
			if response[i] == nil then
				table.insert(response,{username=""})
			end
			if response[i]["score"] == nil then
				leaders.text = leaders.text..i..". "..response[i]["username"].."\n"
			else
				leaders.text = leaders.text..i..". "..response[i]["username"]..": "..response[i]["score"].."\n"
			end
		end
	end
	local _, n = string.gsub(leaders.text,"\n","")
	leaderboard.y, leaderboard.height = math.min(263+n*24.4,507), math.min(91+n*48.8,579)
end
network.request("https://raw.githubusercontent.com/kostiaaan/testt_leaderboard/refs/heads/main/leaderboard","GET", leaderboardset)

local startbg = display.newRect(gameovergroup,cx,cy,sx,sy)
startbg.alpha = 0.4
startbg:toBack()
local starter = display.newRoundedRect(gameovergroup,cx,cy,620,230,75)
starter:setFillColor(0,0.5,0)
starter.strokeWidth = 15
starter:setStrokeColor(0,0.8,0)
local startex = display.newText(gameovergroup,"Старт",cx,cy,font,140*textmultiplier)
startex:setFillColor(0,0.8,0)
local shopper = display.newRoundedRect(gameovergroup,cx-212,cy+200,400,120,50)
shopper:setFillColor(0,0.5,0)
shopper.strokeWidth = 15
shopper:setStrokeColor(0,0.8,0)
local shoppex = display.newText(gameovergroup,"Иконки",shopper.x,shopper.y,font,75*textmultiplier)
shoppex:setFillColor(0,0.8,0)
local iconbg = display.newRoundedRect(gameovergroup,cx,850,sx-100,900,40)
iconbg.alpha = 0
iconbg:setFillColor(128/255,219/255,1)
iconbg.strokeWidth = 10
iconbg:setStrokeColor(64/255,155/255,191/255)
local iconname = display.newText(gameovergroup,playerskins[skin][4],cx,475,font,100*textmultiplier)
iconname.alpha = 0
iconname:setFillColor(64/255,155/255,191/255)
local icondescription = display.newText({parent=gameovergroup,text=playerskins[skin][5],x=cx,y=1225,width=sx-100,font=font,fontSize=58*textmultiplier,align="center"})
icondescription.alpha = 0
icondescription:setFillColor(57/255,140/255,172/255)
local iconbgsep = display.newRect(gameovergroup,cx,850,sx-100,600)
iconbgsep.alpha = 0
iconbgsep:setFillColor(0,0)
iconbgsep.strokeWidth = 10
iconbgsep:setStrokeColor(64/255,155/255,191/255)
local iconicon = display.newImage(gameovergroup,playerskins[skin][2],cx,850)
iconicon.alpha = 0
iconicon.width, iconicon.height = iconicon.width*2.5*playerskins[skin][6],iconicon.height*2.5*playerskins[skin][6]
local settings = display.newRoundedRect(gameovergroup,cx+212,cy+200,400,120,50)
settings:setFillColor(0,0.5,0)
settings.strokeWidth = 15
settings:setStrokeColor(0,0.8,0)
local settingx = display.newText(gameovergroup,"Настройки",settings.x,settings.y,font,65*textmultiplier)
settingx:setFillColor(0,0.8,0)
local exitbut = display.newRoundedRect(gameovergroup,cx,cy+344,400,120,50)
exitbut:setFillColor(0,0.5,0)
exitbut.strokeWidth = 15
exitbut:setStrokeColor(0,0.8,0)
local exittex = display.newText(gameovergroup,"Выйти",cx,exitbut.y,font,75*textmultiplier)
exittex:setFillColor(0,0.8,0)
local function reload()
	starter:removeEventListener("touch", gamestart)
	shopper:removeEventListener("touch", shopping)
	exitbut:removeEventListener("touch", exitfunc)
	settings:removeEventListener("touch", setting)
	starter:setFillColor(0,0.5,0)
	starter:setStrokeColor(0,1,0)
	startex:setFillColor(0,1,0)
	shopper:setFillColor(0,0.5,0)
	shopper:setStrokeColor(0,1,0)
	shoppex:setFillColor(0,1,0)
	settings:setFillColor(0,0.5,0)
	settings:setStrokeColor(0,1,0)
	settingx:setFillColor(0,1,0)
	exitbut:setFillColor(0,0.5,0)
	exitbut:setStrokeColor(0,1,0)
	exittex:setFillColor(0,1,0)
	timer.performWithDelay(500, function()
		starter:setFillColor(0,1,0)
		starter:setStrokeColor(0,0.5,0)
		startex:setFillColor(0,0.5,0)
		shopper:setFillColor(0,1,0)
		shopper:setStrokeColor(0,0.5,0)
		shoppex:setFillColor(0,0.5,0)
		settings:setFillColor(0,1,0)
		settings:setStrokeColor(0,0.5,0)
		settingx:setFillColor(0,0.5,0)
		exitbut:setFillColor(0,1,0)
		exitbut:setStrokeColor(0,0.5,0)
		exittex:setFillColor(0,0.5,0)
		starter:addEventListener("touch", gamestart)
		shopper:addEventListener("touch", shopping)
		exitbut:addEventListener("touch", exitfunc)
		settings:addEventListener("touch", setting)
	end)
end

local function gameover()
	fallspeed = 0
	speed = 0
	startbg.alpha = 0.4
	starter.alpha = 1
	startex.alpha = 1
	shoppex.alpha = 1
	shopper.alpha = 1
	settings.alpha = 1
	settingx.alpha = 1
	exitbut.alpha = 1
	exittex.alpha = 1
	ptstatsgame(false)
	gameovergroup:toFront()
	Runtime:removeEventListener("enterFrame", ptgain)
	reload()
	if system.getPreference("app","maxpoints","number") >= 75 then achievement(2) end
	if system.getPreference("app","maxpoints","number") >= 150 then achievement(3) end
	if system.getPreference("app","maxpoints","number") >= 225 then achievement(4) end
	if points == 0 then achievement(6) end
	for _, i in ipairs({42,52,67,69,148,228}) do
		if points == i then achievement(9) end
	end
end
if system.getPreference("app","maxpoints","number") >= 75 then achievement(2) end
if system.getPreference("app","maxpoints","number") >= 150 then achievement(3) end
if system.getPreference("app","maxpoints","number") >= 225 then achievement(4) end
if #unlocked >= 3 then achievement(8) end

function gamestart(event)
	if event.phase == "began" then
		starter.alpha = 0
		startbg.alpha = 0
		startex.alpha = 0
		shopper.alpha = 0
		shoppex.alpha = 0
		settings.alpha = 0
		settingx.alpha = 0
		exitbut.alpha = 0
		exittex.alpha = 0
		fallspeed = 8
		speed = 8
		
		for i = 1, #hazards do
			display.remove(hazards[i])
		end
		spawnhazards()
		ptstatsgame(true)
		
		if math.random(1,20) == 1 then
			achievement(5)
		end
		
		for i, ii in ipairs(playerskins) do
			if i == skin then
				ii[1].alpha = 1
			else
				ii[1].alpha = 0
			end
		end
		
		gameovergroup:toFront()
		
		player.x, player.y = 125, 950
		playerhitbox.x, playerhitbox.y = 125, 950

		prepoints = 0
		Runtime:addEventListener("enterFrame", ptgain)
	end
end


local shopgroup
local icons = {}
function iconpick(event)
	if event.phase == "began" then
		local choice = event.target.choice
		local isChosenUnlocked = false
		local preiconback = icons[skin*2-1]
		local preicon = icons[skin*2]
		local iconback = icons[choice*2-1]
		local icon = icons[choice*2]
		iconname.text = playerskins[choice][4]
		icondescription.text = playerskins[choice][5]
		iconbg:setFillColor(128/255,219/255,1)
		iconbg:setStrokeColor(64/255,155/255,191/255)
		iconname:setFillColor(64/255,155/255,191/255)
		icondescription:setFillColor(57/255,140/255,172/255)
		iconbgsep:setStrokeColor(64/255,155/255,191/255)
		display.remove(iconicon)
		iconicon = display.newImage(gameovergroup,playerskins[choice][2],cx,850)
		iconicon.width, iconicon.height = iconicon.width*2.5*playerskins[choice][6],iconicon.height*2.5*playerskins[choice][6]
		for _, unlockedid in ipairs(unlocked) do
			if unlockedid == choice then
				isChosenUnlocked = true
				break
			end
		end
		if not isChosenUnlocked then
			iconbg:setFillColor(0.3)
			iconname:setFillColor(0.12)
			icondescription:setFillColor(0.07)
			iconbg:setStrokeColor(0.18)
			iconbgsep:setStrokeColor(0.18)
			display.remove(iconicon)
			iconicon = display.newImage(gameovergroup,playerskins[choice][2],cx,850)
			iconicon.width, iconicon.height = iconicon.width*2.5*playerskins[choice][6],iconicon.height*2.5*playerskins[choice][6]
			iconicon:setFillColor(0)
			return
		end
		
		preiconback:setFillColor(0.85)
		preiconback:setStrokeColor(0.6)
		preicon:setFillColor(1)
		preicon.fill.effect = "filter.grayscale"
		iconback:setFillColor(153/255,232/255,1)
		iconback:setStrokeColor(0,195/255,1)
		icon:setFillColor(1)
		icon.fill.effect = nil
		skin = choice
		system.setPreferences("app",{savedskin=skin})
	end
end
function shopping(event)
	if event.phase == "began" then
		if starter.alpha == 1 then
			ptstatsgame(true)
			starter.alpha = 0
			startex.alpha = 0
			settings.alpha = 0
			settingx.alpha = 0
			exitbut.alpha = 0
			exittex.alpha = 0
			shopper.x = cx
			shoppex.x = cx
			shopper.y = 280
			shoppex.y = 280
			iconbg.alpha = 1
			iconname.alpha = 1
			icondescription.alpha = 1
			iconbgsep.alpha = 1
			iconicon.alpha = 1
			
			shopgroup = display.newGroup()
			shopgroup.x, shopgroup.y = cx,cy
			for i = 1, #playerskins do
				local row, totalRows, colsInRow, posX, posY
				if #playerskins <= 10 then
					row = math.floor((i-1)/5)
					totalRows = math.floor((#playerskins-1)/5)
					colsInRow = (row == totalRows) and (#playerskins-1)%5 or 4
					posX = 200 * ((i-1)%5) - 100 * colsInRow
					posY = (350+(sy-1300)/2)-(totalRows*200)/2+row*200
					iconbsize = 125
				elseif #playerskins <= 21 then
					row = math.floor((i-1)/7)
					totalRows = math.floor((#playerskins-1)/7)
					colsInRow = (row == totalRows) and (#playerskins-1)%7 or 6
					posX = 150 * ((i-1)%7) - 75 * colsInRow
					posY = (350+(sy-1300)/2)-(totalRows*150)/2+row*150
					iconbsize = 100
				else
					row = math.floor((i-1)/10)
					totalRows = math.floor((#playerskins-1)/10)
					colsInRow = (row == totalRows) and (#playerskins-1)%10 or 9
					posX = 105 * ((i-1)%10) - 52 * colsInRow
					posY = (325+(sy-1300)/2)-(totalRows*90)/2+row*105
					iconbsize = 70
				end
		
				local iconback = display.newRoundedRect(shopgroup,posX,posY,iconbsize,iconbsize,15)
				iconback.rotation = 45
				iconback.strokeWidth = 7
				iconback.choice = i
				table.insert(icons,iconback)
				
				local icon = display.newImage(shopgroup,playerskins[i][2])
				icon.x, icon.y = iconback.x, iconback.y
				icon.width, icon.height = icon.width*playerskins[i][6]*iconbsize/125,icon.height*playerskins[i][6]*iconbsize/125
				table.insert(icons,icon)
				
				local isunlocked = false
				for _, unlockedid in ipairs(unlocked) do
					if unlockedid == i then
						isunlocked = true
						break
					end
				end
				
				if isunlocked then
					if i == skin then
						iconback:setFillColor(153/255,232/255,1)
						iconback:setStrokeColor(0,195/255,1)
					else
						iconback:setFillColor(0.85)
						iconback:setStrokeColor(0.6)
						icon.fill.effect = "filter.grayscale"
					end
				else
					iconback:setFillColor(0.3)
					iconback:setStrokeColor(0.22)
					icon:setFillColor(0)
				end
			end
			
			for ii = 1, #icons, 2 do
				icons[ii]:addEventListener("touch",iconpick)
			end
		else
			ptstatsgame(false)
			starter.alpha = 1
			startex.alpha = 1
			settings.alpha = 1
			settingx.alpha = 1
			exitbut.alpha = 1
			exittex.alpha = 1
			shopper.x = cx-212
			shoppex.x = cx-212
			shopper.y = cy+200
			shoppex.y = cy+200
			iconbg.alpha = 0
			iconname.alpha = 0
			icondescription.alpha = 0
			iconbgsep.alpha = 0
			iconicon.alpha = 0
			
			for _, i in ipairs(icons) do
				display.remove(i)
			end
			display.remove(shopgroup)
			shopgroup = nil
			icons = {}
		end
	end
end

function exitfunc(event)
	if event.phase == "began" then
		native.requestExit()
	end
end

function exitandsavefunc(event)
	if event.phase == "began" then
		system.setPreferences("app",{textmultiplier=textmultiplier})
		native.requestExit()
	end
end

local textmultiplierlabel, textmultipliertest
function textmultiplierchangefung(event)
	if event.phase == "began" then
		if event.target.change == "default" then
			textmultiplier = 1
		elseif event.target.change then
			textmultiplier = textmultiplier + 0.01
		else
			textmultiplier = textmultiplier - 0.01
		end
		textmultiplier = math.min(math.max(textmultiplier,0.75),1.5)
		textmultipliertest.size = 40*textmultiplier
		textmultiplierlabel.text = "Размер текста: "..textmultiplier
	end
end
local savechangesbut = display.newRoundedRect(gameovergroup,cx,sy-150,970,160,65)
savechangesbut:setFillColor(0,1,0)
savechangesbut.strokeWidth = 15
savechangesbut:setStrokeColor(0,0.5,0)
savechangesbut.alpha = 0
savechangesbut:addEventListener("touch",exitandsavefunc)
local savechangestext = display.newText(gameovergroup,"Сохранить изменения",cx,savechangesbut.y,font,80*textmultiplier)
savechangestext:setFillColor(0,0.5,0)
savechangestext.alpha = 0
local settbg = display.newRoundedRect(gameovergroup,cx,cy+35,sx-100,1225,40)
settbg.alpha = 0
settbg:setFillColor(0.55)
settbg.strokeWidth = 10
settbg:setStrokeColor(0.35)
--[[local]] textmultiplierlabel = display.newText(gameovergroup,"Размер текста: "..textmultiplier,cx,cy-460,sx-175,0,font,75*textmultiplier)
textmultiplierlabel.alpha = 0
textmultiplierlabel:setFillColor(0.35)
local textmultiplierupperbut = display.newRoundedRect(gameovergroup,cx+430,textmultiplierlabel.y-50,80,80,20)
textmultiplierupperbut:setFillColor(0,1,0)
textmultiplierupperbut.strokeWidth = 10
textmultiplierupperbut:setStrokeColor(0,0.6,0)
textmultiplierupperbut.change = true
textmultiplierupperbut.alpha = 0
textmultiplierupperbut:addEventListener("touch",textmultiplierchangefung)
local textmultiplierlowerbut = display.newRoundedRect(gameovergroup,cx+430,textmultiplierlabel.y+50,80,80,20)
textmultiplierlowerbut:setFillColor(1,0,0)
textmultiplierlowerbut.strokeWidth = 10
textmultiplierlowerbut:setStrokeColor(0.7,0,0)
textmultiplierlowerbut.change = false
textmultiplierlowerbut.alpha = 0
textmultiplierlowerbut:addEventListener("touch",textmultiplierchangefung)
local textmultiplierdefbut = display.newRoundedRect(gameovergroup,cx+330,textmultiplierlabel.y,80,80,20)
textmultiplierdefbut:setFillColor(0,0.75,1)
textmultiplierdefbut.strokeWidth = 10
textmultiplierdefbut:setStrokeColor(0,0.525,0.7)
textmultiplierdefbut.change = "default"
textmultiplierdefbut.alpha = 0
textmultiplierdefbut:addEventListener("touch",textmultiplierchangefung)
local textmultipliertestbg = display.newRoundedRect(gameovergroup,cx,cy-300,850,60,12)
textmultipliertestbg.alpha = 0
textmultipliertestbg:setFillColor(0,0.88,0.88)
textmultipliertestbg.strokeWidth = 7
textmultipliertestbg:setStrokeColor(0,0.5,0.5)
--[[local]] textmultipliertest = display.newText(gameovergroup,"Этот текст должен идеально лежать в рамке",cx,cy-300,font,40*textmultiplier)
textmultipliertest.alpha = 0
textmultipliertest:setFillColor(0,0.5,0.5)
function setting(event)
	if event.phase == "began" then
		local prevtextmultiplier = textmultiplier
		if starter.alpha == 1 then
			ptstatsgame(true)
			starter.alpha = 0
			startex.alpha = 0
			shopper.alpha = 0
			shoppex.alpha = 0
			exitbut.alpha = 0
			exittex.alpha = 0
			settings.x = cx
			settingx.x = cx
			settings.y = 280
			settingx.y = 280
			savechangesbut.alpha = 1
			savechangestext.alpha = 1
			settbg.alpha = 1
			textmultiplierlabel.alpha = 1
			textmultiplierupperbut.alpha = 0.8
			textmultiplierlowerbut.alpha = 0.8
			textmultiplierdefbut.alpha = 0.8
			textmultipliertestbg.alpha = 1
			textmultipliertest.alpha = 1
		else
			ptstatsgame(false)
			starter.alpha = 1
			startex.alpha = 1
			shopper.alpha = 1
			shoppex.alpha = 1
			exitbut.alpha = 1
			exittex.alpha = 1
			settings.x = cx+212
			settingx.x = cx+212
			settings.y = cy+200
			settingx.y = cy+200
			savechangesbut.alpha = 0
			savechangestext.alpha = 0
			settbg.alpha = 0
			textmultiplierlabel.alpha = 0
			textmultiplierupperbut.alpha = 0
			textmultiplierlowerbut.alpha = 0
			textmultiplierdefbut.alpha = 0
			textmultipliertestbg.alpha = 0
			textmultipliertest.alpha = 0
			textmultiplier = prevtextmultiplier
		end
	end
end

reload()

gameovergroup:toFront()

local function playerhazardtouch(self,event)
	if event.phase == "began" then
		if self.ID == "player" and event.other.ID == "hazard" or event.other.ID == "sideshazard" or event.other.ID == "glitchhazard" then
			gameover()
			if event.other.ID == "sideshazard" then achievement(7) end
			if event.other.ID == "glitchhazard" then achievement(10) end
		end
	end
end

Runtime:addEventListener("enterFrame", move)
Runtime:addEventListener("touch", playermovefunc)
ptstatsswitch:addEventListener("touch", ptstatsfunc)
playerhitbox.collision = playerhazardtouch
playerhitbox:addEventListener("collision",playerhitbox)

--- DEBUG - DEBUG - DEBUG - DEBUG - DEBUG - DEBUG - DEBUG - DEBUG ---

local testmode = false
if testmode then
	local testbut = display.newRect(sx-50,50,85,85)
	testbut.alpha = 0.3
	local function testbutfunc(event)
		if event.phase == "began" then
			if testbut.alpha == 0.4 then
				testbut.alpha = 0.3
				physics.setDrawMode("normal")
			else
				testbut.alpha = 0.4
				physics.setDrawMode("hybrid")
			end
		end
	end
	testbut:addEventListener("touch", testbutfunc)
	local testbut0 = display.newRect(sx-50,150,85,85)
	testbut0.alpha = 0.3
	local function testbut0func(event)
		if event.phase == "began" then
			if testbut0.alpha == 0.4 then
				testbut0.alpha = 0.3
				physics.start()
			else
				testbut0.alpha = 0.4
				physics.pause()
			end
		end
	end
	testbut0:addEventListener("touch", testbut0func)
	
	local testbut1 = display.newRect(sx-50,250,85,85)
	testbut1.alpha = 0.3
	local function testbut1func(event)
		if event.phase == "began" then
			skin = skin + 1
			if skin > #playerskins then
				skin = 1
			end
		end
	end
	testbut1:addEventListener("touch", testbut1func)
	
	local testtext = display.newText("prepoints = nil\npoints = nil\nmaxpoints = nil\nskin = nil\ncheatspeed = nil\nspeed = nil\nunlocked = nil\nachtdoing = nil\nachtlist = nil",cx,cy,sx,sy,font,45*textmultiplier)
	testtext:setFillColor(0.8)
	local function testtextfunc(event)
		testtext.text = "prepoints = "..prepoints.."\npoints = "..points.."\nmaxpoints = "..system.getPreference("app","maxpoints","number").."\nskin = "..skin.."\ncheatspeed = "..cheatspeed.."\nspeed = "..speed.."\nunlocked = "..json.prettify(unlocked).."\nachtdoing = "..tostring(achtdoing).."\nachtlist = "..json.prettify(achtlist)
		testtext:toFront()
	end
	
	local testbut2 = display.newRect(sx-50,350,85,85)
	testbut2.alpha = 0.3
	local function testbut2func(event)
		if event.phase == "began" then
			if testbut2.alpha == 0.4 then
				testbut2.alpha = 0.3
				Runtime:removeEventListener("enterFrame", testtextfunc)
			else
				testbut2.alpha = 0.4
				Runtime:addEventListener("enterFrame", testtextfunc)
			end
		end
	end
	testbut2:addEventListener("touch", testbut2func)
	
	local testbut3 = display.newRect(sx-50,450,85,85)
	testbut3.alpha = 0.3
	local function testbut3func(event)
		if event.phase == "began" then
			if testbut3.alpha == 0.4 then
				testbut3.alpha = 0.3
				cheatspeed = 1
			else
				testbut3.alpha = 0.4
				cheatspeed = 75
			end
		end
	end
	testbut3:addEventListener("touch", testbut3func)
	
	local testbut4 = display.newRect(sx-50,550,85,85)
	testbut4.alpha = 0.3
	testbut4:setFillColor(1,0.6,0.6)
	local function testbut4func(event)
		if event.phase == "began" then
			unlocked = {1}
			system.setPreferences("app",{unlocks=json.encode({1}),maxpoints=0,savedskin=1})
		end
	end
	testbut4:addEventListener("touch", testbut4func)
	
	local testbut5 = display.newRect(sx-50,650,85,85)
	testbut5.alpha = 0.3
	testbut5:setFillColor(0.6,1,0.6)
	local function testbut5func(event)
		if event.phase == "began" then
			unlocked = {}
			for i = 1, #playerskins do table.insert(unlocked,i) end
			system.setPreferences("app",{unlocks=json.encode(unlocked),maxpoints=2^1023})
		end
	end
	testbut5:addEventListener("touch", testbut5func)
end
--------------------------------------------------------------------------------
-- АДМИН-ПАНЕЛЬ ДЛЯ CORONA SDK / SOLAR2D
--------------------------------------------------------------------------------

-- 1. Создаем группу для элементов админ-панели (чтобы скрывать/показывать их вместе)
local adminGroup = display.newGroup()
adminGroup.isVisible = false -- Изначально панель скрыта

-- Получаем размеры экрана для центрирования
local screenW = display.contentWidth
local screenH = display.contentHeight

-- 2. Затемнение фона под панелью (опционально)
local overlay = display.newRect( adminGroup, screenW / 2, screenH / 2, screenW, screenH )
overlay:setFillColor( 0, 0, 0, 0.5 ) -- Полупрозрачный черный фон

-- 3. Фон самой админ-панели
local panelBg = display.newRect( adminGroup, screenW / 2, screenH / 2, 280, 350 )
panelBg:setFillColor( 0.15, 0.15, 0.15 )
panelBg.strokeWidth = 2
panelBg:setStrokeColor( 0.8, 0.8, 0.8 )

-- Заголовок панели
local panelTitle = display.newText( adminGroup, "ПАРАМЕТРЫ АДМИНА", screenW / 2, screenH / 2 - 140, native.systemFontBold, 16 )
panelTitle:setFillColor( 1, 1, 1 )

-- 4. Кнопка закрытия панели ("X")
local closeBtn = display.newRect( adminGroup, screenW / 2 + 120, screenH / 2 - 140, 30, 30 )
closeBtn:setFillColor( 0.8, 0.2, 0.2 )
local closeText = display.newText( adminGroup, "X", screenW / 2 + 120, screenH / 2 - 140, native.systemFontBold, 16 )

-- 5. Пример функциональной кнопки внутри панели (например, добавить очки / здоровье / золото)
local actionBtn = display.newRect( adminGroup, screenW / 2, screenH / 2 - 60, 220, 40 )
actionBtn:setFillColor( 0.2, 0.6, 0.2 )
local actionText = display.newText( adminGroup, "Добавить бонус", screenW / 2, screenH / 2 - 60, native.systemFont, 14 )

-- Обработчик закрытия панели
local function closePanel( event )
    if ( event.phase == "ended" ) then
        adminGroup.isVisible = false
    end
    return true
end
closeBtn:addEventListener( "touch", closePanel )
closeText:addEventListener( "touch", closePanel )

-- Обработчик действия админа (сюда можно вписать вашу игровую логику)
local function adminAction( event )
    if ( event.phase == "ended" ) then
        print("Админ-действие выполнено: например, выданы ресурсы или изменен уровень.")
        -- Пример: если у вас есть глобальная переменная score, можно написать:
        -- score = score + 1000
    end
    return true
end
actionBtn:addEventListener( "touch", adminAction )
actionText:addEventListener( "touch", adminAction )


--------------------------------------------------------------------------------
-- КНОПКА ВЫЗОВА АДМИН-ПАНЕЛИ (Всегда видна на экране)
--------------------------------------------------------------------------------

-- Создаем кнопку в левом верхнем углу экрана
local openAdminBtn = display.newRect( 40, 30, 60, 30 )
openAdminBtn:setFillColor( 0.2, 0.2, 0.8 )
openAdminBtn.strokeWidth = 1
openAdminBtn.setStrokeColor = ( 1, 1, 1 )

local openAdminText = display.newText( "ADMIN", 40, 30, native.systemFontBold, 12 )
openAdminText:setFillColor( 1, 1, 1 )

-- Обработчик открытия панели
local function openPanel( event )
    if ( event.phase == "ended" ) then
        -- Переключаем видимость панели
        adminGroup.isVisible = not adminGroup.isVisible
        
        -- Если панель открылась, поднимаем её на самый передний план
        if adminGroup.isVisible then
            adminGroup:toFront()
            openAdminBtn:toFront()
            openAdminText:toFront()
        end
    end
    return true
end

openAdminBtn:addEventListener( "touch", openPanel )
openAdminText:addEventListener( "touch", openPanel )
