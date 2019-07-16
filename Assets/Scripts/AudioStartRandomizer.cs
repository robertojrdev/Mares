using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioStartRandomizer : MonoBehaviour
{
    void Start()
    {
        AudioSource s = GetComponent<AudioSource>();
        if(!s)
        {
            Debug.LogWarning("No audio source found");
            return;
        }

        if(!s.clip)
        {
            Debug.LogWarning("Audio source has no clip");
            return;
        }

        float totalTime = s.clip.length;
        float time = Random.Range(0, totalTime);
        s.time = time;
    }
}
