package options;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.addons.editors.spine.FlxSpine;
import flixel.addons.editors.spine.texture.FlixelTextureLoader;
import flixel.FlxAssets;
import spinehaxe.animation.Animation;
import spinehaxe.AnimationState;

class SpineAnimationState extends MusicBeatState
{
    var spineBoy:FlxSpine;
    var animationController:AnimationState;

    override function create() {
        super.create();

        // 加载 Spine 动画
        spineBoy = new FlxSpine();
        spineBoy.data = FlxAssets.loadSpineData("assets/spine/spineboy.json");
        spineBoy.textureLoader = new FlixelTextureLoader(flixel.util.loaders.TextureRegionType.IMAGE);

        // 设置位置和缩放
        spineBoy.x = FlxG.width / 2;
        spineBoy.y = FlxG.height / 2;
        spineBoy.scale.set(0.6, 0.6);

        // 初始化动画控制器
        animationController = spineBoy.state;

        // 播放动画
        spineBoy.skeleton.setToSetupPose();
        var walkAnimation:Animation = spineBoy.skeleton.data.findAnimation("walk");
        animationController.setAnimation(0, walkAnimation, true);

        add(spineBoy);

        // 添加返回提示
        var text = new FlxText(20, 20, 0, "Press SPACE to play jump\nPress ESC to return", 16);
        add(text);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            // 触发跳跃动画
            var jumpAnimation:Animation = spineBoy.skeleton.data.findAnimation("jump");
            animationController.setAnimation(0, jumpAnimation, false);
            animationController.addAnimation(0, walkAnimation, true, 0);
        }

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new OptionsState());
        }
    }
}