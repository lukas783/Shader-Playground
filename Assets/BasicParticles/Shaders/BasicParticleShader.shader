// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BasicParticleShader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_Radius("Radius?", float) = 0.01
	}
	SubShader {

		Pass {

			CGPROGRAM
			
			// The OpenGL Target we wanna hit
			#pragma target 5.0

			// declare some vertex and fragment shaders ( TODO: ADD IN #pragma geometry geom)
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			// have access to our particle struct from inside the shader
			struct Particle {
				float3 position;
				float3 velocity;
				float currTime;
				float lifeTime;
			};
		
			// default vertex/fragment stuff 
			struct PS_IN {
				float4 position : SV_POSITION;
				float4 color : COLOR;
			};

			struct G_OUT {
				float4 position : SV_POSITION;
				float4 color : COLOR;
			};
	
			// access our array of particles from inside the shader 
			StructuredBuffer<Particle> particleBuffer;

			uniform float4 _Color;

			// the fragment shadser, this passes the color through and sets the position of our particle
			PS_IN vert(uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID) {
				PS_IN o = (PS_IN)0;

				o.color = _Color;
				o.position = UnityObjectToClipPos(float4(particleBuffer[instance_id].position, 1.0f));
				return o;
			}
			
			static const fixed SQRT3_6 = sqrt(3) / 6;

			float _Radius;
			[maxvertexcount(3)]
			void geom(point PS_IN i[1], inout TriangleStream<G_OUT> outStream) {
				G_OUT g_out;
				
				float a = _ScreenParams.x / _ScreenParams.y; 
				float s = _Radius;
				float s2 = s * SQRT3_6 * a;

				g_out.color = i[0].color * _Color;
				g_out.position = i[0].position + float4(0,s2*2,0,0);
				outStream.Append(g_out);
				g_out.position = i[0].position + float4(-s*0.5f, -s2, 0, 0);
				outStream.Append(g_out);
				g_out.position = i[0].position + float4(s*0.5, -s2, 0, 0);
				outStream.Append(g_out);
				outStream.RestartStrip();
			}

			// the fragment shader, this currently just spits out the material color 
			float4 frag(G_OUT input) : COLOR
			{
				return input.color;
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
