// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BasicParticleShader" {
	Properties {
		_Color("Color", Color) = (1,1,1,1)
	}
	SubShader {

		Pass {

			CGPROGRAM
			
			// The OpenGL Target we wanna hit
			#pragma target 5.0

			// declare some vertex and fragment shaders ( TODO: ADD IN #pragma geometry geom)
			#pragma vertex vert
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

			// the fragment shader, this currently just spits out the material color 
			float4 frag(PS_IN input) : COLOR
			{
				return input.color;
			}

			ENDCG
		}
	}
}
