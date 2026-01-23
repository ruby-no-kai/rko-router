// Handle /go/prospectus language redirect for rubykaigi.org
// Returns Response if redirect needed, null otherwise
function handleProspectusRedirect(
  request: AWSCloudFrontFunction.Request,
): AWSCloudFrontFunction.Response | null {
  const host = request.headers["host"]?.value;
  if (host !== "rubykaigi.org" || request.uri !== "/go/prospectus") {
    return null;
  }

  const country = request.headers["cloudfront-viewer-country"]?.value;
  const acceptLang = request.headers["accept-language"]?.value || "";

  const lang = (country === "JP" || acceptLang.toLowerCase().includes("ja"))
    ? "ja"
    : "en";

  // Build query string preserving original
  const qs = Object.keys(request.querystring)
    .map(k => {
      const v = request.querystring[k];
      return v.value ? `${k}=${v.value}` : k;
    })
    .join("&");
  const location = `/go/prospectus-${lang}${qs ? "?" + qs : ""}`;

  return {
    statusCode: 302,
    statusDescription: "Found",
    headers: {
      location: { value: location },
    },
  };
}

// Set x-rko-host and x-rko-xfp headers for backend routing
function setRkoHeaders(request: AWSCloudFrontFunction.Request): void {
  request.headers["x-rko-host"] = request.headers["host"];

  const fp = request.headers["cloudfront-forwarded-proto"]?.value;
  if (fp === "https" || fp === "HTTPS") {
    request.headers["x-rko-xfp"] = { value: "https" };
  } else {
    request.headers["x-rko-xfp"] = { value: "http" };
  }
}

function handler(
  event: AWSCloudFrontFunction.Event,
): AWSCloudFrontFunction.Request | AWSCloudFrontFunction.Response {
  const { request } = event;

  const redirect = handleProspectusRedirect(request);
  if (redirect) {
    return redirect;
  }

  setRkoHeaders(request);
  return request;
}
