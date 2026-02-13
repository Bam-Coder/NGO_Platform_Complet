export function normalizeMediaUrl(inputUrl?: string | null): string {
  if (!inputUrl) return '';

  const base = process.env.PUBLIC_BASE_URL?.trim();
  if (!base) return inputUrl;

  try {
    const publicBase = new URL(base);
    const raw = new URL(inputUrl);
    const localLikeHosts = new Set(['localhost', '127.0.0.1', '10.0.2.2', '10.0.3.2']);

    if (
      localLikeHosts.has(raw.hostname) &&
      raw.pathname.startsWith('/uploads/')
    ) {
      return `${publicBase.origin}${raw.pathname}${raw.search}`;
    }

    return inputUrl;
  } catch {
    if (inputUrl.startsWith('/uploads/')) {
      try {
        const publicBase = new URL(base);
        return `${publicBase.origin}${inputUrl}`;
      } catch {
        return inputUrl;
      }
    }

    return inputUrl;
  }
}

export function normalizeMediaUrls(urls?: string[] | null): string[] {
  if (!Array.isArray(urls)) return [];
  return urls.map((url) => normalizeMediaUrl(url)).filter(Boolean);
}
