# NextShow × Cinema Integration

### Technical Starting Point + Questions for Naman & Team

Hey Naman, I want us to properly think through how we can make **cinema one of the strongest parts of** **NextShow**, because I think this could become one of our biggest differentiators. The goal isn't simply: “Put cinema listings on NextShow.” The bigger idea is: **NextShow becomes the place where someone can discover, compare and** **eventually book what they want to do in their city, with cinema sitting** **alongside comedy, music, theatre, sports and other local experiences.**

Cinema is particularly important because we don't currently see a strong consumer platform in Germany that brings the city's cinema options together with the rest of the things people can do, while also allowing users to compare their options. But I don't want us to start by trying to build the most complicated version. I want us to start **small, prove it works, and then build deeper.**

# 1. What I think our first version should be

I don't think we need to sell cinema tickets ourselves initially. Our first goal should be:

### DISCOVER → COMPARE → GO TO BOOK

For example, a user searches: **“What can I do tonight?”** NextShow could show:

### 🎬 Cinema

**Film:** Example Film **Cinema:** Kino X **Time:** 19:3A **Price:** €11 **Distance:** 2.4 km **Language:** Original Version / Original Version with Subtitles **Book** If the user clicks **Book**, they are sent directly to the cinema's booking page. So initially: **NextShow handles discovery.** **The cinema handles the actual transaction.** This means we don't initially need to deal with:

- Payments
- Seat selection
- Ticket generation
- Refunds
- Ticket cancellations
- Holding ticket inventory
- Payment disputes We can solve those later.
# 2. The first goal: get 3–5 Berlin cinemas

I think we should start with **small and independent Berlin cinemas**. Not necessarily because they are technically easier, but because the value proposition is strong for them. Our pitch would basically be: “We're building NextShow, a Berlin platform that brings cinema, comedy, music, theatre and other experiences together in one place. We're currently building our first group of pilot partners. We'd like to feature your cinema and programme on NextShow and send people directly to your booking flow.” This also fits one of our bigger missions:

### Give smaller local businesses visibility.

Instead of only showing the biggest names, NextShow can help people discover places they didn't even know existed.

# 3. What we need from the first cinema

Ideally, we need information like:

### Cinema

- Name
- Address
- Website
- Images / logo
- Description
### Film

- Film title
- Genre
- Description
- Poster / image
- Duration
- Language
- Subtitle information
### Screening

- Date
- Start time
- Cinema
- Screen, if available
- Price
- Ticket types
- Booking link We need to understand how each cinema currently provides this information. Some might have an **Application Programming Interface (API)**. Some might have a **data feed**. Some might have a ticketing provider. Some might have nothing and simply update their website.

### That's okay for the pilot.

# 4. The important thing: don't build a custom system for every cinema

This is something I really want us to think about from the beginning. Imagine eventually having: **100 cinemas** and every cinema uses a different system. We don't want: Cinema 1 → completely different code Cinema 2 → completely different code Cinema 3 → completely different code Cinema 4 → completely different code That becomes impossible to maintain. Instead, I think we need something like: **Cinema systems** ↓ **NextShow integration / adapter layer** ↓ **Standard NextShow cinema data** ↓ **NextShow database** ↓ **NextShow intelligent engine** ↓ **Consumer**

The idea is that every cinema gets converted into the same NextShow format. So regardless of where the data comes from, our system understands: **Film → Cinema → Screening → Time → Price → Language → Booking** Then adding a new cinema becomes much easier.

# 5. We also need to think about the “traction” part

I don't want NextShow to become another website where we have 500 listings nobody uses. The point is to build something people actually use to decide: **“What am I doing tonight?”** So eventually the system should allow us to understand things like:

- What people search for
- What categories they explore
- Which cinemas they click
- Which films they look at
- Which prices they prefer
- Which locations they prefer
- What times people normally go out
- Which experiences lead to bookings Then the intelligent engine can become better. For example: Someone says: “I want something fun tonight, I'm with two friends, we don't want to spend more than €25 and we're around Neukölln.” NextShow shouldn't just show a list. It should understand the request and potentially say: **“Here's what I'd recommend tonight.”** And maybe give:

🎬 Cinema 😂 Comedy 🎵 Live music 🍜 Something nearby That's when NextShow becomes the **decision layer for going out**, rather than simply a listing platform.

# 6. Cinema can become an anchor

This is another thing I want us to think about technically. Cinema gives us very useful information: **Time + location + duration + price** That means we can eventually build experiences around it. For example: Movie at 19:30 ↓ Dinner at 17:45 nearby ↓ Drinks at 22:00 Or: Comedy at 20:00 ↓ Late-night food nearby So the system isn't just recommending individual events. It's potentially building an entire **night out**. That's where the intelligent part of NextShow becomes much more meaningful.

# 7. Our technical roadmap

I would like us to think about this in stages.

### PHASE 1 — DISCOVERY

