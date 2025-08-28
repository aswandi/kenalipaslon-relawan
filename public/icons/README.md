# PWA Icons

This directory should contain the following icon files for the PWA:

- `icon-192x192.png` - 192x192 pixel icon for Android
- `icon-512x512.png` - 512x512 pixel icon for splash screens

## Icon Requirements

The icons should:
1. Have a red theme to match the app branding
2. Include "KP" letters or KENALI PASLON branding
3. Be optimized for mobile displays
4. Have transparent or white backgrounds

## How to Add Icons

1. Create or design icons with the specifications above
2. Save them as PNG files with the exact names listed
3. Place them in this `/public/icons/` directory

The icons will be automatically referenced by:
- The PWA manifest (`/manifest.json`)
- The service worker (`/sw.js`)
- The main HTML template