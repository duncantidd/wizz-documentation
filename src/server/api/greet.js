// Served at /api/greet. Powers the live "Server API" sandbox in the docs:
// the browser calls this same-origin route and the handler runs server-side.
//
// A plain object answers 200 as JSON; { status, headers, body } gives full
// control over the response.
export default async function handler(request) {
  if (request.method !== "GET") {
    return { status: 405, headers: { allow: "GET" }, body: { error: "Method not allowed" } };
  }

  const raw = request.query.get("name") ?? "";
  const name = raw.trim().slice(0, 40) || "friend";

  return {
    message: `Hello, ${name}! This JSON was produced by src/server/api/greet.js.`,
    method: request.method,
    path: request.path,
    query: Object.fromEntries(request.query),
    userAgent: request.headers["user-agent"] ? "present (lowercased header map)" : "absent",
    runtime: `Node ${process.version}`,
    renderedAt: new Date().toISOString()
  };
}
