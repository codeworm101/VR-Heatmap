using System.Collections;
using UnityEngine;

public class Heatmap : MonoBehaviour
{
    public int count = 100; // Maximum number of points in the heatmap
    public Material material; // Reference to the material used for rendering the heatmap
    public Vector4[] positions; // Array to store the positions of the heatmap points
    private Vector4[] properties; // Array to store properties (e.g., intensity) of the heatmap points
    private int currentIndex = 0; // Index to keep track of the current position in the circular buffer

    // Start is called before the first frame update
    void Start()
    {
        // Initialize arrays for positions and properties
        positions = new Vector4[count];
        properties = new Vector4[count];

        // Start coroutine to update positions periodically
        StartCoroutine(UpdatePositionsPeriodically(0.05f));
    }

    // Coroutine to update heatmap positions periodically
    IEnumerator UpdatePositionsPeriodically(float interval)
    {
        while (true)
        {
            UpdatePositionsFromRaycast(); // Update heatmap positions based on raycast hits
            UpdateMaterial(); // Update material properties to reflect changes in heatmap data
            yield return new WaitForSeconds(interval); // Wait for the specified interval
        }
    }

    // Update heatmap positions based on raycast hits
    void UpdatePositionsFromRaycast()
    {
        // Perform a raycast from the center of the screen
        Ray ray = Camera.main.ScreenPointToRay(new Vector3((Screen.width / 2) + 3.5f, Screen.height / 2, 0));
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            // Transform the hit position from world space to local space
            Vector3 localPosition = transform.InverseTransformPoint(hit.point);

            // Check if the hit point matches any of the previously hit points
            bool isNewPoint = true;
            for (int i = 0; i < count; i++)
            {
                if (positions[i] != Vector4.zero && Vector3.Distance(localPosition, positions[i]) < 0.01f)
                {
                    // If the hit point matches a previously hit point, accumulate intensity and exit the loop
                    properties[i].y += 0.1f; // Increase intensity
                    isNewPoint = false;
                    break;
                }
            }

            // If it's a new hit point, find the next available index in the arrays
            if (isNewPoint)
            {
                // Use circular buffer approach to store new hit point
                positions[currentIndex] = new Vector4(localPosition.x, localPosition.y, localPosition.z, 0);
                properties[currentIndex] = new Vector4(Random.Range(0.05f, 0.25f), 0.1f, 0, 0); // Set initial intensity
                currentIndex = (currentIndex + 1) % count; // Move to the next index in a circular manner
            }
        }
    }

    // Update material properties to reflect changes in heatmap data
    void UpdateMaterial()
    {
        // Set the length of the point arrays in the shader
        material.SetInt("_Points_Length", count);

        // Set the arrays of positions and properties in the shader
        material.SetVectorArray("_Points", positions);
        material.SetVectorArray("_Properties", properties);
    }
}
