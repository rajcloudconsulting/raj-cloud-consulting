# Visual Customisation

## Brand colours

Edit CSS variables near the top of `assets/css/styles.css`:

```css
--bg: #050914;
--cyan: #2ad4ff;
--blue: #3388ff;
--purple: #8f6cff;
```

## Hero technologies

The floating hero nodes are inside `index.html` under `.orbital-scene`.
Each node has a `data-detail` attribute used by JavaScript.

## Architecture diagram

Architecture labels and node positions are defined in the SVG within
`#architecture`. Text displayed when a node is selected is defined in
`architectureData` inside `assets/js/main.js`.

## Terminal animation

Edit `terminalSteps` in `assets/js/main.js`.

## Performance

No external 3D library is used. The 3D appearance is built with CSS transforms,
SVG and lightweight JavaScript to keep GitHub Pages fast.
