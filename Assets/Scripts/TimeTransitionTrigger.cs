using System.Collections;
using UnityEngine;
using UnityEngine.Rendering; // OBLIGATORIO para controlar el Post-Procesado

public class TimeTransitionTrigger : MonoBehaviour
{
    [Header("Referencias de Iluminación")]
    [SerializeField] private Light directionalLight;

    [Header("Referencias de Post-Procesado")]
    [SerializeField] private Volume volumeNoche; // Arrastra acá tu Volume_Noche

    [Header("Configuración del Tiempo")]
    [SerializeField] private float transitionDuration = 5f;

    [Header("Colores de la Transición")]
    [SerializeField] private Color diaColor = new Color(1f, 0.95f, 0.8f);
    [SerializeField] private Color atardecerColor = new Color(0.9f, 0.4f, 0.2f);
    [SerializeField] private Color nocheColor = new Color(0.1f, 0.15f, 0.25f);

    private float rotacionDia = 50f;
    private float rotacionAtardecer = 15f;
    private float rotacionNoche = 290f;

    private bool yaSeActivo = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !yaSeActivo)
        {
            yaSeActivo = true;
            StartCoroutine(TransicionDiaANoche());
        }
    }

    private IEnumerator TransicionDiaANoche()
    {
        float tiempoTranscurrido = 0f;
        float mitadTiempo = transitionDuration / 2f;

        float intensidadInicial = directionalLight.intensity;

        // FASE 1: De Día a Atardecer
        while (tiempoTranscurrido < mitadTiempo)
        {
            tiempoTranscurrido += Time.deltaTime;
            float t = tiempoTranscurrido / mitadTiempo;

            directionalLight.color = Color.Lerp(diaColor, atardecerColor, t);
            
            float anguloX = Mathf.Lerp(rotacionDia, rotacionAtardecer, t);
            directionalLight.transform.rotation = Quaternion.Euler(anguloX, directionalLight.transform.eulerAngles.y, directionalLight.transform.eulerAngles.z);

            yield return null;
        }

        tiempoTranscurrido = 0f;

        // FASE 2: De Atardecer a Noche (Aquí se activa el post-procesado)
        while (tiempoTranscurrido < mitadTiempo)
        {
            tiempoTranscurrido += Time.deltaTime;
            float t = tiempoTranscurrido / mitadTiempo;

            directionalLight.color = Color.Lerp(atardecerColor, nocheColor, t);
            directionalLight.intensity = Mathf.Lerp(intensidadInicial, 0.05f, t);

            float anguloX = Mathf.Lerp(375f, rotacionNoche, t);
            directionalLight.transform.rotation = Quaternion.Euler(anguloX, directionalLight.transform.eulerAngles.y, directionalLight.transform.eulerAngles.z);

            RenderSettings.ambientLight = Color.Lerp(diaColor, nocheColor, t);

            // Transición suave del Post-Procesado de noche (va de 0 a 1)
            if (volumeNoche != null)
            {
                volumeNoche.weight = t;
            }

            yield return null;
        }

        directionalLight.intensity = 0.05f;
        directionalLight.color = nocheColor;
        directionalLight.transform.rotation = Quaternion.Euler(rotacionNoche, directionalLight.transform.eulerAngles.y, directionalLight.transform.eulerAngles.z);
        RenderSettings.ambientLight = nocheColor;
        
        if (volumeNoche != null) volumeNoche.weight = 1f;
    }
}