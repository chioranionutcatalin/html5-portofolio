(function () {
  var form = document.getElementById("contact-form");

  if (!form) {
    return;
  }

  function getValue(fieldName) {
    var field = form.elements[fieldName];
    return ((field && field.value) || "").trim();
  }

  form.addEventListener("submit", function (event) {
    event.preventDefault();

    var recipient = form.getAttribute("data-recipient") || "";
    var name = getValue("name");
    var email = getValue("email");
    var subject = getValue("subject");
    var message = getValue("message");

    var finalSubject = subject || "Message from portfolio website";
    var finalBody = "Name: " + name + "\n" + "Email: " + email + "\n\n" + message;

    var mailtoUrl =
      "mailto:" +
      encodeURIComponent(recipient) +
      "?subject=" +
      encodeURIComponent(finalSubject) +
      "&body=" +
      encodeURIComponent(finalBody);

    window.location.href = mailtoUrl;
  });
})();
