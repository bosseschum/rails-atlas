export class ApiClient {
  async getGraph() {
    const response = await fetch("/api/graph");
    return response.json();
  }

  async getModelConnections(name) {
    const response = await fetch(`/api/models/${encodeURIComponent(name)}`);
    return response.json();
  }

  async getImpact(name) {
    const response = await fetch(`/api/impact/${encodeURIComponent(name)}`);
    return response.json();
  }

  async getMetrics(name) {
    const response = await fetch(`/api/model/${encodeURIComponent(name)}`);
    return response.json();
  }

  async getPath(from, to) {
    const response = await fetch(
      `/api/path/${encodeURIComponent(from)}/${encodeURIComponent(to)}`,
    );
    return response.json();
  }
}
