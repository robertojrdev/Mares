using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HandPointer : MonoBehaviour
{
    private static Action onActivate;
    private static bool isActive = false;

    [SerializeField] private LineRenderer line;
    [SerializeField] private float smoothLine = 0.07f;
    [SerializeField] private LayerMask mask = -1;
    [SerializeField] private Transform hand;
    [SerializeField] private OVRInput.Controller controller = OVRInput.Controller.RTouch;
    [SerializeField] private bool interactOnButtonRelease = false;

    private VrPointerInteractable currentInteractable;
    private bool isButtonDown = false;

    //SMOOTH LINE
    private Vector3 currentLineEndPoint;
    private Vector3 smoothVelocity;

    private void Awake()
    {
        Manager.onFinishSimulation += Activate;
    }

    private void OnDestroy()
    {
        Manager.onFinishSimulation -= Activate;

    }

    private void Activate()
    {
        isActive = true;
        if (line)
        {
            line.gameObject.SetActive(true);
            currentLineEndPoint = hand.position;
        }

        if (onActivate != null)
            onActivate.Invoke();
    }

    private void Update()
    {
        if (!isActive)
            return;

        Vector3? pointingPosition = PointToObjects();

        SetLine(pointingPosition);

        CheckInput();
    }

    private void SetLine(Vector3? pointingPosition)
    {
        if (!line)
            return;

        //if pointing nothing just point far away
        Vector3 finalPosition = pointingPosition.HasValue ?
            pointingPosition.Value :
            hand.position + hand.forward * 20;

        //smooth movement
        finalPosition = Vector3.SmoothDamp(currentLineEndPoint, finalPosition, ref smoothVelocity, smoothLine);
        currentLineEndPoint = finalPosition;

        line.SetPositions(new Vector3[] { hand.position, finalPosition });
    }

    private Vector3? PointToObjects()
    {
        Ray ray = new Ray(hand.transform.position, hand.transform.forward);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, 50, mask))
        {
            VrPointerInteractable interactable = hit.transform.GetComponent<VrPointerInteractable>();
            if (interactable)
            {
                PointToInteractable(interactable);
            }
            else
            {
                StopPointing();
            }

            return hit.point;
        }
        else
        {
            StopPointing();
            return null;
        }
    }

    private void PointToInteractable(VrPointerInteractable interactable)
    {
        if (!interactable)
            throw new Exception("Interactable cannot be null");

        if (interactable == currentInteractable)
            return;

        if (currentInteractable)
            currentInteractable.StopPointing();

        currentInteractable = interactable;
        currentInteractable.Point();
    }

    private void StopPointing()
    {
        if (!currentInteractable)
            return;

        currentInteractable.StopPointing();
        currentInteractable = null;
    }

    private void CheckInput()
    {
        float buttonValue = OVRInput.Get(OVRInput.Axis1D.PrimaryIndexTrigger, controller);

        if (buttonValue >= 0.5f)
        {
            if (!isButtonDown)
                OnButtonDown();

            isButtonDown = true;
        }
        else if(buttonValue <= 0.45f)
        {
            if (isButtonDown)
                OnButtonUp();

            isButtonDown = false;
        }
    }

    private void OnButtonUp()
    {
        if (!interactOnButtonRelease)
            return;

        if (currentInteractable)
            currentInteractable.Interact();
    }

    private void OnButtonDown()
    {
        if (interactOnButtonRelease)
            return;

        if (currentInteractable)
            currentInteractable.Interact();
    }
}
