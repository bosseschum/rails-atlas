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
    // Wire UI controls, theme toggle, search, and resizer immediately
    this.setupTheme();
    this.setupControls();

    const searchInput = document.getElementById("search");
    if (searchInput) {
      searchInput.addEventListener("input", (event) => {
        this.graphView.filterBySearch(event.target.value);
      });
    }

    const sidebarElem = document.getElementById("sidebar");
    const handleElem = document.getElementById("drag-handle");
    const networkContainer = document.getElementById("network");
    if (sidebarElem && handleElem && networkContainer) {
      new SidebarResizer({
        sidebar: sidebarElem,
        handle: handleElem,
        networkContainer: networkContainer,
        onResize: () => this.graphView.redrawAndFit(),
      });
    }

    try {
      const graphData = await this.api.getGraph();
      this.graphView.render(graphData);
      this.graphView.onClick((params) => this.handleClick(params));
    } catch (err) {
      console.error("Failed to load graph data:", err);
    }
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
        try {
          const smells = await this.api.getSmells();
          this.sidebar.showSmells(smells);
        } catch (err) {
          console.error("Failed to load smells:", err);
        }
      });
    }
  }

  setupTheme() {
    const themeToggle = document.getElementById("theme-toggle");
    if (!themeToggle) return;

    const getPreferredTheme = () => {
      try {
        const stored = localStorage.getItem("theme");
        if (stored === "dark" || stored === "light") return stored;
      } catch (e) {
        // storage may be restricted
      }
      return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    };

    const updateToggleUI = (theme) => {
      const isDark = theme === "dark";
      themeToggle.textContent = isDark ? "☀️ Light" : "🌙 Dark";
      const targetTheme = isDark ? "light" : "dark";
      themeToggle.setAttribute(
        "aria-label",
        `Switch to ${targetTheme} theme`,
      );
      themeToggle.setAttribute(
        "title",
        `Switch to ${targetTheme} theme`,
      );
    };

    const currentTheme =
      document.documentElement.getAttribute("data-theme") || getPreferredTheme();
    document.documentElement.setAttribute("data-theme", currentTheme);
    updateToggleUI(currentTheme);

    themeToggle.addEventListener("click", () => {
      const activeTheme =
        document.documentElement.getAttribute("data-theme") === "dark"
          ? "light"
          : "dark";
      document.documentElement.setAttribute("data-theme", activeTheme);
      try {
        localStorage.setItem("theme", activeTheme);
      } catch (e) {
        // ignore storage errors
      }
      updateToggleUI(activeTheme);
    });

    try {
      const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
      if (mediaQuery && typeof mediaQuery.addEventListener === "function") {
        mediaQuery.addEventListener("change", (e) => {
          let stored = null;
          try {
            stored = localStorage.getItem("theme");
          } catch (_) {}
          if (!stored) {
            const sysTheme = e.matches ? "dark" : "light";
            document.documentElement.setAttribute("data-theme", sysTheme);
            updateToggleUI(sysTheme);
          }
        });
      }
    } catch (_) {}
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
