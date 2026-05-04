using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneTransitioner : MonoBehaviour
{
    public static SceneTransitioner instance;
    private CanvasGroup cg;
    public float duration = 1f;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
            SceneManager.sceneLoaded += OnSceneLoaded;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        GameObject faderObj = GameObject.FindGameObjectWithTag("Fader");
        if (faderObj != null)
        {
            cg = faderObj.GetComponent<CanvasGroup>();
            if (cg != null)
            {
                cg.alpha = 1f;
                StartCoroutine(Fade(0f));
            }
        }
    }

    public void LoadScene(string sceneName)
    {
        StartCoroutine(Transition(sceneName));
    }

    IEnumerator Transition(string sceneName)
    {
        GameObject faderObj = GameObject.FindGameObjectWithTag("Fader");
        if (faderObj != null)
        {
            cg = faderObj.GetComponent<CanvasGroup>();
            yield return StartCoroutine(Fade(1f));
        }

        SceneManager.LoadScene(sceneName);
    }

    IEnumerator Fade(float targetAlpha)
    {
        if (cg == null) yield break;

        float startAlpha = cg.alpha;
        float timer = 0f;

        while (timer < duration)
        {
            timer += Time.deltaTime;
            cg.alpha = Mathf.Lerp(startAlpha, targetAlpha, timer / duration);
            yield return null;
        }
        cg.alpha = targetAlpha;
    }
}