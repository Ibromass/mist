# MIST & BLOOM

A responsive storefront made with plain HTML, CSS and JavaScript. The mini humidifier is the main product; aroma oils are extras included with selected packages.

## Open the site

Open `index.html` in a browser, or use VS Code Live Server. If the local preview says `ERR_CONNECTION_REFUSED`, restart Live Server and refresh the page.

## Packages

- Fresh Start - NGN 13,500: 1 mini humidifier and 1 lemon aroma oil.
- Double Refresh - NGN 24,500: 2 mini humidifiers, 1 lemon oil and 1 strawberry oil.
- Ultimate Refresh - NGN 34,500: 3 mini humidifiers, 2 lemon oils and 2 strawberry oils.
- Free delivery is shown for all packages.

Each Order now button adds that package to the saved bag and opens the order form. The bag uses this browser's localStorage and is not shared across devices.

## Email order requests

There is no backend, payment integration, email API or order database. Submitting the form opens an email draft addressed to `abolarinwaibraheem@gmail.com`; the customer must press Send in their email app. The website cannot confirm that an email was sent or received.

## Product media

Supplied photos and videos are in `assets/products/`. The wide hero video uses `humidifier.mp4`, the replacement clip supplied by the customer. The two demonstration clips are `humid2.mp4` and `humid3.mp4`. Videos try audible autoplay when visible; browser autoplay rules may require them to start muted until the customer selects Enable sound.

Package collages show the exact humidifier and oil quantities listed above. Mobile layouts use the matching `bundle-*-mobile.jpg` photos. Aroma oils are package extras; no compatibility with the humidifier water tank is claimed.
