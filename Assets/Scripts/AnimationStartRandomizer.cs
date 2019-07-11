using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationStartRandomizer : MonoBehaviour
{
    private Animator anim;

    void Start()
    {
        anim = GetComponent<Animator>();

        float offset = Random.Range(0f, 1f);
        anim.SetFloat("cycleoffset", offset);
    }
}
