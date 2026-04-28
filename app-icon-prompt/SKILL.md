---
name: app-icon-prompt
description: Use when the user wants to design an app icon or generate a prompt for AI image generators. Analyzes the project's category, platform (iOS/macOS/web/CLI), audience, and brand to produce icon concepts plus a refined prompt with safe-zone and clipping guidance.
---

Guide agents through analyzing a project and generating optimal App icon prompts for AI image generators.

## Analyze Project

First, analyze the project to gather information about:

### App Type
Determine what category the app belongs to:
- **Game**: Entertainment, gaming apps
- **Tool**: Productivity, utilities, developer tools
- **Health**: Health, fitness, medical
- **Finance**: Banking, investment, crypto
- **Social**: Social networking, messaging
- **Education**: Learning, tutorials
- **Entertainment**: Media, video, music
- **Shopping**: E-commerce, marketplace
- **News**: News, magazines, reading
- **Travel**: Travel, maps, navigation
- **Food**: Food delivery, recipes, restaurants
- **Other**: Custom category

### Platform
- iOS / iPadOS / macOS / watchOS / tvOS
- Website / Web App
- CLI / Terminal tool
- Cross-platform

### UI Style
- **Minimalist**: Clean, simple, ample whitespace
- **Modern**: Contemporary, sleek, gradients
- **Playful**: Fun, colorful, animated
- **Professional**: Business-like, corporate, serious
- **Luxurious**: Premium, elegant, dark themes
- **Retro**: Vintage, nostalgic
- **Nature-inspired**: Organic, earthy tones

### Target Audience
- Age range (kids, teens, adults, seniors)
- Professional vs casual users
- Developers vs general consumers

### Main Functions
List the core features:
- What does the app do?
- What's the primary use case?
- What's the "aha" moment?

### Brand Identity
- Any existing brand colors?
- Any mascots or characters?
- Preferred imagery or symbols?

### Existing Assets
Check for:
- Existing icon references
- App screenshots
- Marketing materials
- Brand guidelines

## Research & Recommendations

Based on the analysis, recommend 3-5 icon options with different approaches:

For each option, provide:
1. **Style**: Describe the visual style (flat, 3D, abstract, illustrative, etc.)
2. **Concept**: What's depicted in the icon
3. **Colors**: Suggested color palette
4. **Why it works**: Brief reasoning for this choice

Example options:
- **Option 1 - Minimalist**: Simple geometric shape with app initial
- **Option 2 - Symbolic**: Abstract representation of core function
- **Option 3 - Illustrative**: Character or mascot representing the app
- **Option 4 - Gradient**: Modern gradient with subtle depth

Use `AskUserQuestion` to let the user select their preferred option or ask for modifications.

## Generate Icon Prompt

Once the user selects an option, generate a detailed prompt following these guidelines:

### Technical Requirements

**a. Square & Size**
- Icon must be a perfect square
- Minimum size: 1024x1024 pixels
- Recommend 2048x2048 or larger for flexibility
- For production: Generate at multiple sizes (16, 32, 64, 128, 256, 512, 1024)

**b. iOS/macOS Rounded Corners**
- iOS applies a rounded corner mask (Apple's "superellipse")
- Main content should have **20-30px padding** from edges (at 1024px size)
- Keep important elements within the safe area
- Avoid putting critical content in corners

**c. macOS Icon Clipping**
- macOS icons often have 3D effects, shadows, depth
- Draw the icon **smaller than the canvas** with margin
- Leave **40-60px margin** on each side (at 1024px size)
- This allows clipping in Photoshop or Sketch without losing key content

### Prompt Structure

Include in your prompt:

```
[Subject]: [describe the main visual element]
[Style]: [flat/3D/illustrated/abstract/minimalist]
[Colors]: [specific color palette]
[Composition]: [layout, elements arrangement]
[Technical]: square, [size]x[size], clean edges
[Safety]: [iOS/macOS] safe zone with [X]px padding
[Background]: [solid/gradient/transparent]
[Additional]: [any specific details]
```

### Example Prompts

**For a productivity tool:**
```
A sleek minimalist icon featuring a stylized checklist with checkmarks,
flat design, primary color #007AFF (iOS blue), white background,
simple geometric shapes, perfect square 1024x1024, main content
centered with 30px padding from edges for iOS rounded corner mask
```

**For a game:**
```
A playful 3D icon featuring a friendly robot character, vibrant
gradient background from #FF6B6B to #FFE66D, cartoon style,
soft shadows, perfect square 2048x2048, icon drawn at 1800x1800
with 124px margin for macOS clipping, transparent background
```

**For a finance app:**
```
A professional icon with abstract coin/stack design, gradient from
#1E3A5F to #2E5A8F (deep blue), subtle gold accents #FFD700,
modern flat style with slight depth, perfect square 1024x1024,
main content within 30px safe zone for iOS, solid background
```

### Refine Prompt

Show the generated prompt to the user and ask:
- Is the style correct?
- Any colors to adjust?
- Want to add/remove elements?
- Need different platform specifications?

## Output Summary

After the user confirms the prompt, provide:

### Generated Icon Prompt
The complete prompt ready for AI image generation

### Platform-Specific Notes
- iOS: Safe zone padding recommendation
- macOS: Clipping margins for key art
- Web: Favicon considerations
- CLI: Square icon with text

### Next Steps
1. Use prompt with AI image generator (Midjourney, DALL-E, Stable Diffusion, etc.)
2. Generate at high resolution (2048x2048 or larger)
3. Test with actual device corner masks
4. Export to required sizes

**NEVER**:
- Create prompts without understanding the app
- Ignore platform-specific requirements
- Skip user confirmation on style
- Generate prompts with text (hard to read at small sizes)

Remember: You're helping create the first impression of the app. Make sure the icon fits the app's purpose and stands out in the app store.
