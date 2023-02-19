package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var quoteText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var quoteBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 0.55));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color color is useless cuz we removed the og bg
			['THE GANG'],
			['Friend',			'friend',		'Leader, 3D Modeler, and Artist\n"Lost time making models"',													'https://twitter.com/Friendfred3',		'EE222E'],
			['SoyDeans',		'sussydeans',	'Leader and Concept Artist\n"Havent been breathing since 1972"',												'https://twitter.com/SoyDoesArt',		'C9CA9E'],
			['Sandwich',		'sandwich',		'Main Coder, Playtester and Charter\n"Life is like a Sandwich. Either way you flip it, the bread comes first"',	'https://twitter.com/randomguyhere0',	'F6DEBD'],
			['Kevin Kuntz',		'kevin',		'Coder\n"If you like that, try a lil summy summy"',																'https://twitter.com/KevinHunts23',		'EFB0A1'],
			['Noosh',			'noosh',		'Additional Coding Help\nLook who it is! Its look who it is!',													'https://twitter.com/NooshStuff',		'0A5700'],
			['Scrumbo',			'scrumbo',		'Composer\n"I can have sex legally"',																			'https://twitter.com/scrumbo_',			'FFC0DD'],
			["Scrumbo's Dad",	'dad',			'Henry VA\n"So they kept on searching, left and right, up and down, deep and wide."',							'https://twitter.com/scrumbo_',			'6b111d'],
			['Ezhalt',			'ez',			'Composer\n"Boate califórnia é o seu point"',																	'https://twitter.com/_ezhaltd',			'742E4E'],
			['Hazelpy',			'hazel',		'Composer\n"Play project swan"',																				'https://twitter.com/hazelpyyt',		'66CCCC'],
			['Samiiwave',		'samiwave',		'Composer',																										'https://twitter.com/mapleleef_',		'804E88'],
			['Top 10 Awesome',	'top10',		'Composer\n"mario"',																							'https://twitter.com/top10awesome3',	'FDFE4F'],
			['Anonymous',		'question',		'Composer\n"quote"',																							'https://twitter.com/real_scawthon',	'444444'],
			['Cyratu',			'cyratu',		'Chromatics, Artist, and Charter\n"I have a license for being dumb"',											'https://twitter.com/Cyratu3',			'DD681A'],
			['Bonky',			'bonky',		'Composer\n"ja kiedy kupa kibel aaaAAAA"',																		'https://twitter.com/Bonk1y',			'DE9A3B'],
			['Leslay',			'Leslay',		'Chromatics\n"har har har har har"',																			'https://twitter.com/LeSlayWasTaken',	'f1ff7e'],
			['Shmap',			'shmappu',		'Artist\n"pretty ladies, please dont block me or i will injure myself!"',										'https://twitter.com/shmaplos',		'5CC970'],
			['Josh Reptiliano',	'josh',			'Artist\n"like para que fernan lo vea"',																		'https://twitter.com/josh_reptiliano',	'F46D00'],
			['Marketpler',		'marketplier',	'Artist\n"I like men"',																							'https://twitter.com/bonker34',			'FFFFFF'],
			['Scrimbo',			'scrimbo',		'Artist, charter, and trailer\n"I love men"',																	'https://twitter.com/BlooperCloon',		'DA4029'],
			['Pashankie',		'pashankie',	'Charter\n"uhhhhhhhhhh"',																						'https://twitter.com/Pashankie',		'7B4AB3'],
			['Decoy',			'decoy',		'Charter\n"play Somaris Quest: The Celestial Story when it releases"',											'https://twitter.com/Yoshinova_',		'391665'],
			['Nickk',			'nick',			'Charter\n"I have to shit myself"',																				'https://twitter.com/nickstwt',			'CC0100'],
			['Huskey',			'huskey',		'Charter and playtester\n"hi fred"',																			'https://twitter.com/Huzks3',			'3b3b45s'],
			['Fredrick',		'fredrick',		'Charter\n"Take the 6 nuggets and throw 2 of them away, put	2 of them up your ass"',							'https://twitter.com/fredickfunny',		'50b4d5'],
			['Kal',				'kal',			'Playtester\n"i love snas"',																					'https://twitter.com/Kal_050',			'C85167']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
		}
		
		quoteBox = new AttachedSprite();//these are less about the roles and the funny quotes 
		quoteBox.makeGraphic(1, 1, FlxColor.BLACK);
		quoteBox.xAdd = -10;
		quoteBox.yAdd = -10;
		quoteBox.alphaMult = 0.6;
		quoteBox.alpha = 0.6;
		add(quoteBox);

		quoteText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		quoteText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		quoteText.scrollFactor.set();
		//quoteText.borderSize = 2.4;
		quoteBox.sprTracker = quoteText;
		add(quoteText);

		//bg.color = getCurrentBGColor();
		//intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		/*var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}*/

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		quoteText.text = creditsStuff[curSelected][2];
		quoteText.y = FlxG.height - quoteText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(quoteText, {y : quoteText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		quoteBox.setGraphicSize(Std.int(quoteText.width + 20), Std.int(quoteText.height + 25));
		quoteBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	/*function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}*/

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}