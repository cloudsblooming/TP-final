using UnityEngine;

public class GlobalGrassManager : MonoBehaviour
{
    public Transform playerTransform;

    void Start()
    {
        // Si se lo pegás al Player, se asigna solo. Si no, busca al objeto con el tag Player.
        if (playerTransform == null)
        {
            GameObject player = GameObject.FindWithTag("Player");
            if (player != null) playerTransform = player.transform;
        }
    }

    void Update()
    {
        if (playerTransform != null)
        {
            // ¡La clave! Shader.SetGlobalVector le envía la posición a TODOS los materiales del juego a la vez
            Shader.SetGlobalVector("_InteractorPosition", playerTransform.position);
        }
    }
}