using System;
using UnityEngine;
using UnityEngine.Events;

public class OnFinishSimulation : MonoBehaviour
{
    [SerializeField] private UnityEvent _onFinish;

    private void Awake()
    {
        Manager.onFinishSimulation += OnFinish;
    }

    private void OnFinish()
    {
        _onFinish.Invoke();
    }

    private void OnDestroy()
    {
        Manager.onFinishSimulation -= OnFinish;
    }
}
