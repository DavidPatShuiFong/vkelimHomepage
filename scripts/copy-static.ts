// Quarto post-render script: copy static/ into the site output directory so
// files are served from the site root, as Hugo does with its static/ folder
// (e.g. static/CV/cv.pdf -> /CV/cv.pdf).
const outDir = Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR") ?? "_site";

function copyDir(src: string, dest: string) {
  Deno.mkdirSync(dest, { recursive: true });
  for (const entry of Deno.readDirSync(src)) {
    const from = `${src}/${entry.name}`;
    const to = `${dest}/${entry.name}`;
    if (entry.isDirectory) {
      copyDir(from, to);
    } else if (entry.isFile) {
      Deno.copyFileSync(from, to);
    }
  }
}

// Only run on full project renders, not when previewing a single file.
if (Deno.env.get("QUARTO_PROJECT_RENDER_ALL")) {
  copyDir("static", outDir);
}
