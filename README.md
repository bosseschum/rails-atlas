# Rails Atlas 🗺️

**Rails Atlas** is an architecture analysis and dependency visualization tool for Ruby on Rails applications.

It uses fast, static AST parsing (via Ruby's `prism` parser) to extract ActiveRecord models and associations without booting Rails or connecting to a database. Atlas provides both a comprehensive Command Line Interface (CLI) and an interactive Web UI to explore model relationships, discover architectural hotspots, detect design smells, and analyze change impact.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Command Line Interface (CLI)](#command-line-interface-cli)
  - [`atlas scan`](#atlas-scan-path)
  - [`atlas stats`](#atlas-stats-path)
  - [`atlas graph`](#atlas-graph-path)
  - [`atlas model`](#atlas-model-path-model)
  - [`atlas path`](#atlas-path-path-start-end)
  - [`atlas neighbors`](#atlas-neighbors-path-model)
  - [`atlas hotspots`](#atlas-hotspots-path-limit)
  - [`atlas smells`](#atlas-smells-path)
  - [`atlas impact`](#atlas-impact-path-model)
  - [`atlas serve`](#atlas-serve-path)
- [Interactive Web UI](#interactive-web-ui)
  - [Web Features & Shortcuts](#web-features--shortcuts)
  - [REST API Endpoints](#rest-api-endpoints)
- [Architectural Metrics & Smells](#architectural-metrics--smells)
- [How It Works](#how-it-works)
- [Development](#development)
- [License](#license)

---

## Features

- **Static Analysis (Fast & Safe):** Parses Rails models using Ruby 3.3+ `prism` AST parser. No need to boot Rails, load the database, or execute application code.
- **Zeitwerk-Aware Namespace Resolution:** Accurately resolves namespaced model associations (e.g. `Treasurer::Request` → `has_many :line_items` resolves to `Treasurer::LineItem` when present).
- **Association Extraction:** Identifies `belongs_to`, `has_many`, `has_one`, and `has_and_belongs_to_many` (HABTM) associations while ignoring non-model concerns (`app/models/concerns`).
- **Graph & Dependency Analysis:**
  - Shortest path routing between any two models.
  - Blast radius & transitive impact analysis.
  - Inbound and outbound dependency breakdown.
  - Architectural hotspots detection (most connected models).
- **Design Smell Detection:**
  - **God Models:** Models with high coupling ($\ge 10$ total connections).
  - **Orphan / Leaf Models:** Models with $\le 1$ connection.
- **Export Formats:** Export architecture graphs to `atlas.json` and Graphviz `atlas.dot`.
- **Interactive Web Visualizer:** Built-in Sinatra web server with interactive `vis-network` graph, real-time search, association filters, path finder, and smells panel.

---

## Requirements

- **Ruby:** `>= 3.2.0`
- **Target Rails App:** Rails 5/6/7/8 applications structured with standard `app/models`.

---

## Installation

### As a Gem

Add `rails-atlas` to your Rails application's `Gemfile` (typically in the development group):

```ruby
group :development do
  gem 'rails-atlas'
end
```

And install:

```bash
bundle install
```

### Standalone / Local Clone

You can also run Atlas directly against any Rails application directory:

```bash
git clone https://github.com/bosseschum/rails-atlas.git
cd rails-atlas
bundle install
bin/atlas help
```

---

## Command Line Interface (CLI)

Run commands using `bundle exec atlas <command>` (or `bin/atlas <command>`):

```
Commands:
  atlas graph PATH              # Generate graph files (atlas.dot)
  atlas help [COMMAND]          # Describe available commands or one specific command
  atlas hotspots PATH [LIMIT]   # Show architecture hotspots
  atlas impact PATH MODEL       # Analyze impact of a model
  atlas model PATH MODEL        # Inspect a model
  atlas neighbors PATH MODEL    # Show directly connected neighbors
  atlas path PATH START END     # Find path between two models
  atlas scan PATH               # Scan a Rails application
  atlas serve PATH              # Serve the architecture graph
  atlas smells PATH             # Show architectural smells
  atlas stats PATH              # Show graph statistics
```

> **Note:** `PATH` can be a relative or absolute path to the root directory of your Rails application (e.g., `.` or `../my-rails-app`).

---

### `atlas scan PATH`

Scans the target Rails application and writes the entire architecture graph (nodes and edges) to `atlas.json`.

```bash
atlas scan .
```

**Output:**
```
Scan complete. Atlas graph saved to atlas.json
```

---

### `atlas stats PATH`

Displays a high-level summary of the application's domain model architecture, including total models, total associations, most connected models, association type breakdowns, and top architecture hotspots.

```bash
atlas stats .
```

**Example Output:**
```
Atlas Statistics
----------------

Models: 42
Associations: 98

Most Connected Models:
----------------
User: 24
Organization: 18
Project: 12
Order: 10

Association Types:
----------------
belongs_to: 52
has_many: 38
has_one: 6
has_and_belongs_to_many: 2

Architecture Hotspots:
----------------
User
Organization
Project
Order
```

---

### `atlas graph PATH`

Exports the architecture model graph to a Graphviz DOT format file (`atlas.dot`), which can be converted to PNG, SVG, or PDF using Graphviz `dot`.

```bash
atlas graph .
```

**Output:**
```
Generate atlas.dot
```

*Convert to image using Graphviz:*
```bash
dot -Tpng atlas.dot -o architecture.png
```

---

### `atlas model PATH MODEL`

Inspects a specific model, listing its incoming and outgoing associations.

```bash
atlas model . User
```

**Example Output:**
```
Model: User

Outgoing Associations:
----------------------
belongs_to organization
has_many projects
has_many orders

Incoming Associations:
----------------------
Comment belongs_to author
Membership belongs_to user
```

---

### `atlas path PATH START END`

Calculates and displays the shortest dependency path between two models using breadth-first search (BFS).

```bash
atlas path . Order Invoice
```

**Example Output:**
```
Order
 ↓
Payment
 ↓
Invoice
```

If no path connects the two models, it outputs `No path found`.

---

### `atlas neighbors PATH MODEL`

Lists all directly connected models, indicating directional flow (`[IN]` or `[OUT]`) and association details.

```bash
atlas neighbors . Organization
```

**Example Output:**
```
Model: Organization

Directly Connected Models
-------------------------
[OUT] has_many members → Member
[OUT] has_many projects → Project
[IN] User belongs_to organization
```

---

### `atlas hotspots PATH [LIMIT]`

Ranks and displays the top architectural hotspots (models with the highest degree of connectivity).

```bash
atlas hotspots . 5
```

**Example Output:**
```
Architectural Hotspots
---------------------

User (24)
Organization (18)
Project (12)
Order (10)
Account (8)
```

---

### `atlas smells PATH`

Runs heuristic smell detection across the model graph:
- **Potential God Models:** Models with $\ge 10$ incoming and outgoing connections.
- **Leaf / Orphan Models:** Models with $\le 1$ connection (isolated or peripheral models).

```bash
atlas smells .
```

**Example Output:**
```
Architectural Smells
-------------------

Potential God Models
-------------------
User - 24 connections
Organization - 18 connections

Leaf Models
-----------
AuditLog
FeatureFlag
Setting
```

---

### `atlas impact PATH MODEL`

Performs blast radius / reachability analysis. Displays all models transitively reachable from the target model across the graph component, along with the total reach count.

```bash
atlas impact . Organization
```

**Example Output:**
```
Impact Analysis: Organization
-------------------------

Account
Invoice
Member
Order
Payment
Project
Subscription
User

Total Reach: 8 models
```

---

### `atlas serve PATH`

Starts the interactive Atlas Web UI backed by Sinatra at `http://localhost:4567`.

```bash
atlas serve .
```

**Output:**
```
== Sinatra (v4.0.0) has taken the stage on 4567 for development with backup from WEBrick
[2026-11-02 13:46:00] INFO  WEBrick::HTTPServer#start: pid=... port=4567
```

Open `http://localhost:4567` in your browser.

---

## Interactive Web UI

The web visualizer renders your Rails architecture graph using `vis-network` and provides real-time interaction.

### Web Features & Shortcuts

- **Graph Exploration:** Pan, zoom, and drag nodes to inspect relationships.
- **Model Search:** Filter models by name dynamically using the top search bar.
- **Association Filters:** Toggle checkboxes to filter visible edge types:
  - `belongs_to`
  - `has_many`
  - `has_one`
  - `habtm` (`has_and_belongs_to_many`)
- **Edge Labels:** Checkbox to toggle association relationship names on edges.
- **Model Details & Metrics Sidebar:** Click any model node to view:
  - **Metrics:** Total connections (Degree), Incoming count, Outgoing count, Impact reach count.
  - **Connections:** Inbound ($\leftarrow$) and Outbound ($\rightarrow$) associations.
  - **Impact Reach:** All reachable models in the dependency graph.
- **Shortest Path Finder:**
  - <kbd>Shift</kbd> + **Click** node A to set start point.
  - <kbd>Shift</kbd> + **Click** node B to set end point and visualize the highlighted shortest path.
- **Architectural Smells Panel:** Click the **Smells** button in the top bar to inspect God Models, Orphan Models, and Hotspots in the sidebar.
- **Resizable Sidebar:** Drag the sidebar handle to adjust view widths.

### REST API Endpoints

The Sinatra backend exposes the following JSON endpoints:

| Endpoint | Description |
| :--- | :--- |
| `GET /api/graph` | Full graph data with nodes, degrees, and edges |
| `GET /api/models` | List of all model node objects |
| `GET /api/models/:name` | Direct incoming and outgoing connections for `:name` |
| `GET /api/model/:name` | Graph metrics for `:name` (degree, impact, incoming, outgoing, hotspot, orphan) |
| `GET /api/impact/:name` | Array of transitively reachable models starting from `:name` |
| `GET /api/path/:from/:to` | Array of nodes representing the shortest path between `:from` and `:to` |
| `GET /api/smells` | Architectural smells summary (`god_models`, `orphans`, `high_impact`) |

---

## Architectural Metrics & Smells

| Metric / Smell | Definition | Purpose |
| :--- | :--- | :--- |
| **Degree** | Total incoming + outgoing associations | Measures model coupling and centrality |
| **Impact Reach** | Number of reachable models via graph traversal | Evaluates blast radius when refactoring or migrating a model |
| **God Model** | Total connections $\ge 10$ | Identifies bloated models that may violate Single Responsibility Principle |
| **Orphan / Leaf Model** | Total connections $\le 1$ | Identifies isolated models, auxiliary tables, or dead domain concepts |
| **Hotspots** | Models sorted by descending degree | Highlights primary domain aggregates and integration points |

---

## How It Works

1. **Scanner (`Atlas::Scanner`):** Finds all `.rb` files in `app/models/` while excluding non-model files such as `app/models/concerns`.
2. **AST Association Extraction (`Atlas::AssociationExtractor`):** Uses Ruby's `Prism` parser to walk the AST and extract macro calls (`belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many`).
3. **Namespace Resolution (`Atlas::GraphBuilder`):** Resolves associations using Zeitwerk/ActiveRecord scoping rules (e.g., scoping under enclosing module namespaces before falling back to top-level constants).
4. **Graph Engine (`Atlas::Graph`):** Builds an in-memory graph representation with BFS path finding, reachable component traversal, degree calculations, and smell detectors.

---

## Development

```bash
# Clone the repository
git clone https://github.com/bosseschum/rails-atlas.git
cd rails-atlas

# Install development dependencies
bundle install

# Run RuboCop
bundle exec rubocop
```

---

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
