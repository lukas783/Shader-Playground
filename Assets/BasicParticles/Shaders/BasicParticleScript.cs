using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicParticleScript : MonoBehaviour {

    // a particle structure
    private struct Particle {
        public Vector3 position;
        public Vector3 velocity;
        public float currTime;
        public float lifeTime;
    }

    public int particleCount = 3000000;

    public Material material;
    public ComputeShader computeShader;

    ComputeBuffer particleBuffer;
    private int kernelID;

    // set up the array of particles
	void Start () {
		if(particleCount <= 0) {
            particleCount = 1;
        }

        Particle[] particleArray = new Particle[particleCount];
        for(int i = 0; i < particleCount; i++) {
            particleArray[i].position.x = 0;
            particleArray[i].position.y = 10;
            particleArray[i].position.z = 0;

            particleArray[i].velocity.x = Random.value * 0.1f - Random.value * 0.1f;
            particleArray[i].velocity.y = Random.value * 0.1f - Random.value * 0.1f;
            particleArray[i].velocity.z = Random.value * 0.1f - Random.value * 0.1f;

            particleArray[i].currTime = 0.0f;
            particleArray[i].lifeTime = Random.value * 5.0f;
        }

        particleBuffer = new ComputeBuffer(particleCount, 32);
        particleBuffer.SetData(particleArray);
        kernelID = computeShader.FindKernel("SpawnParticles");
        computeShader.SetBuffer(kernelID, "particleBuffer", particleBuffer);
        material.SetBuffer("particleBuffer", particleBuffer);
    }

    // what to do when the program exits
    void OnDestroy() {
        if (particleBuffer != null)
            particleBuffer.Release();
    }


    // Update is run every frame, we dispatch our compute shader after setting any constantly changing variables
    void Update () {
        computeShader.SetFloat("deltaTime", Time.deltaTime);
        computeShader.SetFloat("gameTime", Time.time);
        computeShader.Dispatch(kernelID, Mathf.CeilToInt((float)particleCount/256.0f),1,1);
		
	}

    //render as points 
    void OnRenderObject() {
        material.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Points, 1, particleCount);
    }

}
