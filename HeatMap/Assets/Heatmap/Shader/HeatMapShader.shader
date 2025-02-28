Shader "Unlit/HeatmapShader"
{
    Properties
    {
        _HeatTex("Texture", 2D) = "white" {} // Texture property for the heatmap visualization
        _QuadTransform("Quad Transform Vector", Vector) = (0, 0, 0, 0) // Property to specify quad transformation
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" } // Tags to specify rendering order and transparency
        Blend SrcAlpha OneMinusSrcAlpha // Alpha blend mode for transparency

        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Vertex shader function
            #pragma fragment frag // Fragment (pixel) shader function

            float4 _QuadTransform; // Transformation vector for the quad

            // Input structure for vertex shader
            struct vertInput {
                float4 pos : POSITION; // Vertex position
            };

            // Output structure for vertex shader
            struct vertOutput {
                float4 pos : POSITION; // Transformed vertex position
                fixed3 worldPos : TEXCOORD1; // World position of the vertex
            };

            // Vertex shader function
            vertOutput vert(vertInput input) {
                vertOutput o;
                o.pos = UnityObjectToClipPos(input.pos); // Transform vertex position to clip space
                o.worldPos = mul(unity_ObjectToWorld, input.pos).xyz; // Calculate world position of the vertex
                o.worldPos.xyz -= _QuadTransform.xyz; // Adjust world position based on quad transformation
                return o;
            }

            uniform int _Points_Length = 0; // Length of the heatmap point arrays
            uniform float4 _Points[100];     // Array to store heatmap point positions (x, y, z)
            uniform float4 _Properties[100]; // Array to store heatmap properties (x = radius, y = intensity)

            sampler2D _HeatTex; // Heatmap texture sampler

            // Fragment shader function
            half4 frag(vertOutput output) : COLOR {
                half h = 0; // Initialize heatmap intensity

                // Loop over all heatmap points
                for (int i = 0; i < _Points_Length; i++)
                {
                    // Calculate the distance from the current fragment to the heatmap point
                    half di = distance(output.worldPos, _Points[i].xyz);

                    // Calculate the influence (intensity) of the heatmap point based on distance and radius
                    half ri = _Properties[i].x; // Radius of the heatmap point
                    half hi = 1 - saturate(di / ri); // Intensity based on distance and radius

                    // Accumulate the heatmap intensity
                    h += hi * _Properties[i].y; // Intensity of the heatmap point

                }

                // Convert the accumulated intensity to a color using the heatmap texture
                h = saturate(h); // Ensure intensity is in the range [0, 1]
                half4 color = tex2D(_HeatTex, fixed2(h, 0.5)); // Sample color from heatmap texture
                return color; // Return the final color
            }
            ENDCG // End of the CG program
        } // End of the Pass
    } // End of the SubShader

    Fallback "Diffuse" // Fallback shader if this one is not supported
}
