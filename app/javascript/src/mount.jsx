import React from "react";
import ReactDOM from "react-dom/client";

export default function mount(components) {
  document.addEventListener("DOMContentLoaded", () => {
    const mountPoints = document.querySelectorAll("[data-react-component]");
    mountPoints.forEach((mountPoint) => {
      const { dataset } = mountPoint;
      const componentName = dataset.reactComponent;
      if (componentName) {
        const Component = components[componentName];
        if (Component) {
          const props = JSON.parse(dataset.props);
          const root = ReactDOM.createRoot(mountPoint);
          root.render(<Component {...props} />);
        } else {
          console.warn(
            "WARNING: No component found for: ",
            dataset.reactComponent,
            components
          );
        }
      }
    });
  });
}
