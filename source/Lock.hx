import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

using StringTools;

//This was the gonna be the freeplay song lock system but I decided there was an easier way
/*class Lock {	//this is completely independant from the story week lock system
	public static var unlocks:Map<String, Bool> = null;

	public static var lockedSongs:Array<String> = [ //ALL SONGS that need to be unlocked individually will need to be on this list
		'Time',
		'Head-Trip',
		'Fred-Bars',
		'Flee',
		'Universe-End',
		'Red-Lake'
		//SHADOW BONNIE SONG NAME
		//CHIPPER'S REVENGE SONG NAME
		//'isolation',
		//'happy-rainbow-land'
	];

	public static function unlock(name:String):Void {
		if (lockedSongs.contains(name)) {
			unlocks.set(name, true);
			saveData();
		}
	}

	public static function isUnlocked(name:String) {	//if a song isn't on the lockedSongs list it will return true. this makes the logic in FreeplayState addSong easier
		if (!lockedSongs.contains(name)) {return true;}
		if(unlocks.exists(name) && unlocks.get(name)) {
			return true;
		}
		return false;
	}

	public static function loadSave():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.unlocks != null) {
				unlocks = FlxG.save.data.unlocks;
			}
			else {
				unlocks = new Map<String, Bool>();
			}
		}
	}

	public static function saveData():Void {
		FlxG.save.data.unlocks = unlocks;
		FlxG.save.flush();

		
	}
}*/

class NewChallenger extends FlxSprite {
	public var song:String = '';

	//public var onFinish:Void->Void = null;

	public function new(?camera:FlxCamera = null)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('NewChallenger');
		animation.addByPrefix('idle', "NewChallenger", 24);
		animation.play('idle', true);
		scrollFactor.set(0,0);
		antialiasing = false;
		setGraphicSize(-1, 50);
		updateHitbox();
		screenCenter(XY);
		cameras = (camera != null) ? [camera] : FlxCamera.defaultCameras;
		visible = false;
	}

	public function appear(?onFinish:Void->Void = null, ?vis:Bool = true, ?silent:Bool = false) {
		visible = vis;
		animation.play('idle', true);
		var riff = FlxG.sound.play(Paths.sound('GuitarRiff'), silent ? 0.0 : 0.7);
		riff.onComplete = onFinish;
	}

	public function challenge(song:String, ?diff:Int = 1, ?beforeYouGo:Void->Void = null, ?vis:Bool = true, ?silent:Bool = false) {
		var postRiff:Void->Void = function() {
			if (beforeYouGo != null) {beforeYouGo();}

			PlayState.isStoryMode = false;
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

			PlayState.storyDifficulty = diff;
			var jsonPath:String = song + CoolUtil.getDifficultyFilePath(diff).toLowerCase();
			
			PlayState.SONG = Song.loadFromJson(jsonPath, Paths.formatToSongPath(song));
			FlxTransitionableState.skipNextTransIn = true;

			FlxG.sound.music.volume = 0;
			FreeplayState.destroyFreeplayVocals();
			LoadingState.loadAndSwitchState(new PlayState());
		}
		appear(postRiff, vis, silent);
		//Lock.unlock(song);
	}
}