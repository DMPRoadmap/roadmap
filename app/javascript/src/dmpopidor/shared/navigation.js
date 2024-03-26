document.addEventListener('DOMContentLoaded', () => {
  window.addEventListener('scroll', (event) => {
    const scrollY = window.scrollY;
    const width = screen.width;
    const body = document.querySelector('body');

    if (scrollY > 50 && width > 767) {
      body.classList.add('is-scrolled');
    } else {
      body.classList.remove('is-scrolled');
    }
  });
});
