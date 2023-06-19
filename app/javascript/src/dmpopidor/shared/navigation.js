document.addEventListener('DOMContentLoaded', function () {
    window.addEventListener('scroll', (event) => {

        let scrollY = window.scrollY;
        let width = screen.width;
        let body = document.querySelector('body');

        if (scrollY > 50 && width > 767) {
            body.classList.add('is-scrolled');
        } else {
            body.classList.remove('is-scrolled');
        }

    });

    try {
        const button = document.getElementById('create-account-over');
        const formRegister = document.getElementById('create-account-form');
        const div = document.querySelector('div.col-md-12 div.sign-in div.tab-content');


        button.addEventListener('click', () => {

            button.style.display = "none";
            div.style.alignItems = "flex-start";
            formRegister.style.opacity = "0";
            formRegister.style.transition = "visibility 0s 2s, opacity 2s linear;";
            formRegister.style.display = "block";

            setTimeout(() => {
                formRegister.style.opacity = "1";

            }, 100)
        });
    } catch (e) {

    }
});