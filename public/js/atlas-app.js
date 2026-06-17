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

    // wire search
    document.getElementById("search").addEventListener("input", (event) => {
      this.graphView.filterBySearch(event.target.value);
    });

    // wire controls (edge labels, association filters, smells)
    this.setupControls();

    new SidebarResizer({
      sidebar: document.getElementById("sidebar"),
      handle: document.getElementById("drag-handle"),
      networkContainer: document.getElementById("network"),
      onResize: () => this.graphView.redrawAndFit(),
    });
  }

  setupControls() {
    const labelsCheckbox = document.getElementById("toggle_edge_labels");
    if (labelsCheckbox) {
      labelsCheckbox.addEventListener("change", (e) => {
        this.graphView.toggleEdgeLabels(e.target.checked);
      });
    }

    const associationCheckboxes = Array.from(
      document.querySelectorAll(".association-filter"),
    );
    if (associationCheckboxes.length > 0) {
      const updateFilter = () => {
        const allowed = new Set(
          associationCheckboxes.filter((c) => c.checked).map((c) => c.value),
        );
        this.graphView.filterByRelationship(allowed);
      };

      associationCheckboxes.forEach((cb) =>
        cb.addEventListener("change", updateFilter),
      );

      // initial filter (show all checked by default)
      updateFilter();
    }

    const smellsBtn = document.getElementById("show-smells");
    if (smellsBtn) {
      smellsBtn.addEventListener("click", async () => {
        const smells = await this.api.getSmells();
        this.sidebar.showSmells(smells);
      });
    }
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
