// Definim tipurile pentru datele pe care le va primi Header-ul
// Similar cu un DTO: HeaderData.java
type MenuItem = {
  label: string;
  link: string;
};

type HeaderProps = {
  menuItems: MenuItem[];
};

// Componenta în sine. Este o funcție care primește props și returnează HTML (JSX).
export default function Header({ menuItems }: HeaderProps) {
  return (
    <header className="bg-gray-800 text-white p-4">
      <nav>
        <ul className="flex space-x-4">
          {menuItems.map((item) => (
            <li key={item.link}>
              <a href={item.link}>{item.label}</a>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  );
}