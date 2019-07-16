using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using UnityEngine.SceneManagement;

public class InterestRegister
{
    public static Dictionary<int, Dictionary<string, float>> register { get; private set; } = 
        new Dictionary<int, Dictionary<string, float>>();

    public static void AddRegister(string name, float time)
    {
        if(time < 0)
            throw new System.Exception("Register cannot have negative values");

        int scene = SceneManager.GetActiveScene().buildIndex;

        if(!register.ContainsKey(scene))
        {
            register.Add(scene, new Dictionary<string, float>());
        }

        if (!register[scene].ContainsKey(name))
            register[scene].Add(name, time);
        else
            register[scene][name] += time;
    }
    
    public static ExcelData GetExcelData()
    {
        ExcelData data = new ExcelData();

        foreach (var scene in register)
        {
            foreach (var item in scene.Value)
            {
                string sceneName = scene.Key.ToString();
                string name = item.Key;
                string time = item.Value.ToString();


                data.AddCell(sceneName);
                data.AddCell(name);
                data.AddCell(time);
                data.AddLine();
            }
        }

        return data;
    }
}
