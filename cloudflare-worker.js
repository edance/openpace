/* Upload this file to cloudflare.
 * Handles the reverse proxy between heroku and webflow
 *
 */

const securityHeaders = {
	"Content-Security-Policy" : "upgrade-insecure-requests",
	"Strict-Transport-Security" : "max-age=1000",
	"X-Xss-Protection" : "1; mode=block",
	"X-Frame-Options" : "DENY",
	"X-Content-Type-Options" : "nosniff",
	"Referrer-Policy" : "strict-origin-when-cross-origin",
};

const SITEMAP_CONTENT = `
# Reference: https://developers.google.com/search/reference/robots_txt
User-agent: *
Allow: /
Disallow: /app

Sitemap: https://www.openpace.co/sitemap.xml
`;

addEventListener('fetch', event => {
  event.respondWith(handleResponse(event.request));
});

async function handleResponse(request) {
  let response = await fetchResponse(request);
  return addHeaders(response);
}

async function fetchResponse(request) {
  let url = new URL(request.url);
  const pathname = url.pathname;

  // Remove trailing slash for any url except /
  if (pathname.length > 1 && pathname.endsWith('/')) {
    url.pathname = pathname.substring(0, pathname.length - 1);
    return Response.redirect(url, 301);
  }

  // default to webflow for most pages
  url.hostname = 'openpace.webflow.io';

  // Handle anything that is under the /app/ path (including /app)
  if (/^\/app\/?.*$/.test(pathname)) {
    url.pathname = url.pathname.replace('/app', '');
    url.hostname = 'squeeze-run.herokuapp.com';
  }

  // Handle anything that is under the /namer/ path (excluding /namer)
  if (/^\/namer\/.+$/.test(pathname)) {
    url.pathname = url.pathname.replace('/namer', '');
    url.hostname = 'activity-namer.herokuapp.com';
  }

  // Synthetic response for robots.txt
  if (url.pathname === '/robots.txt') {
    return new Response(SITEMAP_CONTENT, {
      headers: { "Content-Type": "text/plain" },
      status: 200,
    });
  }

  return fetch(new Request(url, request));
}

async function addHeaders(response) {
	let newHdrs = new Headers(response.headers);

  if (!isHTML(newHdrs)) {
    return response;
  }

  Object.keys(securityHeaders).map((name, index) => {
		newHdrs.set(name, securityHeaders[name]);
	});

	return new Response(response.body , {
		status: response.status,
		statusText: response.statusText,
		headers: newHdrs,
	});
}

function isHTML(headers) {
	return headers.has("Content-Type") && headers.get("Content-Type").includes("text/html");
}
