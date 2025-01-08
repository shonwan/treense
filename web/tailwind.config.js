/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./views/**/*.{html,}",
            "./public/**/*.{html,js}"
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1D4ED8',    // Example: Blue primary color
        secondary: '#4ADE80',  // Example: Green secondary color
        background: '#F3F4F6', // Example: Light background color
        darkGray: '#2D3748',   // Example: Dark gray for text and backgrounds
        lightGray: '#E2E8F0',  // Example: Light gray for borders and backgrounds
      },
      fontSize: {
        'xxl': '2rem',   // Custom font size
        'xxxl': '3rem',  // Custom font size
      },
      fontFamily: {
        sans: ['Helvetica Neue', 'Arial', 'sans-serif'],
        serif: ['Georgia', 'serif'],
      },
      spacing: {
        '128': '32rem',   // Custom spacing size
        '144': '36rem',   // Custom spacing size
      },
      borderRadius: {
        '4xl': '2rem',   // Custom border radius size
        '5xl': '2.5rem', // Custom border radius size
      },
      boxShadow: {
        'light': '0 4px 6px rgba(0, 0, 0, 0.1)',  // Example: Light shadow
        'dark': '0 10px 20px rgba(0, 0, 0, 0.15)', // Example: Dark shadow
      },
      screens: {
        'xs': '480px',   // Custom small screen size (mobile)
        'sm': '640px',   // Tailwind's default small screen size
        'md': '768px',   // Tailwind's default medium screen size
        'lg': '1024px',  // Tailwind's default large screen size
        'xl': '1280px',  // Tailwind's default extra large screen size
        '2xl': '1536px', // Tailwind's default 2x extra large screen size
      },
      animation: {
        'fade': 'fadeIn 0.5s ease-out', // Custom fade animation
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
