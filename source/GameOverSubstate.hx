package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var deathSoundName:String = 'graveSound';

	public static var instance:GameOverSubstate;

	var grave:FlxSprite;
	var gameOverText:FlxSprite;
	var gameOverTween:FlxTween;

	var graveadded:Bool;

	public static function resetVariables() {
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		deathSoundName = 'graveSound';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		Conductor.songPosition = 0;

		grave = new FlxSprite(0, 0).loadGraphic(Paths.image('grave'));
		grave.antialiasing = true;
		grave.scrollFactor.set(1.0, 1.0);
		grave.screenCenter();
		grave.y += 100;
		new FlxTimer().start(2.5, function(tmr:FlxTimer)
		{
			if(!isEnding) {
				add(grave);
				FlxG.sound.play(Paths.sound(deathSoundName));
				graveadded = true;
			}
		});
		
		gameOverText = new FlxSprite(0, 0).loadGraphic(Paths.image('gameover'));
		gameOverText.antialiasing = true;
		gameOverText.scrollFactor.set(1.0, 1.0);
		gameOverText.screenCenter();
		gameOverText.y -= 200;
		gameOverText.alpha = 0;
		add(gameOverText);

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);

		if(controls.ACCEPT) 
			endBullshit();

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new MainMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if(!playingDeathSound && graveadded)  {
			coolStartDeath();		
			playingDeathSound = true;
		}

		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(!isEnding) {
				FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
				gameOverTween = FlxTween.tween(gameOverText, {alpha: 1}, 7, {ease: FlxEase.circOut});
			}
		});
		
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			//incase they didnt finis
			//also game was crashing if u pressed enter before everything appeared so this should fix
			if(gameOverText.alpha > 0)//tween has started, so it can cancel
				gameOverTween.cancel();
			if(grave != null)//grave was added, so it can tween out
				FlxTween.tween(grave, {alpha: 0}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(gameOverText, {alpha: 0}, 2, {ease: FlxEase.circOut});
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	/*function goToNightmare():Void
	{
		if (!isEnding)
		{
			var poop:String = Highscore.formatSong('hot-dilf', 1);
			PlayState.SONG = Song.loadFromJson(poop, 'hot-dilf');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;

			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}*/
}
