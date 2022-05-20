module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    textColor: (theme) => ({
      ...theme("colors"),
      primary: "#0952DE",
    }),
    backgroundColor: (theme) => ({
      ...theme("colors"),
      primary: "#0952DE",
    }),
    borderColor: (theme) => ({
      ...theme("colors"),
      primary: "#0952DE",
    }),
    ringColor: (theme) => ({
      ...theme("colors"),
      primary: "#0952DE",
    }),
  },
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/typography'),
    require('tailwind-scrollbar-hide'),
  ],
};
