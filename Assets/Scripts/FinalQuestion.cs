using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class FinalQuestion : MonoBehaviour
{
    public Transform vrForwardTransform;
    public float distance = 3;
    [SerializeField] private UnityEvent onShow;

    public enum Answer
    { A, B}

    void Awake()
    {
        Manager.onFinishSimulation += Show;
    }

    void OnDestroy()
    {
        Manager.onFinishSimulation -= Show;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.LeftControl))
            Show();
    }

    private void Show()
    {
        onShow.Invoke();
        transform.position = vrForwardTransform.position + distance * vrForwardTransform.forward;
        transform.forward = vrForwardTransform.forward;
    }

    public void AnswerQuestion(bool yes)
    {
        print("RESPONDEU " + yes);
        Manager.SaveDataAndFinish(yes);
    }
}
