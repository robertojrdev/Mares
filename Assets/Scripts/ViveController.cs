using System;
using UnityEngine;
using Valve.VR;

public class ViveController : MonoBehaviour
{
    public float sensitivity = 0.1f;
    public float maxSpeed = 1;

    public SteamVR_Action_Boolean movePress;
    public SteamVR_Action_Vector2 moveValue;

    private float speed;

    private CharacterController controller;
    public Transform cameraRig;
    public Transform head;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
    }

    private void Start()
    {
        //cameraRig = SteamVR_Render.Top().origin;
        //head = SteamVR_Render.Top().head;
    }

    private void FixedUpdate()
    {
        if (movePress.state)
        {
            Vector3 forward = head.forward;
            forward.y = 0;
            forward = forward.normalized;

            var angle = -90;
            Vector3 right = new Vector3();
            right.x = forward.x * Mathf.Cos(angle) - forward.z * Mathf.Sin(angle);
            right.z = forward.x * Mathf.Sin(angle) + forward.z * Mathf.Cos(angle);

            Vector3 movDirection = forward * moveValue.axis.y + right * moveValue.axis.x;

            controller.SimpleMove(movDirection * sensitivity);
        }

        //HandleHead();
        //HandleHeight();
        //CalaculateMovement();
    }

    private void HandleHead()
    {
        var oldPos = cameraRig.position;
        var oldRotation = cameraRig.rotation;

        transform.eulerAngles = new Vector3(0, head.rotation.eulerAngles.y, 0);

        cameraRig.position = oldPos;
        cameraRig.rotation = oldRotation;
    }
    private void CalaculateMovement()
    {
        var orientationEuler = new Vector3(0, transform.eulerAngles.y, 0);
        var orientation = Quaternion.Euler(orientationEuler);
        var movement = Vector3.zero;

        if (movePress.GetStateUp(SteamVR_Input_Sources.Any))
            speed = 0;

        if(movePress.state)
        {
            speed = moveValue.axis.y * sensitivity;
            speed = Mathf.Clamp(speed, -maxSpeed, maxSpeed);

            movement += orientation * (speed * Vector3.forward) * Time.deltaTime;
        }

        controller.Move(movement);
    }

    private void HandleHeight()
    {
        var headHeight = Mathf.Clamp(head.localPosition.y, 1, 2);
        controller.height = headHeight;

        var newCenter = Vector3.zero;
        newCenter.y = controller.height / 2;
        newCenter.y += controller.skinWidth;

        newCenter.x = head.localPosition.x;
        newCenter.z = head.localPosition.z;

        newCenter = Quaternion.Euler(0, -transform.eulerAngles.y, 0) * newCenter;

        controller.center = newCenter;
    }
}
