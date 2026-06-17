const COLOR = {
  high: "#ef4444",
  medium: "#f59e0b",
  low: "#3b82f6",
  faded: "#dddddd",
  pathActive: "#ef4444",
  edgeActive: "#848484",
};

function colorForDegree(degree) {
  if (degree >= 10) return COLOR.high;
  if (degree >= 5) return COLOR.medium;
  return COLOR.low;
}

export class GraphView {
  constructor(container) {
    this.container = container;
    this.nodes = null;
    this.edges = null;
    this.network = null;
  }

  render(graphData) {
    this.nodes = new vis.DataSet(
      graphData.nodes.map((node) => {
        const color = colorForDegree(node.degree);
        return {
          id: node.id,
          label: node.id,
          degree: node.degree,
          originalColor: color,
          color,
        };
      }),
    );

    this.edges = new vis.DataSet(
      graphData.edges.map((edge, index) => ({
        id: index,
        from: edge.source,
        to: edge.target,
        arrows: "to",
        relationship: edge.relationship,
        association_name: edge.association_name,
        labelText: edge.association_name || edge.relationship,
        label: this.showEdgeLabels
          ? edge.association_name || edge.relationship
          : "",
        font: { align: "top" },
      })),
    );

    this.network = new vis.Network(
      this.container,
      { nodes: this.nodes, edges: this.edges },
      { physics: true },
    );

    return this.network;
  }

  onClick(handler) {
    this.network.on("click", handler);
  }

  filterBySearch(query) {
    const normalized = query.toLowerCase();

    this.nodes.forEach((node) => {
      this.nodes.update({
        id: node.id,
        hidden:
          normalized.length > 0 &&
          !node.label.toLowerCase().includes(normalized),
      });
    });
  }

  highlightImpact(selectedModel, impactModels) {
    const impacted = new Set([selectedModel, ...impactModels]);

    this.nodes.forEach((node) => {
      this.nodes.update({
        id: node.id,
        color: impacted.has(node.id) ? node.originalColor : COLOR.faded,
      });
    });

    this.edges.forEach((edge) => {
      const connected = impacted.has(edge.from) && impacted.has(edge.to);
      this.edges.update({
        id: edge.id,
        color: connected ? COLOR.edgeActive : COLOR.faded,
      });
    });
  }

  highlightPath(path) {
    const pathNodes = new Set(path);
    const pathEdges = new Set();

    for (let i = 0; i < path.length - 1; i++) {
      pathEdges.add(`${path[i]}->${path[i + 1]}`);
      pathEdges.add(`${path[i + 1]}->${path[i]}`);
    }

    this.edges.forEach((edge) => {
      const active = pathEdges.has(`${edge.from}->${edge.to}`);
      this.edges.update({
        id: edge.id,
        color: active ? COLOR.pathActive : COLOR.faded,
        width: active ? 4 : 1,
      });
    });

    this.nodes.forEach((node) => {
      this.nodes.update({
        id: node.id,
        color: pathNodes.has(node.id) ? COLOR.pathActive : COLOR.faded,
      });
    });
  }

  toggleEdgeLabels(show) {
    this.showEdgeLabels = !!show;
    this.edges.forEach((edge) => {
      this.edges.update({
        id: edge.id,
        label: this.showEdgeLabels ? edge.label : "",
      });
    });
  }

  filterByRelationship(allowedSet) {
    const hasFilter = allowedSet && allowedSet.size > 0;

    this.edges.forEach((edge) => {
      const visible = !hasFilter || allowedSet.has(edge.relationship);
      this.edges.update({
        id: edge.id,
        hidden: !visible,
      });
    });
  }

  reset() {
    this.nodes.forEach((node) => {
      this.nodes.update({ id: node.id, color: node.originalColor });
    });
  }

  redrawAndFit() {
    this.network.redraw();
    this.network.fit({ animation: false });
  }
}
