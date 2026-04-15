using UnityEngine;

public class CamaraLucy : MonoBehaviour
{
    private Vector3 posicionDeseada;

    [Header("Configuración de Movimiento")]
    public float sensibilidadRueda = 5f;
    public float suavizado = 5f;

    [Header("Límites (Ajustalo a tu escena)")]
    public float zMinimo = -5f; // Qué tan lejos puede ir (atrás)
    public float zMaximo = -1.5f; // Qué tan cerca puede llegar (adelante)

    void Start()
    {
        // Guardamos la posición inicial de la cámara
        posicionDeseada = transform.localPosition;
    }

    void Update()
    {
        // 1. Detectamos la ruedita del mouse
        float rueda = Input.GetAxis("Mouse ScrollWheel");

        if (rueda != 0)
        {
            // 2. Calculamos la nueva posición en el eje Z (hacia adelante/atrás)
            posicionDeseada.z += rueda * sensibilidadRueda;

            // 3. Limitamos para que la cámara no atraviese la cabeza de Lucy
            posicionDeseada.z = Mathf.Clamp(posicionDeseada.z, zMinimo, zMaximo);
        }

        // 4. Movemos la cámara SUAVEMENTE a esa posición
        transform.localPosition = Vector3.Lerp(transform.localPosition, posicionDeseada, Time.deltaTime * suavizado);
    }
}