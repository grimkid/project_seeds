import { fetchDotCMS } from '@/lib/dotcms';
import ComponentMapper from '@/components/ComponentMapper';
import Sidebar from '@/components/Sidebar'; // Asigură-te că ai importat Sidebar-ul

// Interogarea GraphQL completă și validată
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
        componentaQuicklinks {
          __typename
          title
          quickLinks {
            label
            link
          }
        }
        # Adaugă aici și alte tipuri de conținut pe care le folosești
      }
    }
  }
`;

export default async function Home() {
  try {
    const pageDataResponse = await fetchDotCMS<any>({
      query: GET_PAGE_DATA,
      variables: { url: "/index" }
    });

    const page = pageDataResponse?.PaginaGenericaCollection?.[0];

    if (!page) {
      return <div className="p-4">Pagina "Acasă" nu a fost găsită în dotCMS.</div>;
    }

    // AICI DEFINIM VARIABILA `blocks`
    const allBlocks = page.blocDeContinut || [];

    // Acum separăm blocurile în siguranță
    const mainContentBlocks = allBlocks.filter((b: any) => !b.componentaQuicklinks);
    const sidebarData = allBlocks.find((b: any) => b.componentaQuicklinks)?.componentaQuicklinks;

    return (
      <div className="container mx-auto flex flex-col md:flex-row p-4 gap-4">
        {/* Coloana principală pentru conținut */}
        <div className="w-full md:w-3/4 flex flex-col gap-4">
          {mainContentBlocks.map((block: any, index: number) => (
            <ComponentMapper key={index} block={block} />
          ))}
        </div>

        {/* Coloana pentru Sidebar, se afișează doar dacă există date */}
        {sidebarData && (
          <div className="w-full md:w-1/4">
            <Sidebar title={sidebarData.title} links={sidebarData.quickLinks || []} />
          </div>
        )}
      </div>
    );

  } catch (error) {
    console.error("A apărut o eroare la preluarea datelor paginii:", error);
    return <div className="p-4 text-red-500">Eroare la încărcarea paginii. Verifică consola serverului.</div>;
  }
}