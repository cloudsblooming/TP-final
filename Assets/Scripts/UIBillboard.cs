using UnityEngine;

using UnityEngine;

public class UIBillboard : MonoBehaviour
{
    [Header("Configuración de la Cámara")]
    [SerializeField] private Transform camaraPrincipal;

    void Start()
    {
        // Si no asignaste la cámara en el Inspector, la busca automáticamente por código
        if (camaraPrincipal == null && Camera.main != null)
        {
            camaraPrincipal = Camera.main.transform;
        }
    }

    void LateUpdate()
    {
        // Nos aseguramos de que exista la cámara para que no tire error en la consola
        if (camaraPrincipal != null)
        {
            // 1. Hace el LookAt para orientar el Canvas hacia la dirección de la cámara
            transform.LookAt(transform.position + camaraPrincipal.forward);
            
            // 2. Aplica tus rotaciones (Y: 180, Z: 180) para dar vuelta la imagen 
            // y que la "E" se vea al derecho en cada fotograma
            transform.Rotate(0, 180, 180);
        }
    }
}