// src/lib/dotcms.ts

type GraphQLRequestBody = {
  query: string;
  variables?: { [key: string]: any };
};

export async function fetchDotCMS<T>(body: GraphQLRequestBody): Promise<T> {
  const endpoint = process.env.DOTCMS_GRAPHQL_ENDPOINT;

  if (!endpoint) {
    throw new Error("Variabila de mediu DOTCMS_GRAPHQL_ENDPOINT nu este configurată în .env.local");
  }

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'dotcms': 'true',
      },
      body: JSON.stringify(body),
      cache: 'no-store'
    });
    
    // --- MODIFICARE PENTRU DEPANARE ---
    // Citim răspunsul ca text, indiferent de ce este
    const textResponse = await response.text();
    
    // Afișăm în consolă exact ce am primit de la server
    console.log("==== RĂSPUNS BRUT DE LA API ====");
    console.log(textResponse);
    console.log("==============================");
    
    // Încercăm să parsăm textul ca JSON. Dacă eșuează, vom prinde eroarea.
    const jsonResponse = JSON.parse(textResponse);
    // --- SFÂRȘIT MODIFICARE ---

    if (jsonResponse.errors) {
        console.error("Erori GraphQL:", JSON.stringify(jsonResponse.errors, null, 2));
        throw new Error("Cererea GraphQL a eșuat. Verifică consola pentru detalii.");
    }

    return jsonResponse.data;

  } catch (error) {
    console.error("A eșuat conectarea la dotCMS:", error);
    throw error;
  }
}