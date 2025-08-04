// src/lib/dotcms.ts

// Definim un tip pentru corpul cererii GraphQL.
// Acesta asigură că trimitem mereu o interogare (query) și opțional variabile.
type GraphQLRequestBody = {
  query: string;
  variables?: { [key: string]: any };
};

/**
 * Funcție helper pentru a trimite cereri către API-ul GraphQL al dotCMS.
 * Centralizează logica de fetch, headerele și gestionarea erorilor.
 *
 * @param body - Corpul cererii, conținând interogarea și variabilele.
 * @returns O promisiune care se rezolvă cu datele din răspunsul JSON.
 */
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
        // Header personalizat necesar pentru a fi redirectat corect de NGINX
        'dotcms': 'true',
      },
      body: JSON.stringify(body),
      // În dezvoltare, setăm cache: 'no-store' pentru a ne asigura
      // că vedem mereu datele proaspete din CMS la fiecare refresh.
      cache: 'no-store'
    });

    const jsonResponse = await response.json();

    // Verificăm dacă API-ul GraphQL a returnat erori specifice în corpul răspunsului.
    if (jsonResponse.errors) {
        console.error("Erori GraphQL:", JSON.stringify(jsonResponse.errors, null, 2));
        throw new Error("Cererea GraphQL a eșuat. Verifică consola pentru detalii.");
    }

    // Dacă totul este în regulă, returnăm doar obiectul `data`.
    return jsonResponse.data;

  } catch (error) {
    console.error("A eșuat conectarea la dotCMS:", error);
    // Aruncăm eroarea mai departe pentru a putea fi prinsă în componenta React.
    throw error;
  }
}