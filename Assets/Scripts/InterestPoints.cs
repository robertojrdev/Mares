using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InterestPoints : MonoBehaviour
{
    public readonly int Layer = 8;

    public string pointName = "no name";

    void OnValidate()
    {
        gameObject.layer = Layer;
    }
}
