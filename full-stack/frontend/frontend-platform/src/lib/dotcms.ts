// src/lib/dotcms.ts

type GraphQLRequestBody = {
  query: string;
  variables?: { [key: string]: any };
};

export async function fetchDotCMS<T>(body: GraphQLRequestBody): Promise<T> {
  const endpoint = process.env.DOTCMS_GRAPHQL_ENDPOINT;
  // Log cURL command for debugging
  const curl = [
    'curl',
    '-X', 'POST',
    `'${endpoint}'`,
    '-H', "Content-Type: application/json",
    '-H', "dotcms: true",
    '-d', `'${JSON.stringify(body).replace(/'/g, "'\''")}'`
  ].join(' ');
  console.log("=== cURL pentru debug dotCMS ===\n" + curl + "\n==============================");

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
      body: JSON.stringify(body)
    });
    const textResponse = await response.text();
    const jsonResponse = JSON.parse(textResponse);
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