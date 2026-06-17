export class Sidebar {
  constructor(container) {
    this.container = container;
  }

  showWelcome() {
    this.container.innerHTML = `
      <h2>Rails Atlas</h2>
      <p>Click on a model to see its details</p>
    `;
  }

  showPathModeStart(model) {
    this.container.innerHTML = `
      <h2>Path Mode</h2>
      <p>Start: ${model}</p>
      <p>Shift-Click another node to set the end point.</p>
    `;
  }

  showModel(metrics, connections, impact) {
    this.container.innerHTML = `
      <h2>${metrics.name}</h2>

      <h3>Metrics</h3>
      <ul>
        <li>Connections: ${metrics.degree}</li>
        <li>Impact Reach: ${metrics.impact}</li>
      </ul>

      <ul>
        ${connections
          .map(
            (connection) => `
          <li>
            ${connection.direction === "outgoing" ? "→" : "←"}
            ${connection.relationship}
            ${connection.model}
          </li>
        `,
          )
          .join("")}
      </ul>

      <h3>Impact</h3>
      <p>${impact.length} reachable models</p>
      <ul>
        ${impact.map((model) => `<li>${model}</li>`).join("")}
      </ul>
    `;
  }

  showPath(path) {
    this.container.innerHTML = `
      <h2>Shortest Path</h2>
      <ul>
        ${path.map((node) => `<li>${node}</li>`).join("")}
      </ul>
      <p>Path length: ${path.length - 1}</p>
    `;
  }
}
