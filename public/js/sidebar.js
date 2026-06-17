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

  showModel(name, metrics, connections, impact) {
    this.container.innerHTML = `
      <h2>${name}</h2>

      <h3>Metrics</h3>
      <ul>
        <li>Connections: ${metrics.degree}</li>
        <li>Incoming: ${metrics.incoming}</li>
        <li>Outgoing: ${metrics.outgoing}</li>
        <li>Impact Reach: ${metrics.impact}</li>
      </ul>

      <h3>Connections</h3>
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

  showSmells(smells) {
    const godModels = Object.entries(smells.god_models || {})
      .map(([m, c]) => `<li>${m} — ${c} connections</li>`)
      .join("");

    const orphans = (smells.orphan_models || [])
      .map((m) => `<li>${m}</li>`)
      .join("");

    const hotspots = (smells.hotspots || [])
      .map((pair) => {
        // pair may be [model, count]
        if (Array.isArray(pair)) {
          return `<li>${pair[0]} — ${pair[1]}</li>`;
        }
        return `<li>${pair}</li>`;
      })
      .join("");

    this.container.innerHTML = `
         <h2>Smells</h2>

         <h3>God Models</h3>
         <ul>${godModels || "<li>None found</li>"}</ul>

         <h3>Orphans</h3>
         <ul>${orphans || "<li>None found</li>"}</ul>

         <h3>Hotspots</h3>
         <ul>${hotspots || "<li>None found</li>"}</ul>
       `;
  }
}
