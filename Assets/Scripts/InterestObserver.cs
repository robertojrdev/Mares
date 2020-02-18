using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InterestObserver : MonoBehaviour
{
    [SerializeField] private LayerMask mask = 256;

    private InterestPoints currentPoint;
    private float pointStartTime;

    void Awake()
    {
        Manager.onFinishSimulation += StopLook;
    }

    void OnDestroy()
    {
        Manager.onFinishSimulation -= StopLook;
    }

    private void Update()
    {
        if (!Manager.running)
            return;

        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, 4000, mask))
        {
            InterestPoints point = hit.transform.GetComponent<InterestPoints>();

            if (point)
            {
                StartLook(point);
            }
            else
            {
                StopLook();
            }
        }
        else
            StopLook();
    }

    private void StartLook(InterestPoints point)
    {
        if (point == currentPoint)
            return;

        if (currentPoint)
            StopLook();

        currentPoint = point;
        pointStartTime = Time.unscaledTime;
    }

    private void StopLook()
    {
        if (!currentPoint)
            return;

        float totalTime = Time.unscaledTime - pointStartTime;
        InterestRegister.AddRegister(currentPoint.pointName, totalTime);

        currentPoint = null;
    }
}
