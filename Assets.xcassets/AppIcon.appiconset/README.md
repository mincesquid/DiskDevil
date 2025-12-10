# DiskDevil App Icon Assets

## Required Icon Sizes for macOS

You need to create the following icon images and place them in this directory:

### Icon Sizes Needed:
- `icon_16x16.png` - 16x16 pixels
- `icon_16x16@2x.png` - 32x32 pixels
- `icon_32x32.png` - 32x32 pixels
- `icon_32x32@2x.png` - 64x64 pixels
- `icon_128x128.png` - 128x128 pixels
- `icon_128x128@2x.png` - 256x256 pixels
- `icon_256x256.png` - 256x256 pixels
- `icon_256x256@2x.png` - 512x512 pixels
- `icon_512x512.png` - 512x512 pixels
- `icon_512x512@2x.png` - 1024x1024 pixels

## Design Guidelines

### Theme
DiskDevil is a security and system utility app with a dark, "devil" theme. The icon should convey:
- Security/Protection
- System utility
- Slightly edgy/powerful aesthetic (devil horns, shield, or similar)

### Recommended Design Elements
1. **Primary Symbol**: A shield with devil horns or a stylized devil character
2. **Color Scheme**:
   - Dark reds (#DC143C, #8B0000)
   - Blacks and dark grays (#1A1A1A, #2D2D2D)
   - Accent with metallic silver/blue for tech feel
3. **Style**: Flat design with subtle gradients, modern macOS aesthetic

### Tools to Create Icons

#### Option 1: Design Software
- **Figma** (Free): Create at 1024x1024, export at all sizes
- **Sketch** (Mac only): Native macOS icon template
- **Adobe Illustrator**: Professional vector design
- **Affinity Designer**: One-time purchase alternative

#### Option 2: Icon Generator Services
- **AppIconMaker** (https://appiconmaker.co/)
- **IconKitchen** (https://icon.kitchen/)
- Create one 1024x1024 PNG and let the service generate all sizes

#### Option 3: Command Line (if you have a 1024x1024 source)
```bash
# Install ImageMagick if needed
brew install imagemagick

# Generate all sizes from a 1024x1024 source image
convert icon_1024.png -resize 16x16 icon_16x16.png
convert icon_1024.png -resize 32x32 icon_16x16@2x.png
convert icon_1024.png -resize 32x32 icon_32x32.png
convert icon_1024.png -resize 64x64 icon_32x32@2x.png
convert icon_1024.png -resize 128x128 icon_128x128.png
convert icon_1024.png -resize 256x256 icon_128x128@2x.png
convert icon_1024.png -resize 256x256 icon_256x256.png
convert icon_1024.png -resize 512x512 icon_256x256@2x.png
convert icon_1024.png -resize 512x512 icon_512x512.png
convert icon_1024.png -resize 1024x1024 icon_512x512@2x.png
```

## Design Tips

1. **Keep it simple**: Icons look best when clean and recognizable at small sizes
2. **Test at 16x16**: If it doesn't look good at smallest size, redesign
3. **No text**: App icons should not contain text
4. **Consistent style**: Match macOS Big Sur+ rounded square aesthetic
5. **High contrast**: Ensure icon is visible on both light and dark backgrounds

## Placeholder Icons

Until you create final icons, you can use SF Symbols as placeholders:
- `shield.lefthalf.filled` - Current app icon
- Design around a shield with devil horns concept

## App Store Requirements

For App Store submission:
- All sizes must be present
- PNG format with transparency
- No alpha channel transparency in 1024x1024 version
- Icons should follow Apple Human Interface Guidelines
