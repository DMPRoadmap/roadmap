
const Layout = ({children}) => {
  return (
    <>
      <header className="todo"> Header </header>
      <main>{children}</main>
      <footer className="todo"> Footer </footer>
    </>
  )
}

export default Layout;
