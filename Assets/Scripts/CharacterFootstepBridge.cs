using UnityEngine;

public class CharacterFootstepBridge : MonoBehaviour
{
    // Cambiamos la referencia para que apunte al nuevo script de audio
    [SerializeField] private SimpleFootstepAudio audioPlayer; 
    [SerializeField] private FootstepParticleSpawner spawner;
    
    [Header("Foot Bones References")]
    [SerializeField] private Transform leftFootTransform;
    [SerializeField] private Transform rightFootTransform;

    public void TriggerLeftFootstep()
    {
        // El sonido suena SIEMPRE
        if (audioPlayer != null) audioPlayer.TriggerLeftFootstep();
        
        // Las partículas solo si está en el área
        if (leftFootTransform != null && spawner != null) spawner.SpawnFootstep(leftFootTransform);
    }

    public void TriggerRightFootstep()
    {
        // El sonido suena SIEMPRE
        if (audioPlayer != null) audioPlayer.TriggerRightFootstep();
        
        // Las partículas solo si está en el área
        if (rightFootTransform != null && spawner != null) spawner.SpawnFootstep(rightFootTransform);
    }
}