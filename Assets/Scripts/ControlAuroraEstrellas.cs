using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlAuroraEstrellas : MonoBehaviour
{
    [Header("Referencias")]
    public Material matAurora;
    public Transform sol;

    [Header("Configuración")]
    public float anguloActivacion = 280f;
    public float brilloMaximo = 5f;
    public float velocidadFade = 1.5f;

    private float brilloActual = 0f;

    void Update()
    {
        if (sol == null || matAurora == null) return;

        float rotX = sol.eulerAngles.x;

        // Lógica de activación (Noche)
        if (rotX >= anguloActivacion && rotX < 355f)
        {
            // 1. Aparece la Aurora suavemente
            if (brilloActual < brilloMaximo)
            {
                brilloActual += velocidadFade * Time.deltaTime;
            }

            // 2. ACTIVAR Estrellas (1 = On)
            matAurora.SetFloat("_StarOnOff", 1f);
        }
        else
        {
            // 1. Desaparece la Aurora suavemente
            if (brilloActual > 0f)
            {
                brilloActual -= velocidadFade * Time.deltaTime;
            }

            // 2. DESACTIVAR Estrellas cuando ya no se ve la aurora (0 = Off)
            if (brilloActual <= 0.1f)
            {
                matAurora.SetFloat("_StarOnOff", 0f);
            }
        }

        // Aplicamos el brillo (usando el nombre exacto del shader: _AuroraBrightness)
        matAurora.SetFloat("_AuroraBrightness", brilloActual);
    }
}