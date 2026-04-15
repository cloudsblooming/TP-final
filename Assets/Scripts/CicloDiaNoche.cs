
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CicloDiaNoche : MonoBehaviour
{
    public float duracionMinutos = 1.5f;
    [Range(0, 360)] public float anguloNoche = 280f; 
    private float velocidadRotacion;
    public bool esDeNoche = false;

    void Start()
    {
        velocidadRotacion = 360f / (duracionMinutos * 60f);
    }

    void Update()
    {
        if (!esDeNoche)
        {
            transform.Rotate(Vector3.right * velocidadRotacion * Time.deltaTime);

            
            if (transform.eulerAngles.x >= anguloNoche && transform.eulerAngles.x < 355f)
            {
                esDeNoche = true;
                
                transform.rotation = Quaternion.Euler(anguloNoche, transform.eulerAngles.y, transform.eulerAngles.z);
                Debug.Log("Punto de oscuridad alcanzado: " + anguloNoche);
            }
        }
    }
}