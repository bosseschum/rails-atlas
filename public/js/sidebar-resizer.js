export class SidebarResizer {
  constructor({ sidebar, handle, networkContainer, onResize }) {
    this.sidebar = sidebar;
    this.networkContainer = networkContainer;
    this.onResize = onResize;

    this.handleMouseMove = this.handleMouseMove.bind(this);
    this.handleMouseUp = this.handleMouseUp.bind(this);

    handle.addEventListener("mousedown", () => {
      document.addEventListener("mousemove", this.handleMouseMove);
      document.addEventListener("mouseup", this.handleMouseUp);
    });
  }

  handleMouseMove(event) {
    const newWidth = window.innerWidth - event.clientX;
    if (newWidth <= 200 || newWidth >= 600) return;

    this.sidebar.style.width = `${newWidth}px`;
    this.networkContainer.style.width = `calc(100vw - ${newWidth}px)`;

    if (this.onResize) this.onResize();
  }

  handleMouseUp() {
    document.removeEventListener("mousemove", this.handleMouseMove);
    document.removeEventListener("mouseup", this.handleMouseUp);
  }
}
