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
    this.showEdgeLabels = true;

    // Map edgeId -> { labelText, originalFont }
    this.edgeMeta = new Map();
  }

  render(graphData) {
    if (!graphData || !graphData.nodes || !graphData.edges) return null;

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

    const defaultFont = { size: 10, align: "top", color: "#666666" };

    const edgeItems = graphData.edges.map((edge, index) => {
      const labelText = edge.relationship || "";

      // store metadata so we can restore later
      this.edgeMeta.set(index, {
        labelText,
        originalFont: { ...defaultFont },
      });

      return {
        id: index,
        from: edge.source,
        to: edge.target,
        arrows: "to",
        relationship: edge.relationship,
        associationName: edge.association_name,
        label: this.showEdgeLabels ? labelText : undefined,
        font: this.showEdgeLabels
          ? defaultFont
          : { size: 0, align: "top", color: "rgba(0,0,0,0)" },
      };
    });

    this.edges = new vis.DataSet(edgeItems);

    // destroy previous network cleanly if present
    if (this.network) {
      try {
        this.network.destroy();
      } catch (e) {
        // ignore if not available
      }
    }

    this.network = new vis.Network(
      this.container,
      { nodes: this.nodes, edges: this.edges },
      { physics: true },
    );

    return this.network;
  }

  onClick(handler) {
    if (this.network) this.network.on("click", handler);
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

    const ids = this.edges.getIds();
    for (const id of ids) {
      const edge = this.edges.get(id);
      const connected = impacted.has(edge.from) && impacted.has(edge.to);
      this.edges.update({
        id,
        color: connected ? COLOR.edgeActive : COLOR.faded,
      });
    }

    if (this.network && typeof this.network.redraw === "function")
      this.network.redraw();
  }

  highlightPath(path) {
    if (!Array.isArray(path)) return;

    const pathNodes = new Set(path);
    const pathEdges = new Set();

    for (let i = 0; i < path.length - 1; i++) {
      pathEdges.add(`${path[i]}->${path[i + 1]}`);
      pathEdges.add(`${path[i + 1]}->${path[i]}`);
    }

    const ids = this.edges.getIds();
    for (const id of ids) {
      const edge = this.edges.get(id);
      const active = pathEdges.has(`${edge.from}->${edge.to}`);
      this.edges.update({
        id,
        color: active ? COLOR.pathActive : COLOR.faded,
        width: active ? 4 : 1,
      });
    }

    this.nodes.forEach((node) => {
      this.nodes.update({
        id: node.id,
        color: pathNodes.has(node.id) ? COLOR.pathActive : COLOR.faded,
      });
    });

    if (this.network && typeof this.network.redraw === "function")
      this.network.redraw();
  }

  // Robust toggle: always restore from saved metadata
  toggleEdgeLabels(show) {
    this.showEdgeLabels = !!show;

    const ids = this.edges.getIds();
    for (const id of ids) {
      const meta = this.edgeMeta.get(id) || {};
      const edge = this.edges.get(id) || {};

      if (this.showEdgeLabels) {
        const label =
          meta.labelText ?? edge.associationName ?? edge.relationship ?? "";
        const font = meta.originalFont ??
          edge.font ?? { size: 10, align: "top", color: "#666666" };
        this.edges.update({ id, label, font });
      } else {
        // hide label: remove label and set tiny/transparent font to avoid reserved space
        this.edges.update({
          id,
          label: undefined,
          font: {
            size: 0,
            align: (meta.originalFont && meta.originalFont.align) || "top",
            color: "rgba(0,0,0,0)",
          },
        });
      }
    }

    if (this.network && typeof this.network.redraw === "function") {
      this.network.redraw();
    }
  }

  // Filter edges by their relationship type (expects a Set of allowed relationship strings)
  filterByRelationship(allowedSet) {
    const hasFilter = allowedSet && allowedSet.size > 0;
    const ids = this.edges.getIds();
    for (const id of ids) {
      const e = this.edges.get(id);
      const visible = !hasFilter || allowedSet.has(e.relationship);
      this.edges.update({
        id,
        hidden: !visible,
      });
    }
    if (this.network && typeof this.network.redraw === "function")
      this.network.redraw();
  }

  reset() {
    this.nodes.forEach((node) => {
      this.nodes.update({ id: node.id, color: node.originalColor });
    });
    if (this.network && typeof this.network.redraw === "function")
      this.network.redraw();
  }

  redrawAndFit() {
    if (this.network) {
      this.network.redraw();
      this.network.fit({ animation: false });
    }
  }
}
