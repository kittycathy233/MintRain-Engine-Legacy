package backend;

import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import openfl.utils.Assets;
import flixel.FlxObject;

import states.MainMenuState;

class CustomFadeTransition extends FlxSubState {
    public static var finishCallback: Void -> Void;
    var isTransIn: Bool = false;
    var transBlack: FlxSprite;
    var transGradient: FlxSprite;
    var duration: Float;

    var loadLeft: FlxSprite;
    var loadRight: FlxSprite;
    var loadAlpha: FlxSprite;
    var WaterMark: FlxText;
    var EventText: FlxText;
    var transBG: FlxSprite;
    
	var baLoadingPics:FlxSprite;
    var baLoadingPicTween: FlxTween;

    var loadLeftTween: FlxTween;
    var loadRightTween: FlxTween;
    var loadAlphaTween: FlxTween;
    var EventTextTween: FlxTween;
    var loadTextTween: FlxTween;

    public function new(duration: Float, isTransIn: Bool) {
        this.duration = duration;
        this.isTransIn = isTransIn;
        super();
    }

    override function create() {
        
        var cam: FlxCamera = new FlxCamera();
        cam.bgColor = 0x00;
        FlxG.cameras.add(cam, false);

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        
        // 原版
        var width: Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
        var height: Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));

        if (ClientPrefs.data.customFadeStyle == 'NovaFlare') {
            loadRight = new FlxSprite(isTransIn ? 0 : 1280, 0).loadGraphic(Paths.image('menuExtend/CustomFadeTransition/loadingR'));
            loadRight.scrollFactor.set();
            loadRight.antialiasing = ClientPrefs.data.antialiasing;        
            add(loadRight);
            loadRight.setGraphicSize(FlxG.width, FlxG.height);
            loadRight.updateHitbox();
            
            loadLeft = new FlxSprite(isTransIn ? 0 : -1280, 0).loadGraphic(Paths.image('menuExtend/CustomFadeTransition/loadingL'));
            loadLeft.scrollFactor.set();
            loadLeft.antialiasing = ClientPrefs.data.antialiasing;
            add(loadLeft);
            loadLeft.setGraphicSize(FlxG.width, FlxG.height);
            loadLeft.updateHitbox();
            
            WaterMark = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50 * 2, 0, 'MINTRAIN ENGINE V' + MainMenuState.mintrainEngineVersion, 50);
            WaterMark.scrollFactor.set();
            WaterMark.setFormat(Assets.getFont("assets/fonts/loadText.ttf").fontName, 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            WaterMark.antialiasing = ClientPrefs.data.antialiasing;
            add(WaterMark);
            
            EventText = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50, 0, 'LOADING . . . . . . ', 50);
            EventText.scrollFactor.set();
            EventText.setFormat(Assets.getFont("assets/fonts/loadText.ttf").fontName, 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            EventText.antialiasing = ClientPrefs.data.antialiasing;
            add(EventText);
            
            if (!isTransIn) {
                try {
                    FlxG.sound.play(Paths.sound('NFE/loading_close_move')/*,ClientPrefs.data.CustomFadeSound*/);
                } catch (e: Dynamic) {}

                if (!ClientPrefs.data.CustomFadeText) {
                    EventText.text = '';
                    WaterMark.text = '';
                }

                loadLeftTween = FlxTween.tween(loadLeft, {x: 0}, duration, {
                    onComplete: function(twn: FlxTween) {
                        if (finishCallback != null) {
                            finishCallback();
                        }
                    },
                    ease: FlxEase.expoInOut
                });

                loadRightTween = FlxTween.tween(loadRight, {x: 0}, duration, {
                    onComplete: function(twn: FlxTween) {
                        if (finishCallback != null) {
                            finishCallback();
                        }
                    },
                    ease: FlxEase.expoInOut
                });

                loadTextTween = FlxTween.tween(WaterMark, {x: 50}, duration, {
                    onComplete: function(twn: FlxTween) {
                        if (finishCallback != null) {
                            finishCallback();
                        }
                    },
                    ease: FlxEase.expoInOut
                });

                EventTextTween = FlxTween.tween(EventText, {x: 50}, duration, {
                    onComplete: function(twn: FlxTween) {
                        if (finishCallback != null) {
                            finishCallback();
                        }
                    },
                    ease: FlxEase.expoInOut
                });

            } else {
                try {
                    FlxG.sound.play(Paths.sound('NFE/loading_open_move')/*,ClientPrefs.data.CustomFadeSound*/);
                } catch (e: Dynamic) {}

                EventText.text = 'COMPLETED !';

                loadLeftTween = FlxTween.tween(loadLeft, {x: -1280}, duration, {
                    onComplete: function(twn: FlxTween) {
                        close();
                    },
                    ease: FlxEase.expoInOut
                });

                loadRightTween = FlxTween.tween(loadRight, {x: 1280}, duration, {
                    onComplete: function(twn: FlxTween) {
                        close();
                    },
                    ease: FlxEase.expoInOut
                });

                loadTextTween = FlxTween.tween(WaterMark, {x: -1230}, duration, {
                    onComplete: function(twn: FlxTween) {
                        close();
                    },
                    ease: FlxEase.expoInOut
                });

                EventTextTween = FlxTween.tween(EventText, {x: -1230}, duration, {
                    onComplete: function(twn: FlxTween) {
                        close();
                    },
                    ease: FlxEase.expoInOut
                });
            }
        } else if (ClientPrefs.data.customFadeStyle == 'Vanilla') {
            transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
            transGradient.scale.x = width;
            transGradient.updateHitbox();
            transGradient.scrollFactor.set();
            transGradient.screenCenter(X);
            add(transGradient);

            transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
            transBlack.scale.set(width, height + 400);
            transBlack.updateHitbox();
            transBlack.scrollFactor.set();
            transBlack.screenCenter(X);
            add(transBlack);

            if (isTransIn)
                transGradient.y = transBlack.y - transBlack.height;
            else
                transGradient.y = -transGradient.height;
        } else if (ClientPrefs.data.customFadeStyle == 'MintRain') {
            // 动态获取目录下的所有PNG图片
            var imagePathPrefix = "menuExtend/CustomFadeTransition/Blue_Archive/CN/";
            var availableImages = [];
            
            // 遍历所有图片资源
            for (asset in Assets.list(IMAGE)) {
                // 提取相对路径并检查前缀和扩展名
                if (asset.startsWith("assets/images/")) {
                    var relativePath = asset.substring("assets/images/".length);
                    if (relativePath.startsWith(imagePathPrefix) && relativePath.endsWith(".png")) {
                        var imageName = relativePath.substring(0, relativePath.length - 4); // 移除.png扩展名
                        availableImages.push(imageName);
                    }
                }
            }
            
            // 如果没有找到图片，使用默认
            if (availableImages.length == 0) {
                availableImages.push('menuExtend/CustomFadeTransition/Blue_Archive/CN/LoadingImage_44_Kr');
            }
            
            // 随机选择图片
            var selectedImage = availableImages[Std.random(availableImages.length)];
            
            transBG = new FlxSprite().loadGraphic(Paths.image('menuExtend/CustomFadeTransition/Login_Pad_BG'));
            transBG.scrollFactor.set();
            transBG.antialiasing = ClientPrefs.data.antialiasing;
            add(transBG);
            transBG.setGraphicSize(FlxG.width, FlxG.height);
            transBG.updateHitbox();      
           
            baLoadingPics = new FlxSprite().loadGraphic(Paths.image(selectedImage)); // 加载随机图片
            baLoadingPics.scrollFactor.set();
            baLoadingPics.antialiasing = ClientPrefs.data.antialiasing;
            add(baLoadingPics);
            baLoadingPics.setGraphicSize(FlxG.width, FlxG.height);
            baLoadingPics.updateHitbox();
            baLoadingPics.scale.set(1, 1.2);
        
            if (!isTransIn) {
                // 渐显逻辑保持不变
                baLoadingPics.alpha = 0;
                FlxG.sound.play(Paths.sound('BA/UI_Loading'));
        
                baLoadingPicTween = FlxTween.tween(baLoadingPics, {alpha: 1}, 0.4, {
                    onComplete: function(twn: FlxTween) {
                        if (finishCallback != null) finishCallback();
                    },
                    ease: FlxEase.quartOut
                });
            } else {
                // 渐隐逻辑保持不变
                FlxG.sound.play(Paths.sound('BA/UI_Login'));
        
                baLoadingPicTween = FlxTween.tween(baLoadingPics, {alpha: 0}, 0.4, {
                    onComplete: function(twn: FlxTween) {
                        close();
                    },
                    ease: FlxEase.linear
                });
            }
        }

        super.create();
    }

    override function update(elapsed: Float) {
        if (ClientPrefs.data.customFadeStyle == 'Vanilla') {
            super.update(elapsed);

            final height: Float = FlxG.height * Math.max(camera.zoom, 0.001);
            final targetPos: Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);

            if (duration > 0)
                transGradient.y += (height + targetPos) * elapsed / duration;
            else
                transGradient.y = (targetPos) * elapsed;

            if (isTransIn)
                transBlack.y = transGradient.y + transGradient.height;
            else
                transBlack.y = transGradient.y - transBlack.height;

            if (transGradient.y >= targetPos) {
                close();
                if (finishCallback != null) finishCallback();
                finishCallback = null;
            }
        } else if (ClientPrefs.data.customFadeStyle == 'MintRain') {
            transBG.alpha = baLoadingPics.alpha;
           /* if (baLoadingPics.alpha <= 0) {
                close();
                if (finishCallback != null) finishCallback();
                finishCallback = null;
            }
*/
			/*//还没改
            super.update(elapsed);

            final height: Float = FlxG.height * Math.max(camera.zoom, 0.001);
            final targetPos: Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);

            if (duration > 0)
                transGradient.y += (height + targetPos) * elapsed / duration;
            else
                transGradient.y = (targetPos) * elapsed;

            if (isTransIn)
                transBlack.y = transGradient.y + transGradient.height;
            else
                transBlack.y = transGradient.y - transBlack.height;

            if (transGradient.y >= targetPos) {
                close();
                if (finishCallback != null) finishCallback();
                finishCallback = null;
            }*/
        }
    }
}