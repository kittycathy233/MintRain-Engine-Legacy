package backend;

import backend.Song;
import backend.Section;
import objects.Note;

typedef BPMChangeEvent =
{
    var stepTime:Int;
    var songTime:Float;
    var bpm:Float;
    @:optional var stepCrochet:Float;
}

class Conductor
{
    public static var bpm(default, set):Float = 100;
    public static var crochet:Float = ((60 / bpm) * 1000); // 每拍的毫秒数
    public static var stepCrochet:Float = crochet / 4; // 每步的毫秒数
    public static var songPosition:Float = 0;
    public static var offset:Float = 0;

    public static var safeZoneOffset:Float = 0; // 安全区域的偏移量，单位为毫秒

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    /**
     * 根据时间差判断音符的评分
     * @param arr 评分数组
     * @param diff 时间差
     * @return 返回对应的评分
     */
    public static function judgeNote(arr:Array<Rating>, diff:Float=0):Rating
    {
        var data:Array<Rating> = arr;
        for(i in 0...data.length-1) // 跳过最后一个窗口（Shit）
            if (diff <= data[i].hitWindow)
                return data[i];

        return data[data.length - 1];
    }

    /**
     * 根据时间获取当前的拍子
     * @param time 时间
     * @return 返回当前的拍子
     */
    public static function getCrotchetAtTime(time:Float){
        var lastChange = getBPMFromSeconds(time);
        return lastChange.stepCrochet * 4;
    }

    /**
     * 根据时间获取当前的BPM
     * @param time 时间
     * @return 返回当前的BPM
     */
    public static function getBPMFromSeconds(time:Float){
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: bpm,
            stepCrochet: stepCrochet
        }
        for (i in 0...Conductor.bpmChangeMap.length)
        {
            if (time >= Conductor.bpmChangeMap[i].songTime)
                lastChange = Conductor.bpmChangeMap[i];
        }

        return lastChange;
    }

    /**
     * 根据步数获取当前的BPM
     * @param step 步数
     * @return 返回当前的BPM
     */
    public static function getBPMFromStep(step:Float){
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: bpm,
            stepCrochet: stepCrochet
        }
        for (i in 0...Conductor.bpmChangeMap.length)
        {
            if (Conductor.bpmChangeMap[i].stepTime <= step)
                lastChange = Conductor.bpmChangeMap[i];
        }

        return lastChange;
    }

    /**
     * 将拍子转换为秒
     * @param beat 拍子
     * @return 返回对应的秒数
     */
    public static function beatToSeconds(beat:Float): Float{
        var step = beat * 4;
        var lastChange = getBPMFromStep(step);
        return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000;
    }

    /**
     * 根据时间获取当前的步数
     * @param time 时间
     * @return 返回当前的步数
     */
    public static function getStep(time:Float){
        var lastChange = getBPMFromSeconds(time);
        return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
    }

    /**
     * 根据时间获取当前的步数（四舍五入）
     * @param time 时间
     * @return 返回当前的步数
     */
    public static function getStepRounded(time:Float){
        var lastChange = getBPMFromSeconds(time);
        return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
    }

    /**
     * 根据时间获取当前的拍子
     * @param time 时间
     * @return 返回当前的拍子
     */
    public static function getBeat(time:Float){
        return getStep(time) / 4;
    }

    /**
     * 根据时间获取当前的拍子（四舍五入）
     * @param time 时间
     * @return 返回当前的拍子
     */
    public static function getBeatRounded(time:Float):Int{
        return Math.floor(getStepRounded(time) / 4);
    }

    /**
     * 映射BPM变化
     * @param song 歌曲
     */
    public static function mapBPMChanges(song:SwagSong)
    {
        bpmChangeMap = [];

        var curBPM:Float = song.bpm;
        var totalSteps:Int = 0;
        var totalPos:Float = 0;
        for (i in 0...song.notes.length)
        {
            if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
            {
                curBPM = song.notes[i].bpm;
                var event:BPMChangeEvent = {
                    stepTime: totalSteps,
                    songTime: totalPos,
                    bpm: curBPM,
                    stepCrochet: calculateCrochet(curBPM) / 4
                };
                bpmChangeMap.push(event);
            }

            var deltaSteps:Int = Math.round(getSectionBeats(song, i) * 4);
            totalSteps += deltaSteps;
            totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
        }
        trace("new BPM map BUDDY " + bpmChangeMap);
    }

    /**
     * 获取指定部分的拍子数
     * @param song 歌曲
     * @param section 部分
     * @return 返回拍子数
     */
    static function getSectionBeats(song:SwagSong, section:Int)
    {
        var val:Null<Float> = null;
        if(song.notes[section] != null) val = song.notes[section].sectionBeats;
        return val != null ? val : 4;
    }

    /**
     * 计算拍子的毫秒数
     * @param bpm BPM
     * @return 返回拍子的毫秒数
     */
    inline public static function calculateCrochet(bpm:Float){
        return (60 / bpm) * 1000;
    }

    /**
     * 设置BPM
     * @param newBPM 新的BPM
     * @return 返回新的BPM
     */
    public static function set_bpm(newBPM:Float):Float {
        bpm = newBPM;
        crochet = calculateCrochet(bpm);
        stepCrochet = crochet / 4;

        return bpm = newBPM;
    }
}