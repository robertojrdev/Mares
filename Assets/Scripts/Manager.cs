using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Valve.VR;

public class Manager : MonoBehaviour
{
    public bool showExcelInTheEnd = true;
    private static Manager instance;
    private float counter = 0;
    private float fadeTime = 2;
    private int index = 0;
    public static bool running { get; private set; } = true;
    private bool savingExcelFile = false;

    public float[] timers = new float[] { 90, 20, 90};

    [SerializeField] private bool useSteamLoadLevel;
    [SerializeField] private SteamVR_LoadLevel steamLoadLevel;

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
            instance.StartCoroutine(ExcelFileCreator.Create(table, time, Application.dataPath, instance.showExcelInTheEnd));
        else
        {
            var obj = new GameObject("Manager", typeof(Manager));
            instance.StartCoroutine(ExcelFileCreator.Create(table, time, Application.dataPath, instance.showExcelInTheEnd));
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

        if(useSteamLoadLevel)
        {
            var nextIndex = SceneManager.GetActiveScene().buildIndex + 1;
            if (SceneManager.sceneCountInBuildSettings > nextIndex)
            {
                print("LOADING SCENE: " + nextIndex);
                var loader = Instantiate(steamLoadLevel);
                loader.levelName = (nextIndex +1).ToString();
                loader.Trigger();
            }
            else
            {
                Debug.LogError("No scene to load but your counter still have time");
            }

            return;
        }

        DoFade(Fade.Out);

        int nextScene = SceneManager.GetActiveScene().buildIndex +1;
        if (SceneManager.sceneCountInBuildSettings > nextScene)
            StartCoroutine(LoadSceneDelayed(nextScene, fadeTime));
        else
            Debug.LogError("No scene to load but your counter still have time");
    }

    IEnumerator LoadSceneDelayed(int sceneIndex, float delay)
    {
        yield return new WaitForSeconds(delay);

        AsyncOperation async = SceneManager.LoadSceneAsync(sceneIndex, LoadSceneMode.Single);

        yield return new WaitUntil(() => async.isDone);

        DoFade(Fade.In);
    }

    private void Finish()
    {
        print("Finish all");
        running = false;
        if(onFinishSimulation != null)
            onFinishSimulation.Invoke();

        SaveDataAndFinish(false);
    }

    public static void DoFade(Fade fade)
    {
        _fade = fade;
        _fading = true;
    }

    private static Texture2D _fadeTexture;
    private static bool _fading = false;
    private static float _alpha;
    private static Fade _fade;
    public enum Fade { In, Out}
    private void OnGUI()
    {
        if (!_fadeTexture)
        {
            _fadeTexture = new Texture2D(1, 1);
            _fadeTexture.SetPixel(0, 0, new Color(0, 0, 0, _alpha));
            _fadeTexture.Apply();
        }

        GUI.DrawTexture(
            new Rect(Vector2.zero, new Vector2(Screen.width, Screen.height)),
            _fadeTexture
        );

        if (!_fading)
            return;

        float delta = Mathf.InverseLerp(0, 1, _alpha);
        float increment = Time.deltaTime / fadeTime;
        print(increment);
        _alpha += _fade == Fade.In ? -increment : increment;

        if (_fade == Fade.In)
        {
            if (_alpha <= 0)
            {
                _alpha = 0;
                _fading = false;
            }

        }
        else
        {
            if(_alpha >= 1)
            {
                _alpha = 1;
                _fading = false;
            }
        }

        _fadeTexture.SetPixel(0, 0, new Color(0, 0, 0, _alpha));
        _fadeTexture.Apply();
    }
}
