# Image Upload Guide - Liberia League App

## 📸 How to Add Photos to Your Application

This guide explains the **easiest ways** to add team logos, player photos, and league images to your application.

---

## 🚀 Quick Start - 3 Easy Options

### **Option 1: Use Imgur (Easiest - Recommended for Getting Started)**

**Why Imgur?**
- Free forever
- No account required
- Instant uploads
- Direct image links
- Works immediately

**Steps:**
1. Go to https://imgur.com
2. Click "New post" or drag and drop your image
3. After upload, **right-click** on the image
4. Select "Copy image address" or "Copy image link"
5. Paste that URL into your league/team form

**Example URL you'll get:**
```
https://i.imgur.com/abc123.png
```

**Video Tutorial:** https://imgur.com/upload

---

### **Option 2: Use Supabase Storage (Best for Production)**

**Why Supabase?**
- Integrated with your app
- Secure and fast
- Free tier: 1GB storage
- Part of your existing setup

**Setup Steps:**

#### Step 1: Create Storage Bucket in Supabase

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project
3. Click **"Storage"** in the left sidebar
4. Click **"New bucket"**
5. Name it: `league-images`
6. Make it **Public** ✓
7. Click "Create bucket"

#### Step 2: Upload Images

1. Click on the `league-images` bucket
2. Create folders for organization:
   - `team-logos/`
   - `player-photos/`
   - `league-logos/`
3. Click "Upload file"
4. Select your image
5. After upload, click the file name
6. Click **"Get URL"** or **"Copy URL"**
7. Use this URL in your app!

**Example URL you'll get:**
```
https://your-project-ref.supabase.co/storage/v1/object/public/league-images/team-logos/mighty-barrolle.png
```

#### Step 3: Use in Your App

When creating a league/team/player:
- Paste the copied URL into the "Logo URL" or "Photo URL" field
- Save the form
- The image will display automatically!

---

### **Option 3: Use Direct Web Links (Temporary)**

You can use any public image URL from the internet:

**Example sources:**
- Wikipedia: `https://upload.wikimedia.org/wikipedia/commons/...`
- Team websites: `https://example.com/logo.png`
- CDNs: `https://cdn.example.com/image.png`

**How to get the URL:**
1. Find the image online
2. Right-click the image
3. Select "Copy image address"
4. Paste into your form

⚠️ **Warning:** External links can break if the source website removes them.

---

## 📋 Where to Add Image URLs in the App

### **1. League Logos**

**Location:** `/admin/leagues`

**Field:** "Logo URL"

**When creating a league:**
```
League Name: Liberia Premier League 2025
Sport: Football
Logo URL: https://i.imgur.com/league-logo.png  ← Paste here
```

---

### **2. Team Logos**

**Location:** `/admin/leagues` → Manage Divisions → Manage Teams

**Field:** "Logo URL" or "Team Logo"

**When creating a team:**
```
Team Name: LISCR FC
Home Stadium: Samuel Kanyon Doe Stadium
Logo URL: https://i.imgur.com/liscr-logo.png  ← Paste here
```

---

### **3. Player Photos**

**Location:** Team management → Add Player

**Field:** "Photo URL"

**When creating a player:**
```
Player Name: John Doe
Position: Forward
Photo URL: https://i.imgur.com/player-photo.png  ← Paste here
```

---

## 🎨 Image Requirements

### **Recommended Image Sizes:**

- **Team Logos:** 200x200px to 500x500px (square)
- **Player Photos:** 300x400px to 600x800px (portrait)
- **League Logos:** 400x400px to 800x800px (square)

### **Supported Formats:**

✅ PNG (best for logos - transparent background)
✅ JPG/JPEG (best for photos)
✅ WebP (modern, smaller file size)
✅ SVG (vector graphics - scales perfectly)

### **File Size:**

- Keep under 1MB for fast loading
- Compress large images using:
  - https://tinypng.com
  - https://squoosh.app

---

## 🔧 Step-by-Step Example: Adding a Team Logo

### **Using Imgur (Easiest):**

1. **Prepare your logo:**
   - Have a team logo image ready (PNG or JPG)
   - Recommended: 300x300px, transparent background

2. **Upload to Imgur:**
   - Go to https://imgur.com
   - Drag and drop your logo
   - Wait for upload (few seconds)

3. **Get the URL:**
   - Right-click the uploaded image
   - Click "Copy image address"
   - You'll get: `https://i.imgur.com/abc123.png`

4. **Add to your app:**
   - Login to admin dashboard
   - Go to `/admin/leagues`
   - Click "Manage Divisions"
   - Click "Add Team"
   - Fill in team details
   - In "Logo URL" field, paste: `https://i.imgur.com/abc123.png`
   - Click "Create Team"

