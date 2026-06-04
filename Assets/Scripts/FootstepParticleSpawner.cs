using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FootstepParticleSpawner : MonoBehaviour
{
    [Header("Particle Settings")]
    [SerializeField] private GameObject footstepParticlePrefab;
    [Header("Compensación de Movimiento")]
    [SerializeField] private float forwardOffset = 0.15f; // Ajusta esto para empujar la flor hacia adelante
    
    [Header("Area Restriction")]
    [SerializeField] private Collider allowedAreaCollider;

    [Header("Ground Detection")]
    [SerializeField] private LayerMask groundLayer;

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
            // Conseguimos la dirección hacia adelante del personaje
            Vector3 forwardDirection = transform.forward;

            // Calculamos el inicio del rayo sumándole un empuje hacia adelante
            Vector3 rayStart = footTransform.position + (forwardDirection * forwardOffset) + Vector3.up * 0.5f;
            
            if (Physics.Raycast(rayStart, Vector3.down, out RaycastHit hit, 2f, groundLayer))
            {
                Vector3 spawnPosition = hit.point + Vector3.up * 0.01f;
                Instantiate(footstepParticlePrefab, spawnPosition, Quaternion.identity);
            }
        }
    }
}