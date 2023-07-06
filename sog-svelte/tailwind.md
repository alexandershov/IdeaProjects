## Tailwind

Tailwind is a CSS framework.

It uses composable utility classes and embraces functional CSS when you 
compose several CSS classes inline (e.g "text-3xl underline"). 

Here's how to add tailwind to sveltekit project.

Install tailwind
```shell
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Add `content: ['./src/**/*.{html,js,svelte,ts}']` to [tailwind.config.js](tailwind.config.js).

Create [app.css](src/app.css) file with tailwind directives.

Modify [+layout.svelte](./src/routes/+layout.svelte) with `import "../app.css";`

Run server
```shell
npm run dev
```

See example of styling in [+page.svelte](src/routes/+page.svelte)
