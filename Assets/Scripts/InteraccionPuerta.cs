using UnityEngine;
using UnityEngine.SceneManagement;

public class InteraccionPuerta : MonoBehaviour
{
    [Header("UI Elementos")]
    public GameObject botonInteractuarUI;
    public GameObject panelConfirmacionUI;

    [Header("Configuración de la Escena")]
    public string nombreEscenaFinal = "EscenaGraciasPorJugar";

    private bool jugadorCerca = false;
    private bool menuAbierto = false;

    void Update()
    {
        if (jugadorCerca && !menuAbierto && Input.GetKeyDown(KeyCode.E))
        {
            AbrirMenuConfirmacion();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            jugadorCerca = true;
            if (!menuAbierto)
            {
                botonInteractuarUI.SetActive(true);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            jugadorCerca = false;
            botonInteractuarUI.SetActive(false);
            CerrarMenuConfirmacion();
        }
    }

    void AbrirMenuConfirmacion()
    {
        menuAbierto = true;
        botonInteractuarUI.SetActive(false);
        panelConfirmacionUI.SetActive(true);
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }

    public void CerrarMenuConfirmacion()
    {
        menuAbierto = false;
        panelConfirmacionUI.SetActive(false);
        if (jugadorCerca)
        {
            botonInteractuarUI.SetActive(true);
        }
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    public void TerminarJuego()
    {
        SceneManager.LoadScene(nombreEscenaFinal);
    }
}