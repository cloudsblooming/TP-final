using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactor : MonoBehaviour
{
    private Transform playerTransform; 
    private Material grassMat;

    void Start()
    {
        grassMat = GetComponent<Renderer>().material;

        // Buscamos al Player por su Tag al iniciar el juego
        GameObject playerObj = GameObject.FindWithTag("Player");

        if (playerObj != null)
        {
            playerTransform = playerObj.transform;
        }
        else
        {
            Debug.LogWarning("¡Ojo! No encontré ningún objeto con el Tag 'Player' en la escena.");
        }
    }

    void Update()
    {
        // Si encontramos al jugador, le mandamos su posición al shader
        if (playerTransform != null)
        {
            Vector3 interactorPos = playerTransform.position;
            grassMat.SetVector("_InteractorPosition", interactorPos);
        }
    }
}