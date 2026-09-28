import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'SkillAfrica Bootcamp 5.0 | Attendance', description: 'Fast, reliable attendance for SkillAfrica Bootcamp 5.0.' };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }
