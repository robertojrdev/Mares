using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Manager : MonoBehaviour
{
    public bool closeWithoutFinalQuestion = true;
    private static Manager instance;
    private float counter = 0;
    private float fadeTime = 2;
    private int index = 0;
    public static bool running { get; private set; } = true;
    private bool savingExcelFile = false;

    private float[] timers = new float[] { 90, 20, 90};

    public static Action onFinishSimulation;

    void Awake()
    {
        if (!instance)
            instance = this;
        else
        {
            Destroy(this);
            return;
        }

        DontDestroyOnLoad(gameObject);
    }

    // Update is called once per frame
    void Update()
    {
        if (!running)
            return;

        counter += Time.deltaTime;
        if(counter >= timers[index])
        {
            OnFinishCounter();
        }
    }

    public static void SaveDataAndFinish(bool finalAnswer)
    {
        ExcelData table = new ExcelData();
        table.AddCell("Nome do participante");
        table.AddLine();
        table.AddLine();
        table.AddCell("Resposta final");
        table.AddCell(finalAnswer ? "SIM" : "NAO");
        table.AddLine();
        table.AddLine();
        table.AddCell("Cenario");
        table.AddCell("Local");
        table.AddCell("Tempo (segundos)");
        table.AddLine();

        var data = InterestRegister.GetExcelData();

        table.Append(false, data);

        string time = DateTime.Now.ToString("yyyy-MM-dd HH-mm-ss");

        if (instance)
            instance.StartCoroutine(ExcelFileCreator.Create(table, time, Application.dataPath));
        else
        {
            var obj = new GameObject("Manager", typeof(Manager));
            instance.StartCoroutine(ExcelFileCreator.Create(table, time, Application.dataPath));
        }
    }

    void OnFinishCounter()
    {
        print("finish counter " + index);

        index++;
        if (timers.Length > index)
        {
            counter = -fadeTime;
            LoadNextScene();
        }
        else
        {
            Finish();
        }
    }

    private void LoadNextScene()
    {
        print("loading next scene");

        var fade = FindObjectOfType<OVRScreenFade>();
        if(fade)
        {
            fadeTime = fade.fadeTime;
            fade.FadeOut();
        }

        int nextScene = SceneManager.GetActiveScene().buildIndex +1;
        if (SceneManager.sceneCountInBuildSettings > nextScene)
            StartCoroutine(LoadSceneDelayed(nextScene, fadeTime));
        else
            Debug.LogError("No scene to load but your counter still have time");
    }

    IEnumerator LoadSceneDelayed(int sceneIndex, float delay)
    {
        print("Starting load scene delayed");

        yield return new WaitForSeconds(delay);
        SceneManager.LoadScene(sceneIndex);
    }

    private void Finish()
    {
        print("Finish all");
        running = false;
        if(onFinishSimulation != null)
            onFinishSimulation.Invoke();

        if(closeWithoutFinalQuestion)
        {
            SaveDataAndFinish(false);
            StartCoroutine(WaitSaveToExit());
        }
    }

    private IEnumerator WaitSaveToExit()
    {
        yield return new WaitWhile(() => ExcelFileCreator.IsSaving);
        Application.Quit();
    }
}
