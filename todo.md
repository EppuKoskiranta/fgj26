tasks to do
===


1. Models
  - Customer Face
  - Player Hand
  - Cauldron (lotion pot)
  - Lotion/mask Ingredients
    - clay (different types of clay???)
    - charcoal (detox)
    - glycolic acid (exfoliate)
    - aloe vera (calming, hydrate)
    - cucumber (hydration)
    - ...
  - Customer Body
  - Cucumber slices for the eyes???
  - Room/Salon
  - Insense / candles
  - Radio
  - Decor

2. Systems
  - INGREDRIENT:
    - Customer interrogation for lotion type
    - Ingredient mixing logic and parameter scoring.

    - Logic for spreading the lotion on the face
      - Applying the lotion to the face and the face model 
      - Area hit % calculation

  - GAME STATE MANAGEMENT:
    - Game loop management
      - Handles the state of the game
      - Customer respawn logic
    - Scoring system
      - Takes input from lotion mix, apply step% and environment
    - Menus / settings / pause
  
  - PLAYER CONTROLS:
    - Camera handling (Peter)
      - Multiple camera dock points
    - Player input and movement handling
      - Input mapping for different steps of gameplay:
        - Main / brewing / lotion applying

  - ENVIRONMENT:
    - Customer interrogation for environment setup
    - Insense holder / candles logic
        - Need to be able to change the scent 
    - Radio
        - Need to be able to change the bg music

