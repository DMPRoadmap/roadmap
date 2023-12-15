
const mobileMenuOpenIcon = document.getElementById('mobile-menu-open')
const mobileMenuCloseIcon = document.getElementById('mobile-menu-close')
const mobileMenu = document.getElementById('mobile-navigation')

console.log(mobileMenu)
console.log(mobileMenuOpenIcon)
console.log(mobileMenuCloseIcon)

if (mobileMenu !== undefined) {
  mobileMenuOpenIcon.addEventListener('click', () => {
    mobileMenu.style.right = '0';
  })
  mobileMenuCloseIcon.addEventListener('click', () => {
    mobileMenu.style.right = '-300px';
  })
}
