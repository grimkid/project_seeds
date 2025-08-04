 type QuickLink = {
    label: string;
    link: string;
};

type SidebarProps = {
    title: string;
    links: QuickLink[];
};

export default function Sidebar({ title, links }: SidebarProps) {
    return (
        <aside className="w-1/4 p-4 bg-gray-100">
            <h2 className="text-xl font-bold mb-4">{title}</h2>
            <ul>
                {links.map(link => (
                    <li key={link.link} className="mb-2">
                        <a href={link.link} className="text-blue-600 hover:underline">{link.label}</a>
                    </li>
                ))}
            </ul>
        </aside>
    );
}