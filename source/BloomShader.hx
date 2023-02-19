package;

import openfl.filters.ShaderFilter;
import openfl.display.Shader;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class BloomShader extends FlxShader
{
	@:glFragmentSource('#pragma header

//BLOOM SHADER BY BBPANZU

const float amount = 2.0;

// GAUSSIAN BLUR SETTINGS
const float dim = 1.5;
const float Directions = 16.0;
const float Quality = 8.0;
const float Size = 18.0;
vec2 Radius = Size/openfl_TextureSize.xy;
void main(void)
{
	vec2 uv = openfl_TextureCoordv.xy ;
	const float Pi = 6.28318530718; // Pi*2
	vec4 Color = texture2D( bitmap, uv);

	for( float d=0.0; d<Pi; d+=Pi/Directions){
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality){
			Color += flixel_texture2D( bitmap, uv+vec2(cos(d),sin(d))*Size*i/openfl_TextureSize.xy);
		}
	}

	Color /= (dim * Quality) * Directions - 15.0;
	vec4 bloom = (flixel_texture2D(bitmap, uv)/ dim)+Color;

	gl_FragColor = bloom;
}')

	public function new()
	{
		super();
	}
}