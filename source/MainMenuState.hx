package;

import editors.ChartingState;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	public static var mainweekbeat:Bool;
	public static var isHenrySong:Bool;

	//trophies
	var mgTrophy:FlxSprite;//main gang(week)
	var feTrophy:FlxSprite;//foxy exe
	var omcTrophy:FlxSprite;//red lake
	var timeTrophy:FlxSprite;
	var ueTrophy:FlxSprite;//UNiverse end

	var songKey:String = 'RWQFSFASXC';
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var songKeysBuffer:String = '';
	var blackScreenMM:FlxSprite;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		//WeekData.loadTheFirstEnabledMod();
		//Lock.loadSave();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		isHenrySong = false;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		//load unlocks in here so i can do the trophies and all songs go back here when done
		FreeplayState.redlakeUnlocked = FlxG.save.data.redlakeUnlocked;//omc
		FreeplayState.timeUnlocked = FlxG.save.data.timeUnlocked;//8bitfrebear
		FreeplayState.headtripUnlocked = FlxG.save.data.headtripUnlocked;
		FreeplayState.fleeUnlocked = FlxG.save.data.fleeUnlocked;//hook
		FreeplayState.universeendUnlocked = FlxG.save.data.universeendUnlocked;//legs
		FreeplayState.fredbarsUnlocked = FlxG.save.data.fredbarsUnlocked;
		FreeplayState.shadowUnlocked = FlxG.save.data.shadowUnlocked;
		FreeplayState.isolationUnlocked = FlxG.save.data.isolationUnlocked;
		MainMenuState.mainweekbeat = FlxG.save.data.mainweekbeat;//freddy trophy

		//trace(FreeplayState.redlakeUnlocked);
		//trace(FreeplayState.timeUnlocked);
		//trace(FreeplayState.headtripUnlocked);
		//trace(FreeplayState.fleeUnlocked);
		//trace(FreeplayState.universeendUnlocked);
		//trace(FreeplayState.fredbarsUnlocked);
		//trace(FreeplayState.shadowUnlocked);
		//trace(FreeplayState.songsUnlocked);
		//trace(FreeplayState.isolationUnlocked);
		//trace(MainMenuState.mainweekbeat);

		FlxG.mouse.visible = true;

		//PLAYED ALL OTHER SONGS(INCLUDING MAIN WEEK)
		if(FreeplayState.timeUnlocked && FreeplayState.headtripUnlocked && FreeplayState.fleeUnlocked && FreeplayState.universeendUnlocked && FreeplayState.redlakeUnlocked && FreeplayState.fredbarsUnlocked && FreeplayState.shadowUnlocked && MainMenuState.mainweekbeat) {
			FreeplayState.songsUnlocked = true;
			FlxG.save.data.songsUnlocked = FreeplayState.songsUnlocked;
			FlxG.save.flush();
		}

		if(FreeplayState.isolationUnlocked){//played henry {
			FreeplayState.songsUnlocked = false;
			FlxG.save.data.songsUnlocked = FreeplayState.songsUnlocked;
			FlxG.save.flush();
		}

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 0.55));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 95 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 120)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.visible = false;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.setGraphicSize(Std.int(menuItem.width * 1.5));
			menuItem.updateHitbox();
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					menuItem.visible = true;
					canClick = true;
				});
		}

		var mgTrophy:FlxSprite = new FlxSprite(-10, 560).loadGraphic(Paths.image('trophies/maingangtrophy'));//1
		mgTrophy.antialiasing = true;
		if(mainweekbeat)
			add(mgTrophy);

		var feTrophy:FlxSprite = new FlxSprite(300, 560).loadGraphic(Paths.image('trophies/foxyexetrophy'));//3
		feTrophy.antialiasing = true;
		if(FreeplayState.fleeUnlocked)
			add(feTrophy);

		var omcTrophy:FlxSprite = new FlxSprite(150, 560).loadGraphic(Paths.image('trophies/omctrophy'));//2
		omcTrophy.antialiasing = true;
		if(FreeplayState.redlakeUnlocked)
			add(omcTrophy);

		var timeTrophy:FlxSprite = new FlxSprite(950, 560).loadGraphic(Paths.image('trophies/timetrophy'));//5
		timeTrophy.antialiasing = true;
		if(FreeplayState.timeUnlocked)
			add(timeTrophy);

		var ueTrophy:FlxSprite = new FlxSprite(800, 560).loadGraphic(Paths.image('trophies/Universeendtrophy'));//4
		ueTrophy.antialiasing = true;
		if(FreeplayState.universeendUnlocked)
			add(ueTrophy);

		var sbTrophy:FlxSprite = new FlxSprite(1100, 560).loadGraphic(Paths.image('trophies/shadowtrophy'));//6
		sbTrophy.antialiasing = true;
		if(FreeplayState.shadowUnlocked)
			add(sbTrophy);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		blackScreenMM = new FlxSprite().makeGraphic(Std.int(FlxG.width * 4), Std.int(FlxG.height * 4), FlxColor.BLACK);
		blackScreenMM.scrollFactor.set();
		blackScreenMM.screenCenter();
		blackScreenMM.alpha = 0.00001;
		add(blackScreenMM);

		if(FreeplayState.songsUnlocked){
			FlxG.sound.music.volume = 0;
			blackScreenMM.alpha = 1;
			isHenrySong = true;
			var challenge = new Lock.NewChallenger(FlxG.camera);
			add(challenge);
			challenge.challenge('Isolation', 0, function() {}, false, true);
		}

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	var canClick:Bool = true;
	var transitioning:Bool = false;
	var usingMouse:Bool = false;

	override function update(elapsed:Float)
	{
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (FlxG.mouse.overlaps(spr))
			{
				if(canClick)
				{
					curSelected = spr.ID;
					usingMouse = true;
				}
	
				if(FlxG.mouse.justPressed && canClick)
				{
					spr.animation.play('selected');
					selectSomething();
				}
			}
			else if (!transitioning){
				spr.animation.play('idle');
			}
	
		});

		if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
		{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			if(allowedKeys.contains(keyName)) {
				songKeysBuffer += keyName;
				if(songKeysBuffer.length >= 32) songKeysBuffer = songKeysBuffer.substring(1);
				//trace('Test! Allowed Key pressed!!! Buffer: ' + songKeysBuffer);
				if (songKeysBuffer.contains(songKey))
				{
					gotoSong();
				}
			}
		}
	
		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
	
		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function gotoSong() {
		FlxG.sound.music.volume = 0;
		canClick = false;// if u click while loading u can open freeplay or shit like that lol!!!
		blackScreenMM.alpha = 1;
		var challenge = new Lock.NewChallenger(FlxG.camera);
		add(challenge);
		challenge.challenge('say-my-name', 0, function() {}, false, true);
	}

	function selectSomething()
	{
		selectedSomethin = true;
	
		transitioning = true;
	
		canClick = false;
	
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
			}
			else{
				FlxTween.tween(spr, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			}
		});
		goToState();
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];
		trace('selected' + daChoice);
	
		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			switch (daChoice)
			{
				case 'story_mode':
					WeekData.reloadWeekFiles(true);
					var songArray:Array<String> = [];
					var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).songs;
					for (i in 0...leWeek.length) {
						songArray.push(leWeek[i][0]);
					}
					
					PlayState.storyPlaylist = songArray;
					PlayState.isStoryMode = true;
					
					PlayState.storyDifficulty = 0;
					
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyWeek = 0;
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;
					LoadingState.loadAndSwitchState(new PlayState(), true);
					FreeplayState.destroyFreeplayVocals();
				case 'freeplay':
					MusicBeatState.switchState(new FreeplayState());
				case 'credits':
					MusicBeatState.switchState(new CreditsState());
				case 'options':
					MusicBeatState.switchState(new options.OptionsState());
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				//spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
