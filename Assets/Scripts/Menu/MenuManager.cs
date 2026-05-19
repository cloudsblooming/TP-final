using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement; 
public class MenuManager : MonoBehaviour
{
    
    public string nombreDeLaEscenaDelJuego = "Game";

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            SceneManager.LoadScene(nombreDeLaEscenaDelJuego);
        }
    }
}