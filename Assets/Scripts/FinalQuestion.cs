using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class FinalQuestion : MonoBehaviour
{
    public Transform vrForwardTransform;
    public float distance = 3;
    public float faceSmoothTime = 0.5f;
    public float moveSmoothSpeed = 5f;
    [SerializeField] private UnityEvent onShow;
    private bool isVisible = false;
    private Vector3 smoothDampVelocity = Vector3.zero;
    private bool facing = false;
    private Coroutine coroutine;

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

        if(isVisible)
        {
            if (!facing)
            {
                var position = Xz2Xy(transform.position);
                var vrPosition = Xz2Xy(vrForwardTransform.position);

                var direction = position - vrPosition;
                var forward = Xz2Xy(vrForwardTransform.forward);

                var dot = Vector2.Dot(forward, direction.normalized);
                if (dot < 0.4f)
                {
                    if (coroutine != null)
                        StopCoroutine(coroutine);

                    coroutine = StartCoroutine(FaceCharacter());
                }
            }

        }
    }

    private Vector2 Xz2Xy(Vector3 value)
    { return new Vector2(value.x, value.z); }

    private IEnumerator FaceCharacter()
    {
        print("start face");
        facing = true;
        while (facing)
        {
            //MOVE
            Vector3 desiredPosition = vrForwardTransform.position + distance * vrForwardTransform.forward;
            transform.position = Vector3.SmoothDamp(transform.position, desiredPosition, ref smoothDampVelocity, faceSmoothTime);

            //ROTATE
            transform.forward = Vector3.Lerp(transform.forward, vrForwardTransform.forward, moveSmoothSpeed * Time.deltaTime);

            if (smoothDampVelocity.magnitude <= 0.1f)
            {
                facing = false;
            }
            yield return null;
        }

        print("finish face");
    }

    [ContextMenu("Show")]
    private void Show()
    {
        onShow.Invoke();
        transform.position = vrForwardTransform.position + distance * vrForwardTransform.forward;
        transform.forward = vrForwardTransform.forward;
        isVisible = true;
    }

    public void AnswerQuestion(bool yes)
    {
        print("RESPONDEU " + yes);
        Manager.SaveDataAndFinish(yes);
    }
}
