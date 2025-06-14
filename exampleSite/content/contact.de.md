+++
title = "Kontakt"
date = "2025-06-08"
slug = "contact"
author = "Artem Kozlenkov"
+++

<style>
h1 {
    font-family: 'Poppins', sans-serif, 'arial';
    font-weight: 600;
    font-size: 72px;
    color: #606060;
    text-align: center;
}

h4 {
    font-family: 'Roboto', sans-serif, 'arial';
    font-weight: 400;
    font-size: 20px;
    color: #9b9b9b;
    line-height: 1.5;
}

/* ///// inputs ///// */

input:focus ~ label,
textarea:focus ~ label,
input.has-content ~ label,
textarea.has-content ~ label {
    font-size: 0.75em;
    color: #525151;
    top: -5px;
    opacity: 0;
    pointer-events: none;
    -webkit-transition: all 0.225s ease;
    transition: all 0.225s ease;
}

.contact-styled-input {
    float: left;
    width: 293px;
    margin: 1rem 0;
    position: relative;
    border-radius: 4px;
}

@media only screen and (max-width: 768px){
    .contact-styled-input {
        width:100%;
    }
}

.contact-styled-input label {
    color: #999;
    padding: 1.3rem 30px 1rem 30px;
    position: absolute;
    top: 10px;
    left: 0;
    -webkit-transition: all 0.25s ease;
    transition: all 0.25s ease;
    pointer-events: none;
}

.contact-styled-input.contact-wide { 
    width: 650px;
    max-width: 100%;
}

.contact-input,
.contact-textarea {
    padding: 30px;
    border: 0;
    width: 100%;
    font-size: 1rem;
    background-color:rgb(216, 216, 216);
    color: #646464;
    border-radius: 4px;
}

.contact-input:focus,
.contact-textarea:focus { outline: 0; }

.contact-input:focus ~ span,
.contact-textarea:focus ~ span {
    width: 100%;
    -webkit-transition: all 0.075s ease;
    transition: all 0.075s ease;
}

.contact-textarea {
    width: 100%;
    min-height: 15em;
}

.contact-input-container {
    width: 650px;
    max-width: 100%;
    margin: 20px auto 25px auto;
}

.contact-submit-btn {
    float: right;
    padding: 7px 35px;
    border-radius: 60px;
    display: inline-block;
    background-color: #4b8cfb;
    color: white;
    font-size: 18px;
    cursor: pointer;
    box-shadow: 0 2px 5px 0 rgba(0,0,0,0.06),
              0 2px 10px 0 rgba(0,0,0,0.07);
    -webkit-transition: all 300ms ease;
    transition: all 300ms ease;
}

.contact-submit-btn:hover {
    transform: translateY(1px);
    box-shadow: 0 1px 1px 0 rgba(0,0,0,0.10),
              0 1px 1px 0 rgba(0,0,0,0.09);
}

@media (max-width: 768px) {
    .contact-submit-btn {
        width:100%;
        float: none;
        text-align:center;
    }
}

input[type=checkbox] + label {
  color: #ccc;
  font-style: italic;
} 

input[type=checkbox]:checked + label {
  color: #f00;
  font-style: normal;
}
</style>

<div class="contact-container">
  <div class="contact-row">
    <h4 style="text-align:center">Wir würden uns freuen, von Ihnen zu hören!</h4>
  </div>
  <form action="https://formspree.io/f/xanjeyzo" method="POST" class="contact-row contact-input-container" novalidate>
    <div class="contact-col-xs-12">
      <div class="contact-styled-input contact-wide">
        <input class="contact-input" type="text" name="name" required />
        <label>Name</label> 
      </div>
    </div>
    <div class="contact-col-md-6 contact-col-sm-12">
      <div class="contact-styled-input">
        <input class="contact-input" type="email" name="email" required />
        <label>E-Mail</label> 
      </div>
    </div>
    <div class="contact-col-md-6 contact-col-sm-12">
      <div class="contact-styled-input" style="float:right;">
        <input class="contact-input" type="tel" name="sender_phone" placeholder="+41 77 123 45 67" pattern="^\+?[0-9\s\-]{7,15}$" />
        <label>Telefonnummer</label> 
      </div>
    </div>
    <div class="contact-col-xs-12">
      <div class="contact-styled-input contact-wide">
        <textarea class="contact-textarea" name="message" required></textarea>
        <label>Nachricht</label>
      </div>
    </div>
    <div class="contact-col-xs-12">
      <button type="submit" class="contact-btn-lrg contact-submit-btn">Nachricht senden</button>
    </div>
  </form>
</div>

<script>
document.querySelectorAll('.contact-input, .contact-textarea').forEach(input => {
  function toggleHasContent() {
    if (input.value.length > 0) {
      input.classList.add('has-content');
    } else {
      input.classList.remove('has-content');
    }
  }
  input.addEventListener('input', toggleHasContent);
  toggleHasContent();
});
</script>