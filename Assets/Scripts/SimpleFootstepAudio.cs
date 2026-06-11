using UnityEngine;
using StarterAssets;

public class SimpleFootstepAudio : MonoBehaviour
{
    private ThirdPersonController _controller;

    [Header("Sonidos por Superficie")]
    [SerializeField] private AudioClip[] pastoSounds;
    [SerializeField] private AudioClip[] maderaSounds;

    [Header("Detección de Suelo")]
    [SerializeField] private LayerMask groundLayer;
    [SerializeField] private float rayDistance = 1.5f;

    private void Start()
    {
        _controller = GetComponent<ThirdPersonController>();
    }

    public void TriggerLeftFootstep() 
    { 
        PlayFootstep(); 
    }

    public void TriggerRightFootstep() 
    { 
        PlayFootstep(); 
    }

    private void PlayFootstep()
    {
        AudioClip[] clipsActuales = pastoSounds;
        Vector3 rayStart = transform.position + Vector3.up * 0.5f;
        
        if (Physics.Raycast(rayStart, Vector3.down, out RaycastHit hit, rayDistance, groundLayer))
        {
            Collider sueloCollider = hit.collider;
            if (sueloCollider != null && sueloCollider.sharedMaterial != null)
            {
                string nombreMaterial = sueloCollider.sharedMaterial.name;

                if (nombreMaterial.Contains("Madera"))
                {
                    clipsActuales = maderaSounds;
                }
            }
        }

        if (clipsActuales != null && clipsActuales.Length > 0 && _controller != null)
        {
            int index = Random.Range(0, clipsActuales.Length);
            AudioSource.PlayClipAtPoint(
                clipsActuales[index], 
                transform.position, 
                _controller.FootstepAudioVolume
            );
        }
    }
}