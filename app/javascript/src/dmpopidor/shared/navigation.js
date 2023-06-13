document.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('scroll', (event) => {
        let scrollY = window.scrollY;
        let width = screen.width;
        let body = document.querySelector('body');

        if (scrollY > 100 && width > 767) {
            body.classList.add('is-scrolled');
        } else {
            body.classList.remove('is-scrolled');
        }
    });

    const button = document.getElementById('create-account-over');
    const form = document.getElementById('create-account-form');

    button.addEventListener('click', () => {
        button.style.display = "none";
        form.style.opacity = "0";
        form.style.transition = "visibility 0s 2s, opacity 2s linear;";
        form.style.display = "block";
        setTimeout(() => {
            form.style.opacity = "1";
        }, 100)
    });

});