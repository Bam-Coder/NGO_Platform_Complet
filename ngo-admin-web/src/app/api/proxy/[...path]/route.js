const DEFAULT_BACKEND_URL =
  process.env.NEXT_SERVER_API_URL ||
  process.env.NEXT_PUBLIC_API_URL ||
  'http://localhost:3000';

function trimTrailingSlash(value) {
  return value.endsWith('/') ? value.slice(0, -1) : value;
}

function buildTargetUrl(pathSegments, search) {
  const safeBase = trimTrailingSlash(DEFAULT_BACKEND_URL.trim());
  const path = Array.isArray(pathSegments) ? pathSegments.join('/') : '';
  return `${safeBase}/${path}${search || ''}`;
}

function forwardHeaders(request) {
  const headers = new Headers();
  const auth = request.headers.get('authorization');
  const contentType = request.headers.get('content-type');
  const accept = request.headers.get('accept');

  if (auth) headers.set('authorization', auth);
  if (contentType) headers.set('content-type', contentType);
  if (accept) headers.set('accept', accept);

  return headers;
}

async function handler(request, context, method) {
  try {
    const params = await context.params;
    const targetUrl = buildTargetUrl(params?.path, request.nextUrl.search);
    const headers = forwardHeaders(request);

    const init = {
      method,
      headers,
      redirect: 'manual',
    };

    if (method !== 'GET' && method !== 'HEAD') {
      init.body = await request.arrayBuffer();
    }

    const upstream = await fetch(targetUrl, init);

    const responseHeaders = new Headers(upstream.headers);
    responseHeaders.delete('content-encoding');
    responseHeaders.delete('transfer-encoding');
    responseHeaders.delete('connection');

    return new Response(upstream.body, {
      status: upstream.status,
      statusText: upstream.statusText,
      headers: responseHeaders,
    });
  } catch {
    return Response.json(
      {
        message: 'Backend inaccessible via proxy.',
        backend: DEFAULT_BACKEND_URL,
      },
      { status: 502 },
    );
  }
}

export async function GET(request, context) {
  return handler(request, context, 'GET');
}

export async function POST(request, context) {
  return handler(request, context, 'POST');
}

export async function PUT(request, context) {
  return handler(request, context, 'PUT');
}

export async function PATCH(request, context) {
  return handler(request, context, 'PATCH');
}

export async function DELETE(request, context) {
  return handler(request, context, 'DELETE');
}
