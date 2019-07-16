using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class VrPointerInteractable : MonoBehaviour
{
    [SerializeField] private UnityEvent onPoint;
    [SerializeField] private UnityEvent onStopPoint;
    [SerializeField] private UnityEvent onInteract;

    public void Point()
    {
        onPoint.Invoke();
    }
    public void StopPointing()
    {
        onStopPoint.Invoke();
    }

    public void Interact()
    {
        onInteract.Invoke();
    }
}