aet cinema information into NextShow. Show:

- Films
- Cinemas
- Showtimes
- Prices
- Languages
- Locations
- Booking links No ticket selling.
### PHASE 2 — COMPARISON

Allow users to compare: **Film → Cinema → Time → Price → Distance → Language** Example:

|Cinema|Time|Price|Distanc e|
|---|---|---|---|
|Cinema A|19:30|€11|1.2 km|
|Cinema B|20:00|€13|2.4 km|
|Cinema C|21:00|€9|3.1 km|

This is already a strong consumer feature.

### PHASE 3 — INTELLIGENT DISCOVERY

The system starts understanding what the user actually wants. Instead of:

“Here are 5A films.” It can say: **“Based on what you're looking for, I'd pick these three.”**

### PHASE 4 — BOOKING INTEGRATION

Deep-link users directly to the correct screening. Eventually potentially: **NextShow → booking → confirmation**

### PHASE 5 — NATIVE TICKETING

Only once we have enough traction and partnerships:

- Payments
- Seat selection
- Ticket generation
- Refunds
- Cancellations
- Ticket inventory
- Settlement with venues This is much more complicated, so we don't need to solve it immediately.
# 8. Questions I need you to investigate

I want us to go through these **A→Y** rather than just asking “can we integrate cinema?” We need to understand what is actually possible.

## A. Data Sources

**A.** Where can we get cinema data from initially?
**B.** Which Berlin cinemas have **Application Programming Interfaces (APIs)** or data feeds?
**C.** Which cinema ticketing providers are commonly used in Berlin and Germany?

**D.** Can cinemas provide us with their programme through **Comma-Separated Values** **(CSV)**, **JavaScript Object Notation (JSON)**, **Application Programming Interface (API)**, **Extensible Markup Language (XML)** or another structured format?
## B. Cinema Partners

**E.** What information would we need from our first 3–5 cinema partners?
**F.** Can a cinema manually provide its programme if it doesn't have an **Application** **Programming Interface (API)**?
**G.** Could we create a simple partner dashboard where a cinema can update its own programme?
**H.** What would make onboarding a new cinema take minutes or hours rather than days?
## C. Data Structure

**I.** What should our standard NextShow cinema data structure look like? For example: Cinema Film Screening Date Time Price Language Subtitles Location Booking URL Availability
**J.** How do we prevent duplicate films? For example: “The Substance” “THE SUBSTANCE” “The Substance (2024)” should all be recognised as the same film.

**K.** How do we handle Original Version, Original Version with Subtitles, aerman dubbed versions, subtitles, etc.?
## D. Showtimes and Updates

**L.** How frequently should cinema data update? Every 15 minutes? Hourly? Daily?
**M.** How do we know when a screening has been cancelled or changed?
**N.** What happens if a cinema changes its price?
**O.** How do we make sure NextShow doesn't show outdated information? This is extremely important because **trust is everything**.
## E. Price Comparison

**P.** Can we legally and technically display cinema prices?
**Q.** How do we handle different ticket types? Adult Student Senior Member etc.
**R.** Can we genuinely compare prices between cinemas in a fair way?
## F. Booking

**S.** Can we link directly to the exact screening rather than just the cinema homepage? For example: NextShow

↓ **Film X — 19:30 — Cinema Y** ↓ **Book this screening** ↓ Exact cinema booking page.

**T.** Can cinemas provide us with unique booking links for each screening?
**U.** Can we track whether a user came from NextShow?
**V.** Could this eventually become an affiliate or referral model?
## G. Future Ticketing

**W.** What would we technically need to eventually sell cinema tickets ourselves?
**X.** What would need to change in our backend if we eventually need:
- Seat availability
- Seat selection
- Payments
- Ticket generation
- Refunds
- Cancellations
**Y.** Most importantly: **If we eventually have 100 cinemas using 20 different ticketing systems,** **what architecture would allow us to integrate them without rebuilding** **NextShow every time?**
# 9. The question I really want answered

After looking at all of this, I want you to tell us:

### What is the smallest technically realistic version we can build right now

### that allows NextShow to aggregate 3–5 Berlin cinemas, show their films,

### showtimes and prices, compare them and send users directly to the correct booking page?

And then:

### What would we need to build next to go from 5 cinemas → 20 → 100?

I don't want us to overengineer this. I want: **Small → working → tested → traction → deeper integration.**

# 10. What success looks like

Our first technical milestone isn't: “NextShow can sell cinema tickets.” It's: **“Someone in Berlin opens NextShow, tells us what they want to do, sees** **cinema alongside other experiences, finds something they like, compares their options and actually goes somewhere because of us.”**

If we can prove that, **then we have something worth building deeper.** And eventually the vision is: **You don't need to ask Google, Instagram, Eventbrite, DICE, cinema websites and five other places what to do tonight.**

You ask **NextShow**. And NextShow already knows what is happening around you.

### Your city. Finally in one place.