5. **Done!**
   - Your team logo will now display in:
     - Team listings
     - Match schedules
     - Standings tables

---

## 🌐 Using Supabase Storage (Detailed Setup)

### **First-Time Setup:**

#### 1. Create Storage Bucket

```sql
-- Run this in Supabase SQL Editor (Optional - or use UI)
-- The UI method is easier (see steps above)
```

**UI Method (Recommended):**
- Dashboard → Storage → New bucket → Name: `league-images` → Public ✓

#### 2. Set Up Policies (Optional - for security)

If you want only admins to upload:

```sql
-- Allow public read access
CREATE POLICY "Public can view images" ON storage.objects
  FOR SELECT USING (bucket_id = 'league-images');

-- Allow admins to upload
CREATE POLICY "Admins can upload images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'league-images' AND
    auth.uid() IN (
      SELECT id FROM profiles WHERE role = 'admin'
    )
  );
```

#### 3. Upload Images via Dashboard

- Storage → league-images → Upload file
- Create folders: team-logos, player-photos, league-logos
- Upload images to appropriate folders

#### 4. Get Image URLs

After upload:
- Click the image
- Click "Copy URL"
- Use in your app forms

---

## 💡 Pro Tips

### **Organizing Images:**

Create folders in Supabase Storage:
```
league-images/
  ├── team-logos/
  │   ├── liscr-fc.png
  │   ├── mighty-barrolle.png
  │   └── barrack-young.png
  ├── player-photos/
  │   ├── john-doe.jpg
  │   └── jane-smith.jpg
  └── league-logos/
      └── premier-league-2025.png
```

### **Naming Convention:**

Use lowercase with hyphens:
- ✅ `mighty-barrolle-logo.png`
- ✅ `john-doe-photo.jpg`
- ❌ `Mighty Barrolle Logo.PNG`
- ❌ `John Doe Photo.JPG`

### **Image Optimization:**

Before uploading:
1. Resize to recommended dimensions
2. Compress using TinyPNG
3. For logos: Use PNG with transparent background
4. For photos: Use JPG

---

## 🆘 Troubleshooting

### **Image doesn't show:**

1. **Check the URL is direct:**
   - ✅ Ends with `.png`, `.jpg`, `.webp`
   - ❌ Goes to a webpage instead

2. **Test the URL:**
   - Copy the URL
   - Paste in browser address bar
   - Should show ONLY the image

3. **Check image is public:**
   - Not behind login/password
   - Accessible to everyone

4. **Check Supabase bucket is public:**
   - Dashboard → Storage → league-images
   - Check "Public bucket" is enabled

### **URL format examples:**

**✅ Correct URLs:**
```
https://i.imgur.com/abc123.png
https://your-project.supabase.co/storage/v1/object/public/league-images/logo.png
https://example.com/direct-image.jpg
```

**❌ Wrong URLs:**
```
https://imgur.com/gallery/abc123  ← Gallery page, not direct image
https://drive.google.com/file/d/... ← Not public
C:\Users\Desktop\image.png  ← Local file path
```

---

## 📚 Quick Reference

### **Imgur:**
1. Upload → https://imgur.com
2. Right-click → Copy image address
3. Paste in form

### **Supabase:**
1. Dashboard → Storage → league-images
2. Upload file
3. Copy URL
4. Paste in form

### **Where to paste URLs:**
- **Leagues:** Logo URL field
- **Teams:** Logo URL field
- **Players:** Photo URL field

---

## 🎯 Recommended Workflow

**For a new league setup:**

1. **Collect all images:**
   - League logo
   - All team logos
   - Player photos (if available)

2. **Upload to Imgur or Supabase:**
   - Upload all at once
   - Copy all URLs
   - Save in a text file for reference

3. **Add to app:**
   - Create league (paste league logo URL)
   - Create divisions
   - Create teams (paste team logo URLs)
   - Create players (paste player photo URLs)

---

## 🔗 Helpful Links

- **Imgur Upload:** https://imgur.com
- **Supabase Dashboard:** https://app.supabase.com
- **TinyPNG (compress images):** https://tinypng.com
- **Squoosh (resize/compress):** https://squoosh.app
- **Remove Background:** https://remove.bg

---

## 📞 Need Help?

If you have issues:
1. Check the URL ends with `.png` or `.jpg`
2. Test URL in browser - should show image only
3. Make sure image is public (not private/password-protected)
4. Check file size is under 1MB

---

**Last Updated:** December 6, 2025
**App Version:** 100% Complete
