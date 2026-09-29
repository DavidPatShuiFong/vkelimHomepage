<%
// Masonry card listing, used by the home page "Featured Posts" and "Posts".
// Cards are placed left to right into the shortest column by Masonry
// (https://masonry.desandro.com), so newest-first order reads across rows.
// Columns: 3 on desktop, 2 on tablets, 1 on phones (theme/common.scss).
// Custom templates only receive `items` (not `listing`), so each field is
// shown when the item has it.
const showField = (item, field) => item[field] !== undefined && item[field] !== "";
%>

```{=html}
<div class="posts-masonry">
<div class="pm-sizer"></div>
<div class="pm-gutter"></div>
```

<% for (const item of items) { %>

```{=html}
<div class="pm-item">
<a href="<%- item.path %>" class="pm-link">
<div class="card pm-card">
<% if (showField(item, 'image') && item.image) { %>
<img src="<%- item.image %>" class="card-img-top pm-img" alt="<%= item['image-alt'] || '' %>" loading="lazy">
<% } %>
<div class="card-body">
<% if (showField(item, 'title')) { %>
<h5 class="no-anchor card-title listing-title"><%= item.title %></h5>
<% } %>
<% if (showField(item, 'description')) { %>
<div class="card-text listing-description delink">
```

<%= item.description %>

```{=html}
</div>
<% } %>
<% if (showField(item, 'author') || showField(item, 'date')) { %>
<div class="card-attribution">
<% if (showField(item, 'author')) { %><span class="listing-author"><%= item.author %></span><% } %>
<% if (showField(item, 'date')) { %><span class="listing-date"><%= item.date %></span><% } %>
</div>
<% } %>
</div>
</div>
</a>
</div>
```

<% } %>

```{=html}
</div>
<script src="https://cdn.jsdelivr.net/npm/masonry-layout@4.2.2/dist/masonry.pkgd.min.js"></script>
<script>
(() => {
  // Set up every masonry listing not yet initialised (this script is
  // emitted once per listing, each time after that listing's cards).
  if (typeof Masonry === "undefined") return;  // CSS fallback keeps cards readable
  for (const grid of document.querySelectorAll(".posts-masonry:not(.pm-js)")) {
    grid.classList.add("pm-js");
    const msnry = new Masonry(grid, {
      itemSelector: ".pm-item",
      columnWidth: ".pm-sizer",
      gutter: ".pm-gutter",
      percentPosition: true,
      transitionDuration: 0,  // no sliding while images load
    });
    // Card heights change as lazy images and web fonts load: re-lay out
    // (once per frame) whenever any card changes size.
    let pending = false;
    const relayout = () => {
      if (pending) return;
      pending = true;
      requestAnimationFrame(() => { pending = false; msnry.layout(); });
    };
    const observer = new ResizeObserver(relayout);
    grid.querySelectorAll(".pm-item").forEach((el) => observer.observe(el));
  }
})();
</script>
```
