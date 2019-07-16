using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public static class Randomizer
{
    [MenuItem("GameObject/Functions/Randomize Rotation")]
    private static void RandomizeRotationOfSelectedObjs()
    {
        var obj = Selection.objects;
        foreach (var o in obj)
        {
            Type t = o.GetType();

            if(t.Equals(typeof(GameObject)))
            {
                ((GameObject)o).transform.eulerAngles = new Vector3(UnityEngine.Random.Range(0, 45), UnityEngine.Random.Range(0, 360), UnityEngine.Random.Range(0, 360));
            }
        }
    }
}
