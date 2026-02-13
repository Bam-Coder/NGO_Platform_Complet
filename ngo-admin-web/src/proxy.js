import { NextResponse } from 'next/server';
import { getJwtRole } from '@/lib/jwt';

const PUBLIC_PATHS = ['/', '/login', '/register'];

function isPublicPath(pathname) {
  return PUBLIC_PATHS.some((path) => pathname === path || pathname.startsWith(`${path}/`));
}

export function proxy(request) {
  const token = request.cookies.get('token')?.value;
  const { pathname } = request.nextUrl;
  const publicPath = isPublicPath(pathname);
  const isAuthPath = pathname.startsWith('/login') || pathname.startsWith('/register');
  const role = token ? getJwtRole(token) : '';
  const isAdmin = role === 'ADMIN';

  if (!token && !publicPath) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (token && !isAdmin && !publicPath) {
    const response = NextResponse.redirect(new URL('/login', request.url));
    response.cookies.set('token', '', { maxAge: 0, path: '/' });
    return response;
  }

  if (token && isAdmin && isAuthPath) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
