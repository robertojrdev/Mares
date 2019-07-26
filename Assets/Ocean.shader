// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "g"
{
	Properties
	{
		_WaterColor("Water Color", Color) = (0.2,0.282353,0.5490196,1)
		_TopColor("Top Color", Color) = (0.2431373,0.5333334,0.7058824,1)
		_WaveTile("Wave Tile", Float) = 1
		_Wavedirection("Wave direction", Vector) = (-1,0,0,0)
		_Wavestretch("Wave stretch", Vector) = (0.15,0.02,0,0)
		_WaveSped("Wave Sped", Float) = 1
		_WaveHeight("Wave Height", Float) = 1
		_Smoothness("Smoothness", Float) = 0.9
		_smallwavesheight("small waves height", Float) = 0.4
		_EdgeDistance("Edge Distance", Float) = 0.5
		_EdgePower("Edge Power", Float) = 0
		_NormalMapTexture("Normal Map Texture", 2D) = "white" {}
		_NormalMapIntensity("Normal Map Intensity", Range( -2 , 2)) = 1
		_NormalDirection1("Normal Direction 1", Vector) = (0,1,0,0)
		_NormalMapTile("Normal Map Tile", Float) = 1
		_NormalSpeed1("Normal Speed 1", Float) = 0.4
		_NormalMapIntensity2("Normal Map Intensity 2", Range( -2 , 2)) = 1
		_NormalDirection2("Normal Direction 2", Vector) = (0,-1,0,0)
		_NormalMaptile2("Normal Map tile 2", Float) = 5
		_NormalSpeed2("Normal Speed 2", Float) = 0.5
		_SeaFoam("Sea Foam", 2D) = "white" {}
		_SeaFoamTile("Sea Foam Tile", Float) = 1
		_SeaFoamIntensity("Sea Foam Intensity", Range( 0 , 1)) = 1
		_SeaFoamSpeed("Sea Foam Speed", Vector) = (0.1,0.1,0,0)
		_EdgeFoamTile("Edge Foam Tile", Float) = 1
		_FoamMaskTile("Foam Mask Tile", Float) = 1
		_FoamMaskSPeed("Foam Mask SPeed", Vector) = (0.5,0.5,0,0)
		_Vector0("Vector 0", Vector) = (-0.04,0,0,0)
		_RefractAmmoumt("Refract Ammoumt", Float) = 0.1
		_Depth("Depth", Float) = -3
		_Tesselation("Tesselation", Float) = 8
		_MinMaxTesselation("Min Max Tesselation", Vector) = (0,80,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WaveHeight;
		uniform float _WaveSped;
		uniform float2 _Wavedirection;
		uniform float2 _Wavestretch;
		uniform float _WaveTile;
		uniform float _smallwavesheight;
		uniform sampler2D _NormalMapTexture;
		uniform float _NormalMapIntensity;
		uniform float2 _NormalDirection1;
		uniform float _NormalSpeed1;
		uniform float _NormalMapTile;
		uniform float _NormalMapIntensity2;
		uniform float _NormalSpeed2;
		uniform float2 _NormalDirection2;
		uniform float _NormalMaptile2;
		uniform float4 _WaterColor;
		uniform float4 _TopColor;
		uniform sampler2D _SeaFoam;
		uniform float2 _SeaFoamSpeed;
		uniform float _SeaFoamTile;
		uniform float2 _FoamMaskSPeed;
		uniform float _FoamMaskTile;
		uniform float _SeaFoamIntensity;
		uniform sampler2D _GrabTexture;
		uniform float _RefractAmmoumt;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _EdgePower;
		uniform float _EdgeDistance;
		uniform float2 _Vector0;
		uniform float _EdgeFoamTile;
		uniform float _Smoothness;
		uniform float2 _MinMaxTesselation;
		uniform float _Tesselation;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _MinMaxTesselation.x,_MinMaxTesselation.y,_Tesselation);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_6_0 = ( _Time.y * _WaveSped );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult15 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTIle16 = appendResult15;
			float4 WaveTileUV26 = ( ( WorldSpaceTIle16 * float4( _Wavestretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( temp_output_6_0 * _Wavedirection + WaveTileUV26.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner30 = ( temp_output_6_0 * _Wavedirection + ( WaveTileUV26 * _smallwavesheight ).xy);
			float simplePerlin2D29 = snoise( panner30 );
			float temp_output_32_0 = ( simplePerlin2D1 + simplePerlin2D29 );
			float3 WaveHeight38 = ( ( float3(0,1,0) * _WaveHeight * 0.01 ) * temp_output_32_0 );
			v.vertex.xyz += WaveHeight38;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult15 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTIle16 = appendResult15;
			float2 panner76 = ( 1.0 * _Time.y * ( _NormalDirection1 * _NormalSpeed1 * 0.001 ) + ( WorldSpaceTIle16 * _NormalMapTile * 0.001 ).xy);
			float2 panner77 = ( 1.0 * _Time.y * ( _NormalSpeed2 * _NormalDirection2 * 0.001 ) + ( WorldSpaceTIle16 * _NormalMaptile2 * 0.001 ).xy);
			float3 NormalMapR86 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMapTexture, panner76 ), _NormalMapIntensity ) , UnpackScaleNormal( tex2D( _NormalMapTexture, panner77 ), _NormalMapIntensity2 ) );
			o.Normal = NormalMapR86;
			float2 panner121 = ( 1.0 * _Time.y * _SeaFoamSpeed + ( WorldSpaceTIle16 * _SeaFoamTile * 0.01 ).xy);
			float2 panner112 = ( 1.0 * _Time.y * _FoamMaskSPeed + ( WorldSpaceTIle16 * _FoamMaskTile ).xy);
			float simplePerlin2D111 = snoise( panner112 );
			float FoamMask115 = simplePerlin2D111;
			float4 clampResult119 = clamp( ( tex2D( _SeaFoam, panner121 ) * FoamMask115 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 SeaFoam107 = ( clampResult119 * _SeaFoamIntensity );
			float temp_output_6_0 = ( _Time.y * _WaveSped );
			float4 WaveTileUV26 = ( ( WorldSpaceTIle16 * float4( _Wavestretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( temp_output_6_0 * _Wavedirection + WaveTileUV26.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner30 = ( temp_output_6_0 * _Wavedirection + ( WaveTileUV26 * _smallwavesheight ).xy);
			float simplePerlin2D29 = snoise( panner30 );
			float temp_output_32_0 = ( simplePerlin2D1 + simplePerlin2D29 );
			float WavePattern35 = temp_output_32_0;
			float clampResult53 = clamp( WavePattern35 , 0.0 , 1.0 );
			float4 lerpResult49 = lerp( _WaterColor , ( _TopColor + SeaFoam107 ) , clampResult53);
			float4 Albedo55 = lerpResult49;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor130 = tex2D( _GrabTexture, ( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( _RefractAmmoumt * NormalMapR86 ) ).xy );
			float4 clampResult131 = clamp( screenColor130 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Refraction132 = clampResult131;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth137 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth137 = abs( ( screenDepth137 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult138 = clamp( ( 1.0 - distanceDepth137 ) , 0.0 , 1.0 );
			float Depth139 = clampResult138;
			float4 lerpResult140 = lerp( Albedo55 , Refraction132 , Depth139);
			o.Albedo = lerpResult140.rgb;
			float screenDepth62 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth62 = abs( ( screenDepth62 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float2 panner146 = ( 1.0 * _Time.y * _Vector0 + ( WorldSpaceTIle16 * _EdgeFoamTile * 0.01 ).xy);
			float4 clampResult69 = clamp( ( _EdgePower * ( ( 1.0 - distanceDepth62 ) + tex2D( _SeaFoam, panner146 ) ) ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Edge67 = clampResult69;
			o.Emission = Edge67.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16400
0;73.6;930;480;120.1185;-3059.211;1.895832;True;False
Node;AmplifyShaderEditor.CommentaryNode;17;-2566.211,-1727.867;Float;False;710.7573;230.2934;;3;14;15;16;World Space UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;14;-2516.211,-1674.974;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2278.58,-1677.867;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2109.055,-1660.108;Float;False;WorldSpaceTIle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;28;-2556.086,-1304.644;Float;False;977.4886;368.7475;;6;19;20;21;22;18;26;Wave Tile UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;19;-2491.11,-1052.145;Float;False;Property;_Wavestretch;Wave stretch;4;0;Create;True;0;0;False;0;0.15,0.02;5,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;18;-2506.086,-1254.644;Float;False;16;WorldSpaceTIle;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;120;-197.6643,3874.896;Float;False;1448.806;392.01;Comment;8;119;118;115;111;112;117;113;114;Foam Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;108;-198.5325,3320.388;Float;False;1650.225;398.1128;;10;107;102;105;104;103;106;121;123;148;149;Sea Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-2899.72,2695.915;Float;False;2344.958;1072.848;Comment;22;46;70;76;77;75;80;84;83;82;78;79;85;71;59;58;60;74;61;73;86;89;90;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-148.5325,3408.16;Float;False;16;WorldSpaceTIle;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2222.835,-1074.357;Float;False;Property;_WaveTile;Wave Tile;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2232.233,-1239.712;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-158.6292,4047.149;Float;False;Property;_FoamMaskTile;Foam Mask Tile;25;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-2783.296,3251.049;Float;False;Constant;_Nromalizernmaptile;Nromalizer nmaptile;21;0;Create;True;0;0;False;0;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2822.002,3129.472;Float;False;Property;_NormalMaptile2;Normal Map tile 2;18;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-137.1296,3598.873;Float;False;Constant;_Float2;Float 2;22;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-139.4319,3501.05;Float;False;Property;_SeaFoamTile;Sea Foam Tile;21;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;38.24391,3957.796;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2523.192,3516.053;Float;False;Property;_NormalSpeed2;Normal Speed 2;19;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;117;-51.694,4129.038;Float;False;Property;_FoamMaskSPeed;Foam Mask SPeed;26;0;Create;True;0;0;False;0;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2818.515,2964.339;Float;False;16;WorldSpaceTIle;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2809.929,2842.208;Float;False;Property;_NormalMapTile;Normal Map Tile;14;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2685.559,3449.507;Float;False;Constant;_normalizesize;normalize size ;21;0;Create;True;0;0;False;0;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;79;-2530.529,3608.963;Float;False;Property;_NormalDirection2;Normal Direction 2;17;0;Create;True;0;0;False;0;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2008.538,-1186.063;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;78;-2530.822,3274.607;Float;False;Property;_NormalDirection1;Normal Direction 1;13;0;Create;True;0;0;False;0;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;82;-2519.332,3408.957;Float;False;Property;_NormalSpeed1;Normal Speed 1;15;0;Create;True;0;0;False;0;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-172.4152,2429.273;Float;False;1103.828;729.696;;9;93;96;95;94;91;92;97;146;147;Edge Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-2247.287,3448.72;Float;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;123;104.8465,3582.04;Float;False;Property;_SeaFoamSpeed;Sea Foam Speed;23;0;Create;True;0;0;False;0;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;112;221.1605,3955.523;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;180.5061,3403.228;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;44;-2812.664,242.3976;Float;False;1623.577;831.2086;;13;1;29;32;3;35;4;31;6;34;5;13;27;30;Wave Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2515.995,3045.102;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1781.482,-1188.39;Float;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2506.777,2824.97;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2249.697,3279.465;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;75;-1989.678,2752.304;Float;True;Property;_NormalMapTexture;Normal Map Texture;11;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;111;436.5928,3953.219;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;121;319.3577,3517.136;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2570.835,947.9713;Float;False;26;WaveTileUV;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;76;-1957.687,3022.33;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;91;93.70345,2525.883;Float;True;Property;_SeaFoam;Sea Foam;20;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2371.102,1024.416;Float;False;Property;_smallwavesheight;small waves height;8;0;Create;True;0;0;False;0;0.4;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;77;-1959.937,3191.034;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;5;-2758.741,816.7982;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1704.948,3176.566;Float;False;Property;_NormalMapIntensity;Normal Map Intensity;12;0;Create;True;0;0;False;0;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2748.323,952.9814;Float;False;Property;_WaveSped;Wave Sped;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1699.403,3398.646;Float;False;Property;_NormalMapIntensity2;Normal Map Intensity 2;16;0;Create;True;0;0;False;0;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2344.256,874.9081;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;70;-1428.527,3312.804;Float;True;Property;_Normal2;Normal 2;7;0;Create;True;0;0;False;0;08e42407d128de648b69c302253e80f0;08e42407d128de648b69c302253e80f0;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;4;-2727.843,543.3122;Float;False;Property;_Wavedirection;Wave direction;3;0;Create;True;0;0;False;0;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2692.174,292.3976;Float;False;26;WaveTileUV;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;46;-1434.377,3093.364;Float;True;Property;_Normal1;Normal 1;7;0;Create;True;0;0;False;0;08e42407d128de648b69c302253e80f0;08e42407d128de648b69c302253e80f0;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;659.5366,3953.98;Float;False;FoamMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;505.4529,3370.388;Float;True;Property;_TextureSample1;Texture Sample 1;22;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-2552.515,736.9334;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;30;-2146.205,731.3185;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;85;-1088.507,3190.178;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;3;-2140.384,385.931;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;910.9854,3929.924;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1867.183,447.7287;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;-2774.631,4248.481;Float;False;1394.318;505.4248;;9;125;132;131;130;129;127;124;128;126;Refraction;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;149;794.7983,3544.699;Float;False;Property;_SeaFoamIntensity;Sea Foam Intensity;22;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;119;1057.267,3928.552;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;98;95.61406,2013.112;Float;False;1517.509;315.7502;;7;66;69;67;65;63;62;64;Edge Detection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-113.3146,2946.546;Float;False;Property;_EdgeFoamTile;Edge Foam Tile;24;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-794.7617,3185.798;Float;False;NormalMapR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-122.4152,2853.656;Float;False;16;WorldSpaceTIle;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-111.0123,3044.369;Float;False;Constant;_Float1;Float 1;22;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;29;-1859.376,684.985;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;1074.758,3527.322;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;206.6235,2848.724;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1624.428,598.708;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;145.6141,2186.812;Float;False;Property;_EdgeDistance;Edge Distance;9;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;147;167.5598,2995.719;Float;False;Property;_Vector0;Vector 0;27;0;Create;True;0;0;False;0;-0.04,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;126;-2682.08,4544.61;Float;False;Property;_RefractAmmoumt;Refract Ammoumt;28;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-2685.9,4639.306;Float;False;86;NormalMapR;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;124;-2724.631,4298.481;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;56;-2829.906,1421.164;Float;False;1127.458;811.377;;8;110;109;47;48;53;52;55;49;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.DepthFade;62;372.1981,2196.664;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-2432.978,4541.959;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;125;-2408.803,4298.732;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2430.224,4911.525;Float;False;Property;_Depth;Depth;29;0;Create;True;0;0;False;0;-3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;1191.582,3380.261;Float;False;SeaFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1404.275,586.7302;Float;False;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;146;382.0712,2930.814;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;64;647.628,2178.624;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;-2195.9,4444.306;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;92;555.1865,2673.165;Float;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2671.063,2015.11;Float;False;35;WavePattern;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2555.24,-653.7128;Float;False;1130.88;632.6469;;6;24;38;37;25;36;42;Wave Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2668.101,1878.886;Float;False;107;SeaFoam;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;137;-2226.124,4897.226;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-2702.202,1656.489;Float;False;Property;_TopColor;Top Color;1;0;Create;True;0;0;False;0;0.2431373,0.5333334,0.7058824,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-2311.935,-278.6659;Float;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;53;-2379.771,1970.769;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;130;-1996.014,4400.626;Float;False;Global;_GrabScreen0;Grab Screen 0;28;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;97;775.813,2479.273;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;143;-1964.673,4917.725;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;675.2796,2063.113;Float;False;Property;_EdgePower;Edge Power;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;47;-2705.03,1475.784;Float;False;Property;_WaterColor;Water Color;0;0;Create;True;0;0;False;0;0.2,0.282353,0.5490196,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-2431.052,1769.029;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;24;-2341.723,-603.7128;Float;False;Constant;_WaveUp;Wave Up;3;0;Create;True;0;0;False;0;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;36;-2505.24,-355.5335;Float;False;Property;_WaveHeight;Wave Height;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;131;-1786.714,4424.026;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2096.637,-405.2276;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;49;-2274.36,1564.122;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;138;-1814.024,4894.927;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;893.3373,2092.717;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1874.011,-405.7695;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-1620.314,4442.226;Float;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1942.447,1567.958;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;69;1107.125,2094.251;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-1644.424,4894.026;Float;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;1373.123,2069.803;Float;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1664.36,-412.3061;Float;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-693.6337,613.6736;Float;False;Property;_Tesselation;Tesselation;30;0;Create;True;0;0;False;0;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-494.5556,-304.9067;Float;False;55;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-514.4614,-222.7213;Float;False;132;Refraction;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-483.4614,-145.7213;Float;False;139;Depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;145;-697.0792,695.8657;Float;False;Property;_MinMaxTesselation;Min Max Tesselation;31;0;Create;True;0;0;False;0;0,80;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;116;-272.4025,880.2858;Float;False;115;FoamMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-596.7439,452.5213;Float;False;38;WaveHeight;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-214.6959,645.2843;Float;False;67;Edge;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;144;-480.6242,565.6094;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;140;-272.4614,-288.7213;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-266.0266,24.48685;Float;False;86;NormalMapR;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-546.8854,189.1161;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;g;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;14;1
WireConnection;15;1;14;3
WireConnection;16;0;15;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;113;0;106;0
WireConnection;113;1;114;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;84;0;83;0
WireConnection;84;1;79;0
WireConnection;84;2;89;0
WireConnection;112;0;113;0
WireConnection;112;2;117;0
WireConnection;105;0;106;0
WireConnection;105;1;104;0
WireConnection;105;2;103;0
WireConnection;74;0;58;0
WireConnection;74;1;73;0
WireConnection;74;2;90;0
WireConnection;26;0;21;0
WireConnection;60;0;58;0
WireConnection;60;1;61;0
WireConnection;60;2;90;0
WireConnection;80;0;78;0
WireConnection;80;1;82;0
WireConnection;80;2;89;0
WireConnection;111;0;112;0
WireConnection;121;0;105;0
WireConnection;121;2;123;0
WireConnection;76;0;60;0
WireConnection;76;2;80;0
WireConnection;77;0;74;0
WireConnection;77;2;84;0
WireConnection;31;0;34;0
WireConnection;31;1;54;0
WireConnection;70;0;75;0
WireConnection;70;1;77;0
WireConnection;70;5;71;0
WireConnection;46;0;75;0
WireConnection;46;1;76;0
WireConnection;46;5;59;0
WireConnection;115;0;111;0
WireConnection;102;0;91;0
WireConnection;102;1;121;0
WireConnection;6;0;5;0
WireConnection;6;1;13;0
WireConnection;30;0;31;0
WireConnection;30;2;4;0
WireConnection;30;1;6;0
WireConnection;85;0;46;0
WireConnection;85;1;70;0
WireConnection;3;0;27;0
WireConnection;3;2;4;0
WireConnection;3;1;6;0
WireConnection;118;0;102;0
WireConnection;118;1;115;0
WireConnection;1;0;3;0
WireConnection;119;0;118;0
WireConnection;86;0;85;0
WireConnection;29;0;30;0
WireConnection;148;0;119;0
WireConnection;148;1;149;0
WireConnection;94;0;93;0
WireConnection;94;1;95;0
WireConnection;94;2;96;0
WireConnection;32;0;1;0
WireConnection;32;1;29;0
WireConnection;62;0;63;0
WireConnection;127;0;126;0
WireConnection;127;1;128;0
WireConnection;125;0;124;0
WireConnection;107;0;148;0
WireConnection;35;0;32;0
WireConnection;146;0;94;0
WireConnection;146;2;147;0
WireConnection;64;0;62;0
WireConnection;129;0;125;0
WireConnection;129;1;127;0
WireConnection;92;0;91;0
WireConnection;92;1;146;0
WireConnection;137;0;136;0
WireConnection;53;0;52;0
WireConnection;130;0;129;0
WireConnection;97;0;64;0
WireConnection;97;1;92;0
WireConnection;143;0;137;0
WireConnection;109;0;48;0
WireConnection;109;1;110;0
WireConnection;131;0;130;0
WireConnection;25;0;24;0
WireConnection;25;1;36;0
WireConnection;25;2;42;0
WireConnection;49;0;47;0
WireConnection;49;1;109;0
WireConnection;49;2;53;0
WireConnection;138;0;143;0
WireConnection;66;0;65;0
WireConnection;66;1;97;0
WireConnection;37;0;25;0
WireConnection;37;1;32;0
WireConnection;132;0;131;0
WireConnection;55;0;49;0
WireConnection;69;0;66;0
WireConnection;139;0;138;0
WireConnection;67;0;69;0
WireConnection;38;0;37;0
WireConnection;144;0;23;0
WireConnection;144;1;145;1
WireConnection;144;2;145;2
WireConnection;140;0;57;0
WireConnection;140;1;142;0
WireConnection;140;2;141;0
WireConnection;0;0;140;0
WireConnection;0;1;88;0
WireConnection;0;2;68;0
WireConnection;0;4;45;0
WireConnection;0;11;39;0
WireConnection;0;14;144;0
ASEEND*/
//CHKSM=2E3D89ED76BE485C70B8BD9E56B8BCE294F51D5D