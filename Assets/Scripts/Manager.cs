using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Manager : MonoBehaviour
{
    private static Manager instance;
    private float counter = 0;
    private float fadeTime = 2;
    private int index = 0;
    private bool running = true;

    private float[] timers = new float[] { 20, 10, 10};

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
        print(counter + " " + timers[index]);
        if(counter >= timers[index])
        {
            OnFinishCounter();
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
    }
}
