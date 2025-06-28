---
layout: default
title: Research
---

<h2>Molecular Structure Viewer (NGL)</h2>

<div id="ngl-container" style="width: 600px; height: 600px; margin: 1rem auto;"></div>

<script>
  var stage = new NGL.Stage("ngl-container");

  window.addEventListener("resize", () => stage.handleResize());

  function updateNglBackground(theme) {
    if (theme === "dark") {
      stage.setParameters({ backgroundColor: 0x1b1b1b });
    } else {
      stage.setParameters({ backgroundColor: 0xffffff });
    }
  }

  // Initial background color based on current theme
  updateNglBackground(document.documentElement.getAttribute("data-theme"));

  // Load structure with chain-specific coloring
  stage.loadFile("assets/structures/4dxr.pdb").then(function(component) {
    component.addRepresentation("cartoon", {
      color: "chainname",
      sele: "chain A or chain B"
    });
    component.autoView();
  });

  // Listen to theme change event and update background
  window.addEventListener("themeChanged", (event) => {
    updateNglBackground(event.detail.theme);
  });
</script>
