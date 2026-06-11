using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets; // Asegura que encuentre el script dentro del namespace

public class FootstepParticleSpawner : MonoBehaviour
{
    [Header("Particle Settings")]
    [SerializeField] private GameObject footstepParticlePrefab;
    [Header("Compensación de Movimiento")]
    [SerializeField] private float forwardOffset = 0.15f; 
    
    [Header("Area Restriction")]
    [SerializeField] private Collider allowedAreaCollider;

    [Header("Ground Detection")]
    [SerializeField] private LayerMask groundLayer;

    // Referencia interna al controlador del jugador
    private ThirdPersonController _playerController;

    private void Start()
    {
        // Buscamos el componente ThirdPersonController en el objeto padre principal
        _playerController = GetComponentInParent<ThirdPersonController>();
    }

    public void SpawnFootstep(Transform footTransform)
    {
        if (allowedAreaCollider != null)
        {
            if (!allowedAreaCollider.bounds.Contains(footTransform.position))
            {
                return;
            }
        }

        if (footstepParticlePrefab != null)
        {
            Vector3 forwardDirection = transform.forward;
            Vector3 rayStart = footTransform.position + (forwardDirection * forwardOffset) + Vector3.up * 0.5f;
            
            if (Physics.Raycast(rayStart, Vector3.down, out RaycastHit hit, 2f, groundLayer))
            {
                Vector3 spawnPosition = hit.point + Vector3.up * 0.01f;
                Instantiate(footstepParticlePrefab, spawnPosition, Quaternion.identity);
            }
        }

    }
}