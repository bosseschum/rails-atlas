import { ApiClient } from "./api-client.js";
import { GraphView } from "./graph-view.js";
import { Sidebar } from "./sidebar.js";
import { SidebarResizer } from "./sidebar-resizer.js";

export class AtlasApp {
  constructor() {
    this.api = new ApiClient();
    this.graphView = new GraphView(document.getElementById("network"));
    this.sidebar = new Sidebar(document.getElementById("sidebar-content"));
    this.pathStart = null;
  }

  async init() {
    const graphData = await this.api.getGraph();
    this.graphView.render(graphData);
    this.graphView.onClick((params) => this.handleClick(params));

    document.getElementById("search").addEventListener("input", (event) => {
      this.graphView.filterBySearch(event.target.value);
    });

    new SidebarResizer({
      sidebar: document.getElementById("sidebar"),
      handle: document.getElementById("drag-handle"),
      networkContainer: document.getElementById("network"),
      onResize: () => this.graphView.redrawAndFit(),
    });
  }

  handleClick(params) {
    if (params.nodes.length === 0) {
      this.graphView.reset();
      this.sidebar.showWelcome();
      this.pathStart = null;
      return;
    }

    const model = params.nodes[0];

    if (params.event.srcEvent.shiftKey) {
      this.selectPathNode(model);
    } else {
      this.loadModel(model);
    }
  }

  async loadModel(model) {
    const [metrics, connections, impact] = await Promise.all([
      this.api.getMetrics(model),
      this.api.getModelConnections(model),
      this.api.getImpact(model),
    ]);

    this.sidebar.showModel(model, metrics, connections, impact);
    this.graphView.highlightImpact(model, impact);
  }

  selectPathNode(model) {
    if (!this.pathStart) {
      this.pathStart = model;
      this.sidebar.showPathModeStart(model);
      return;
    }

    const pathEnd = model;
    this.loadPath(this.pathStart, pathEnd);
    this.pathStart = null;
  }

  async loadPath(from, to) {
    const path = await this.api.getPath(from, to);
    this.graphView.highlightPath(path);
    this.sidebar.showPath(path);
  }
}
