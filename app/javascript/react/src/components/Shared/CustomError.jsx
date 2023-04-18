import React from "react";
import styled from "styled-components";

const ErrorContainer = styled.div`
  height: 100vh !important;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  font-family: montserrat, sans-serif;
`;

const BigText = styled.div`
  font-size: 200px;
  font-weight: 900;
  font-family: sans-serif;
  background: url(https://i.imgur.com/mEPnGth.jpg) no-repeat;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-size: cover;
  background-position: center;
`;

const SmallText = styled.div`
  font-family: montserrat, sans-serif;
  color: rgb(0, 0, 0);
  font-size: 24px;
  font-weight: 700;
  text-transform: uppercase;
`;

const Button = styled.button`
  color: #fff;
  padding: 12px 36px;
  font-weight: 600;
  border: none;
  position: relative;
  font-family: "Raleway", sans-serif;
  display: inline-block;
  text-transform: uppercase;
  border-radius: 90px;
  margin: 2px;
  margin-top: 2px;
  background-image: linear-gradient(to right, #09b3ef 0%, #1e50e2 51%, #09b3ef 100%);
  background-size: 200% auto;
  flex: 1 1 auto;
  text-decoration: none;

  &:hover,
  &:focus {
    color: #ffffff;
    background-position: right center;
    box-shadow: 0px 5px 15px 0px rgba(0, 0, 0, 0.1);
    text-decoration: none;
  }
`;

/* The `CustomError` function is defining a React component that renders an error page with a 404 message and a button to return to the homepage. It uses
styled components to define the styling of the page elements. The component returns JSX code that defines the structure and content of the error page. */
function CustomError() {
  return (
    <ErrorContainer className="container">
      <div className="row d-flex align-items-center justify-content-center">
        <div className="col-md-12 text-center">
          <BigText>Oops!</BigText>
          <SmallText>404 - PAGE NOT FOUND</SmallText>
        </div>
        <div className="col-md-12 text-center">
          <p>La page que vous recherchez a peut-être été supprimée, son nom a changé ou est temporairement indisponible.</p>

          <Button>
            <a href="/">Page d'accueil </a>
          </Button>
        </div>
      </div>
    </ErrorContainer>
  );
}

export default CustomError;
