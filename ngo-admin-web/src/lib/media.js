const LOCAL_LIKE_HOSTS = new Set(['localhost', '127.0.0.1', '10.0.2.2', '10.0.3.2']);

export function resolveMediaUrl(inputUrl) {
  if (!inputUrl) return '';

  if (inputUrl.startsWith('/uploads/')) {
    return `/api/proxy${inputUrl}`;
  }

  if (inputUrl.startsWith('/')) {
    return inputUrl;
  }

  try {
    const raw = new URL(inputUrl);

    if (raw.pathname.startsWith('/uploads/')) {
      if (LOCAL_LIKE_HOSTS.has(raw.hostname)) {
        return `/api/proxy${raw.pathname}${raw.search}`;
      }
    }

    return raw.toString();
  } catch {
    return inputUrl;
  }
}
