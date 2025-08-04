import Banner from './Banner';
// Importă aici TOATE componentele pe care le poți adăuga pe o pagină
// import Sidebar from './Sidebar'; 
// import ContentBlock from './ContentBlock';

// Maparea între __typename din GraphQL și componenta React
const componentMap: { [key: string]: React.ComponentType<any> } = {
  ComponentaBanner: Banner,
  // ComponentaQuicklinks: Sidebar,
  // ... adaugă restul aici
};

// Mapper-ul primește un singur bloc de date
export default function ComponentMapper({ block }: { block: any }) {
  // Extragem numele tipului și datele efective din bloc
  const typeName = Object.keys(block)[0]; 
  const ComponentToRender = componentMap[typeName];

  if (!ComponentToRender) {
    // Returnează un placeholder sau null dacă componenta nu e mapată
    return <div className="text-red-500">Componenta de tip '{typeName}' nu este mapată.</div>;
  }
  
  const componentData = block[typeName];

  // Returnează componenta corectă, pasându-i toate datele ca props
  return <ComponentToRender {...componentData} />;
}```

**Acțiune 2: Modifică pagina principală `src/app/page.tsx`**

Curăță fișierul și înlocuiește-l cu următorul cod:

```typescript
import { fetchDotCMS } from '@/lib/dotcms';
import ComponentMapper from '@/components/ComponentMapper';

// Interogarea pe care am validat-o anterior
const GET_PAGE_DATA = `
  query getPageDataByUrl($url: String!) {
    PaginaGenericaCollection(limit: 1, query: "+urlMap:$url") {
      title
      blocDeContinut {
        banner {
          __typename
          title
          subtitlu
          imagineFundal { path }
        }
        # Adaugă aici și celelalte componente, ex: componentaQuicklinks
      }
    }
  }
`;

// Pagina devine o funcție asincronă
export default async function Home() {
  
  // Preluăm datele specifice acestei pagini
  const pageDataResponse = await fetchDotCMS<any>({
    query: GET_PAGE_DATA,
    variables: { url: "/index" } // URL-ul pentru pagina "Acasă"
  });

  const page = pageDataResponse?.PaginaGenericaCollection?.[0];

  if (!page) {
    return <div>Pagina nu a fost găsită.</div>;
  }
  
  const blocks = page.blocDeContinut || [];

  return (
    <div>
      {/* 
        Iterăm prin lista de blocuri de conținut.
        Pentru fiecare bloc, chemăm Mapper-ul care va decide ce să afișeze.
      */}
      {blocks.map((block: any, index: number) => (
        <ComponentMapper key={index} block={block} />
      ))}
    </div>
  );
}