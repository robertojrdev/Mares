using UnityEngine;
using Valve.VR.InteractionSystem;

public class SteamInitialPosition : MonoBehaviour
{

    private void Start()
    {
        var steamPlayer = FindObjectOfType<Player>();
        if (steamPlayer == null)
            return;

        steamPlayer.transform.position = transform.position;
        steamPlayer.transform.rotation = transform.rotation;
    }

}
