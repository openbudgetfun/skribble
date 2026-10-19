// Progressive enhancement for skribble.dev. Every control works and every
// drawing is visible without this file; it adds draw-on reveals, the theme
// toggle, copy buttons, live slider values, and seed shuffling.
(function () {
  "use strict";

  var root = document.documentElement;

  // Replays the draw-on animation inside an element.
  function redraw(element) {
    element.classList.remove("is-in");
    void element.getBoundingClientRect();
    element.classList.add("is-in");
  }

  // Reveal sections and draw their ink as they scroll into view, once the
  // page's fonts are in (see the inline script in <head>).
  function startReveals() {
  var targets = document.querySelectorAll(".draw, .reveal");
  if ("IntersectionObserver" in window) {
    var observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-in");
          observer.unobserve(entry.target);
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.12 },
    );
    targets.forEach(function (target) {
      observer.observe(target);
    });
  } else {
    targets.forEach(function (target) {
      target.classList.add("is-in");
    });
  }
  }
  if (root.classList.contains("inking")) {
    document.addEventListener("skribble:inked", startReveals, { once: true });
  } else {
    startReveals();
  }

  // Light and dark paper, remembered per browser.
  var toggle = document.querySelector(".theme-toggle");
  if (toggle) {
    var media = window.matchMedia("(prefers-color-scheme: dark)");
    var isDark = function () {
      return root.dataset.theme
        ? root.dataset.theme === "dark"
        : media.matches;
    };
    var label = function () {
      toggle.setAttribute(
        "aria-label",
        isDark() ? "Switch to light paper" : "Switch to dark paper",
      );
    };
    toggle.hidden = false;
    label();
    toggle.addEventListener("click", function () {
      root.dataset.theme = isDark() ? "light" : "dark";
      try {
        localStorage.setItem("skribble-theme", root.dataset.theme);
      } catch (error) {}
      label();
    });
    media.addEventListener("change", label);
  }

  // Copy buttons.
  document.querySelectorAll("[data-copy]").forEach(function (button) {
    button.addEventListener("click", function () {
      if (!navigator.clipboard) return;
      navigator.clipboard.writeText(button.dataset.copy).then(function () {
        var text = button.textContent;
        button.textContent = "Copied!";
        setTimeout(function () {
          button.textContent = text;
        }, 1600);
      });
    });
  });

  // Live values next to range inputs.
  document.querySelectorAll('input[type="range"][id]').forEach(function (input) {
    var output = document.querySelector('output[for="' + input.id + '"]');
    if (!output || input.id === "hero-pen") return;
    input.addEventListener("input", function () {
      output.textContent = input.value;
    });
  });

  // The phone's pen slider redraws the phone with another pen.
  var pens = ["gentle", "playful", "expressive"];
  var names = ["Gentle", "Playful", "Expressive"];
  var penSlider = document.getElementById("hero-pen");
  var phone = document.querySelector(".phone");
  if (penSlider && phone) {
    var penName = document.querySelector('output[for="hero-pen"]');
    penSlider.addEventListener("input", function () {
      var index = Number(penSlider.value);
      phone.dataset.pen = pens[index];
      penSlider.setAttribute("aria-valuetext", names[index]);
      if (penName) penName.textContent = names[index];
      redraw(phone);
    });
  }

  // The install command follows the chosen font family's package.
  var fontInstall = document.querySelector("[data-font-install]");
  document.querySelectorAll('input[name="font-family"]').forEach(function (input) {
    input.addEventListener("change", function () {
      if (fontInstall && input.checked) {
        fontInstall.textContent = "flutter pub add " + input.dataset.package;
      }
    });
  });

  // The specimen's weight slider.
  var weight = document.getElementById("font-weight");
  var lab = document.querySelector(".font-lab");
  if (weight && lab) {
    weight.addEventListener("input", function () {
      lab.style.setProperty("--specimen-weight", weight.value);
    });
  }

  // Shuffle the fill gallery through its pre-drawn seeds.
  var gallery = document.querySelector(".fill-grid");
  var shuffle = document.querySelector("[data-shuffle]");
  if (gallery && shuffle) {
    shuffle.addEventListener("click", function () {
      gallery.dataset.seed = String((Number(gallery.dataset.seed) + 1) % 3);
      gallery.querySelectorAll(".fill-card").forEach(redraw);
    });
  }
})();
