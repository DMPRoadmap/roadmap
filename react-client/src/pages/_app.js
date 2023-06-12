import '../main.css';
import Layout from '../components/Layout';


// This default export is required in a new `pages/_app.js` file.
export default function MyApp({ Component, pageProps }) {

  // Once the user request finishes, show the user
  return (
    <>
      <Layout>
        <Component {...pageProps} />
      </Layout>
    </>
  )
}
