# CSS Blocks

Blocks refer to reusable units within the CSS files. Where practicable, we should always try to define a general block or UX concept, rather than styling indivudual elements.

Example:

``` css
/* BAD */

/*<form id="new_user_form">...*/
#new_user_form {
  font-size: 1.2rem;
  margin-left: 14px;
  margin-right: 14px;
  border: thin solid silver;
}

/* BETTER */

/*<form class="bordered-form">...*/
.bordered-form {
  font-size: 1.2rem;
  margin-left: 14px;
  margin-right: 14px;
  border: thin solid silver;
}

/* BEST */

/*<form class="larger margined bordered">...*/
.larger {
  font-size: 1.2rem;
}
.margined {
  margin-left: 14px;
  margin-right: 14px;
}
.bordered {
  border: thin solid silver;
}
```
