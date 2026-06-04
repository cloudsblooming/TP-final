using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterFootstepBridge : MonoBehaviour
{
    [SerializeField] private FootstepParticleSpawner spawner;
    
    [Header("Foot Bones References")]
    [SerializeField] private Transform leftFootTransform;
    [SerializeField] private Transform rightFootTransform;

    public void TriggerLeftFootstep()
    {
        if (leftFootTransform != null) spawner.SpawnFootstep(leftFootTransform);
    }

    public void TriggerRightFootstep()
    {
        if (rightFootTransform != null) spawner.SpawnFootstep(rightFootTransform);
    }
}