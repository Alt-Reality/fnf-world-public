package;

import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class WateryShader extends FlxBasic
{
    public var shader(default, null):FabsShaderGLSL = new FabsShaderGLSL();
    var iTime:Float = 0;

    public function new():Void{
        super();
        shader.distortTexture.input = BitmapData.fromFile(Paths.getPreloadPath('images/heatwave.png'));
    }

    override public function update(elapsed:Float):Void{
        super.update(elapsed);
        iTime += elapsed;
        shader.iTime.value = [iTime];
    }
}

class FabsShaderGLSL extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float iTime;

        uniform sampler2D distortTexture;


        void main(){
                vec2 p_m = openfl_TextureCoordv;
                vec2 p_d = p_m;

                p_d.t -= iTime * 0.05;
                p_d.t = mod(p_d.t, 1.0);

                vec4 dst_map_val = flixel_texture2D(distortTexture, p_d);

                vec2 dst_offset = dst_map_val.xy;
                dst_offset -= vec2(.5,.5);
                dst_offset *= 2.;
                dst_offset *= 0.03; //THIS CONTROLS THE INTENSITY [higher numbers = MORE WAVY] DO NOT GO ABOVE 0.2 DAWG THIS SHIT LOOK LIKE I TOOK A PERC

                //reduce effect towards Y top
                //dst_offset *= pow(p_m.t, 1.5); //THIS CONTROLS HOW HIGH UP THE SCREEN THE EFFECT GOES [higher numbers = less screen space]

                vec2 dist_tex_coord = p_m.st + dst_offset;
                gl_FragColor = flixel_texture2D(bitmap, dist_tex_coord); 
        }')

    public function new()
    {
        super();
    }
}