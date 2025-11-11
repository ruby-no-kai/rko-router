function handler(
  event: AWSCloudFrontFunction.Event,
): AWSCloudFrontFunction.Request {
  const { request, context } = event;

  request.headers["x-rko-host"] = request.headers["host"];

  const fp = request.headers["cloudfront-forwarded-proto"]?.value;
  if (fp === "https" || fp === "HTTPS") {
    request.headers["x-rko-xfp"] = { value: "https" };
  } else {
    request.headers["x-rko-xfp"] = { value: "http" };
  }

  return request;
}
