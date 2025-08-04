import Banner from './Banner';
// Importă aici TOATE componentele pe care le poți adăuga pe o pagină

// Maparea între __typename din GraphQL și componenta React
const componentMap: { [key: string]: React.ComponentType<any> } = {
  // Aici trebuie să folosești numele variabilei din GraphQL, NU __typename-ul
  banner: Banner, 
  // Exemplu: componentaQuicklinks: Sidebar
};

// Mapper-ul primește un singur bloc de date
export default function ComponentMapper({ block }: { block: any }) {
  // Extragem numele tipului și datele efective din bloc
  const typeName = Object.keys(block)[0]; 
  const ComponentToRender = componentMap[typeName];

  if (!ComponentToRender) {
    // Returnează un placeholder sau null dacă componenta nu e mapată
    // Comentăm linia de eroare pentru a nu strica layout-ul
    // return <div className="text-red-500">Componenta de tip '{typeName}' nu este mapată.</div>;
    return null;
  }
  
  const componentData = block[typeName];

  // Returnează componenta corectă, pasându-i toate datele ca props
  return <ComponentToRender {...componentData} />;
}