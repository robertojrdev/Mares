using UnityEngine;

public class FollowAhead : MonoBehaviour
{

    public Transform target;
    public float height = 1;
    public float distance = 1.5f;
    public float smooth = 1.5f;
    public bool faceTarget = true;

    private Vector3 _smoothVelocity;

    private void Update()
    {
        if (!target)
            return;

        Vector3 forward = target.forward;
        forward.y = 0;
        forward = forward.normalized;

        Vector3 targetPos = target.position;

        Vector3 position = forward * distance + Vector3.up * height + targetPos;

        transform.position = Vector3.SmoothDamp(transform.position, position, ref _smoothVelocity, smooth);

        if (faceTarget)
            transform.LookAt(targetPos);
    }

}
