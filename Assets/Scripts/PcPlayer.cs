using System;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PcPlayer : MonoBehaviour
{

    public float walkSpeed;
    public float runSpeed;
    public float rotationSpeed;
    public Camera headCamera;
    public float cameraHeight;
    public float bobCameraSpeed;
    public float bobCameraHeight;

    private CharacterController controller;
    float xRotation;
    private float bobCameraDelta;

    private void Start()
    {
        controller = GetComponent<CharacterController>();

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        LookArrownd();
        float movement = MoveArrownd();
        BobCamera(movement);
    }

    private void BobCamera(float movementIntensity)
    {

        float speed = Input.GetKey(KeyCode.LeftShift) ? bobCameraSpeed * 1.3f : bobCameraSpeed;
        bobCameraDelta += movementIntensity * Time.deltaTime * speed;
        Vector3 bobPosition = Vector3.up * cameraHeight + Vector3.up * bobCameraHeight * Mathf.Sin(bobCameraDelta);
        headCamera.transform.localPosition = bobPosition;
    }

    private float MoveArrownd()
    {
        Vector3 moveDirection = new Vector3();
        moveDirection += Input.GetAxis("Horizontal") * transform.right;
        moveDirection += Input.GetAxis("Vertical") * transform.forward;
        moveDirection = Vector3.ClampMagnitude(moveDirection, 1);

        float moveSpeed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;
        controller.SimpleMove(moveDirection * moveSpeed * Time.deltaTime);

        return moveDirection.magnitude;
    }

    private void LookArrownd()
    {
        float yRotation = Input.GetAxis("Mouse X");

        transform.Rotate(Vector3.up, yRotation * Time.deltaTime * rotationSpeed);

        xRotation += -Input.GetAxis("Mouse Y") * Time.deltaTime * rotationSpeed;
        xRotation = Mathf.Clamp(xRotation, -90, 90);
        Vector3 currentCamRotation = headCamera.transform.localEulerAngles;
        currentCamRotation.x = xRotation;
        headCamera.transform.localEulerAngles = currentCamRotation;
    }

    private void OnValidate()
    {
        if (!headCamera)
            return;

        headCamera.transform.localPosition = Vector3.up * cameraHeight;
    }
}
