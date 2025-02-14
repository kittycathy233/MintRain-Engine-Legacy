package options;

import states.MainMenuState;
import backend.StageData;
import flixel.addons.transition.FlxTransitionableState;
import mobile.substates.MobileControlSelectSubState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'KeyBoard Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Psych Gameplay', 'MintRain Gameplay' #if mobile , 'Mobile Options' #end];
	private var grpOptions:FlxGroup;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	var tipText:FlxText;
	var bgBlock:FlxSprite;

	var taskbar:FlxSprite;
	var startText:FlxText; // 将按钮改为 FlxText
	var startMenu:FlxSprite; // 灰色方块
	var startMenuOptions:FlxGroup; // 灰色方块内的选项

	var isStartMenuOpen:Bool = false;

	override function create() {
		trace("Entering OptionsState"); // 调试信息

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		// 背景（恢复为 menuDesat 图片，并设置为半透明）
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.5; // 设置为半透明
		add(bg);

		// 灰色方块（开始菜单）
		startMenu = new FlxSprite(0, FlxG.height).makeGraphic(Std.int(FlxG.width * 0.3), Std.int(FlxG.height * 0.35), FlxColor.fromRGB(64, 64, 64, 200)); // 灰色，20% 透明度
		startMenu.scrollFactor.set(0, 0);
		add(startMenu);

		// 灰色方块内的选项
		startMenuOptions = new FlxGroup();
		for (i in 0...options.length) {
			var optionText = new FlxText(20, startMenu.y + 10 + i * 30, 0, options[i], 24);
			optionText.setFormat(Paths.font("arturito-slab.ttf"), 24, FlxColor.WHITE, LEFT);
			optionText.scrollFactor.set(0, 0);
			startMenuOptions.add(optionText);
		}
		add(startMenuOptions);

		// 任务栏
		taskbar = new FlxSprite(0, FlxG.height - 50).makeGraphic(FlxG.width, 50, FlxColor.fromRGB(128, 128, 128, 128)); // 灰色，50% 透明度
		taskbar.scrollFactor.set(0, 0);
		add(taskbar);

		// 将“Start”文本放在最后生成
		startText = new FlxText(10, FlxG.height - 40, 0, "Start", 24);
		startText.setFormat(Paths.font("arturito-slab.ttf"), 24, FlxColor.WHITE, LEFT);
		startText.scrollFactor.set(0, 0);
		add(startText);

		// 初始状态下隐藏灰色方块和选项
		startMenu.visible = false;
		startMenuOptions.visible = false;

		// 启用鼠标可见性
		FlxG.mouse.visible = true;

		super.create();
	}

	function toggleStartMenu() {
		isStartMenuOpen = !isStartMenuOpen;

		if (isStartMenuOpen) {
			// 显示灰色方块和选项
			startMenu.visible = true;
			startMenuOptions.visible = true;

			// 灰色方块从屏幕底部滑出，最终底部与任务栏顶部对齐
			var targetY = taskbar.y - startMenu.height; // 目标 Y 坐标
			FlxTween.tween(startMenu, { y: targetY }, 0.3, { 
				ease: FlxEase.quadOut,
				onUpdate: function(tween:FlxTween) {
					// 更新选项的位置
					for (i in 0...startMenuOptions.members.length) {
						var optionText:FlxText = cast(startMenuOptions.members[i], FlxText);
						optionText.y = startMenu.y + 10 + i * 30;
					}
				}
			});
		} else {
			// 灰色方块滑回屏幕底部
			FlxTween.tween(startMenu, { y: FlxG.height }, 0.3, { 
				ease: FlxEase.quadOut,
				onUpdate: function(tween:FlxTween) {
					// 更新选项的位置
					for (i in 0...startMenuOptions.members.length) {
						var optionText:FlxText = cast(startMenuOptions.members[i], FlxText);
						optionText.y = startMenu.y + 10 + i * 30;
					}
				},
				onComplete: function(tween:FlxTween) {
					startMenu.visible = false;
					startMenuOptions.visible = false;
				}
			});
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			// 检查是否点击了“Start”文本
			if (FlxG.mouse.overlaps(startText)) {
				toggleStartMenu();
			}

			// 检查是否点击了灰色方块内的选项
			for (i in 0...startMenuOptions.members.length) {
				var optionText:FlxText = cast(startMenuOptions.members[i], FlxText);
				if (FlxG.mouse.overlaps(optionText)) {
					trace("Selected option: " + options[i]); // 调试信息
					openSelectedSubstate(options[i]);
					toggleStartMenu();
					break;
				}
			}
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	}

	function openSelectedSubstate(label:String) {
		trace("Opening substate: " + label); // 调试信息
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'KeyBoard Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
			openSubState(new options.VisualsUISubState());
			case 'Gameplay':
			openSubState(new options.GameplaySettingsSubState());
			case 'Psych Gameplay':
			openSubState(new options.GameplaySettingsSubState());
			case 'MintRain Gameplay':
			openSubState(new options.ExtraGameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Mobile Options':
				openSubState(new mobile.options.MobileOptionsSubState());
		}
	}

	override function destroy() {
		trace("Exiting OptionsState"); // 调试信息
		super.destroy();
	}
}