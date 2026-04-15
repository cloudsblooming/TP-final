using UnityEngine;

public class MovimientoLucy : MonoBehaviour {
    public CharacterController controller;
    public Transform cam;
    public float velocidad = 3f;
    public float suavizadoGiro = 0.1f;
    float velocidadGiro;

    void Update() {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");
        Vector3 direccion = new Vector3(horizontal, 0f, vertical).normalized;

        if (direccion.magnitude >= 0.1f) {
            float anguloObjetivo = Mathf.Atan2(direccion.x, direccion.z) * Mathf.Rad2Deg + cam.eulerAngles.y;
            float angulo = Mathf.SmoothDampAngle(transform.eulerAngles.y, anguloObjetivo, ref velocidadGiro, suavizadoGiro);
            transform.rotation = Quaternion.Euler(0f, angulo, 0f);

            Vector3 dirMovimiento = Quaternion.Euler(0f, anguloObjetivo, 0f) * Vector3.forward;
            controller.Move(dirMovimiento.normalized * velocidad * Time.deltaTime);
        }
    }
}