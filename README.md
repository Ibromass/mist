# MIST & BLOOM

A responsive storefront made with plain HTML, CSS and JavaScript. The mini humidifier is the main product; aroma oils are extras included with selected packages.

## Open the site

Open `index.html` in a browser, or use VS Code Live Server. If the local preview says `ERR_CONNECTION_REFUSED`, restart Live Server and refresh the page.

## Packages

- Fresh Start - NGN 20,000: 1 mini humidifier + 1 free fragrance oil.
- Double Refresh - NGN 38,000: 2 mini humidifiers + 2 free fragrance oils.
- Ultimate Refresh - NGN 55,000: 3 mini humidifiers + 3 free fragrance oils.
- Free delivery is shown for all packages.

These are draft prices based on the supplier costs provided (NGN 6,000 per humidifier and NGN 6,000 per oil) plus estimated packaging, delivery and promotion allowances. Confirm actual costs before treating the estimated profit as final. See the costing note below.

Each Order now button adds that package to the saved bag and opens the order form. Customers can optionally state their Mango/Strawberry scent preference; if blank, the store should confirm their preference. The bag uses this browser's localStorage and is not shared across devices.

## Email order requests

There is no backend, payment integration, email API or order database. Submitting the form opens an email draft addressed to `abolarinwaibraheem@gmail.com`; the customer must press Send in their email app. The website cannot confirm that an email was sent or received.

## Product media

Supplied photos and videos are in `assets/products/`. The mango and strawberry product photos are `mango-oil-product.png` and `strawberry-oil-product.png`; their notes and packaging references are also included. The wide hero video uses `humidifier.mp4`, the replacement clip supplied by the customer. The two demonstration clips are `humid2.mp4` and `humid3.mp4`. Videos try audible autoplay when visible; browser autoplay rules may require them to start muted until the customer selects Enable sound.

Package photos show the included humidifier quantities and the matching mango/strawberry oils. The oils are fragrance products and are not intended for the humidifier water tank.

## Draft package costing

Planning assumptions per order: product cost NGN 12,000 / 24,000 / 36,000; packaging NGN 500 / 1,000 / 1,500; free-delivery allowance NGN 2,500 / 3,500 / 5,000; promotion allowance NGN 1,000 / 1,500 / 2,000 for Fresh / Double / Ultimate. That gives estimated variable costs of NGN 16,000 / 30,000 / 44,500. The draft prices above leave NGN 4,000 / 8,000 / 10,500 before monthly overhead and tax. Customers can choose Mango and Strawberry oil quantities to suit each offer. If actual delivery, packaging, advertising or operating costs exceed these allowances, raise the price or restrict free delivery to routes within the budget.
