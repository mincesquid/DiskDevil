# StoreKit 2 & Freemium Setup Guide

Complete guide to configuring your DiskDevil subscriptions in App Store Connect and testing.

---

## Table of Contents

1. [App Store Connect Setup](#app-store-connect-setup)
2. [Product IDs Configuration](#product-ids-configuration)
3. [Testing with StoreKit Configuration](#testing-with-storekit-configuration)
4. [Sandbox Testing](#sandbox-testing)
5. [Freemium Limits Summary](#freemium-limits-summary)

---

## App Store Connect Setup

### 1. Create Your App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** > **+** > **New App**
3. Fill in details:
   - **Name**: DiskDevil
   - **Primary Language**: English (US)
   - **Bundle ID**: (your bundle ID)
   - **SKU**: unique identifier (e.g., `diskdevil-2025`)

### 2. Create Subscription Group

1. Go to your app > **Subscriptions**
2. Click **Create Subscription Group**
3. Name: `DiskDevil Pro` (or your preferred name)
4. This groups all your subscription tiers together

### 3. Create Subscription Products

Create these 4 subscription products in your subscription group:

#### Premium Monthly
- **Product ID**: `com.diskdevil.premium.monthly`
- **Reference Name**: DiskDevil Premium Monthly
- **Duration**: 1 Month
- **Price**: $9.99 USD (Tier 10)
- **Features**:
  - Unlimited hidden file reveals
  - Unlimited network monitoring
  - Unlimited security scans
  - Privacy levels 1-9
  - Recovery tools & system repair
  - Priority email support

#### Premium Yearly
- **Product ID**: `com.diskdevil.premium.yearly`
- **Reference Name**: DiskDevil Premium Yearly
- **Duration**: 1 Year
- **Price**: $95.99 USD (20% off)
- **Features**: Same as Premium Monthly

#### Elite Monthly
- **Product ID**: `com.diskdevil.elite.monthly`
- **Reference Name**: DiskDevil Elite Monthly
- **Duration**: 1 Month
- **Price**: $19.99 USD (Tier 20)
- **Features**:
  - Everything in Premium
  - Privacy level 10 (MAXIMUM PARANOIA)
  - Advanced threat detection
  - Real-time network filtering
  - Telemetry blocking & privacy hardening
  - Priority live chat support

#### Elite Yearly
- **Product ID**: `com.diskdevil.elite.yearly`
- **Reference Name**: DiskDevil Elite Yearly
- **Duration**: 1 Year
- **Price**: $191.99 USD (20% off)
- **Features**: Same as Elite Monthly

### 4. Configure Subscription Pricing

For each product:
1. Click the product
2. Go to **Subscription Pricing**
3. Click **Add Pricing** or **Edit**
4. Select all territories or specific ones
5. Enter pricing (App Store Connect will suggest equivalent prices for each region)
6. Click **Save**

### 5. Add Subscription Information

For each product:
1. **Subscription Display Name**: The name users see (e.g., "Premium")
2. **Description**: Benefits description (copy from features above)
3. **Promotional Text**: (Optional) Limited time offers
4. **Screenshots**: (Optional but recommended)

### 6. Configure Auto-Renewable Settings

1. **Subscription Duration**: Already set when creating
2. **Introductory Offers** (Optional):
   - Free Trial: 7 days free
   - Pay As You Go: First month at $4.99
   - Pay Up Front: 3 months for $24.99
3. **Promotional Offers**: Create offers for lapsed subscribers

---

## Product IDs Configuration

The app is already configured with these Product IDs in `StoreKitManager.swift:18-21`:

```swift
private let premiumMonthlyID = "com.diskdevil.premium.monthly"
private let premiumYearlyID = "com.diskdevil.premium.yearly"
private let eliteMonthlyID = "com.diskdevil.elite.monthly"
private let eliteYearlyID = "com.diskdevil.elite.yearly"
```

**IMPORTANT**: If you want to use different Product IDs:
1. Update these constants in `Models/StoreKitManager.swift`
2. Match them exactly in App Store Connect
3. Rebuild the app

---

## Testing with StoreKit Configuration

### Option 1: StoreKit Configuration File (Recommended for Development)

1. In Xcode, go to **File** > **New** > **File**
2. Choose **StoreKit Configuration File**
3. Name it `DiskDevil.storekit`
4. Add your products:

```json
{
  "identifier" : "com.diskdevil.premium.monthly",
  "type" : "auto-renewable-subscription",
  "displayName" : "Premium Monthly",
  "description" : "Unlimited access to premium features",
  "price" : 9.99,
  "familyShareable" : false,
  "subscriptionDuration" : "P1M"
}
```

(Repeat for all 4 products)

5. In scheme settings:
   - Edit Scheme > Run > Options
   - **StoreKit Configuration**: Select `DiskDevil.storekit`

### Option 2: Testing Purchases in Development

1. Transactions use local StoreKit testing
2. No real money charged
3. Subscriptions auto-renew every few minutes for testing
4. You can clear transactions: **Debug** > **StoreKit** > **Delete All Transactions**

---

## Sandbox Testing

### 1. Create Sandbox Tester Accounts

1. Go to App Store Connect
2. **Users and Access** > **Sandbox Testers**
3. Click **+** to add tester
4. Fill in details (use a fake email like `test@example.com`)
5. **Don't use your real Apple ID**

### 2. Sign in with Sandbox Account

On your test Mac:
1. **Don't sign out of iCloud**
2. When making purchase in app, a prompt appears
3. Sign in with sandbox tester account
4. Complete purchase (no real charge)

### 3. Test Subscription Flow

1. Launch DiskDevil
2. Click **Upgrade** button
3. Select a plan
4. Click **Subscribe**
5. Sign in with sandbox account
6. Purchase processes
7. App should unlock features immediately

### 4. Test Restore Purchases

1. Delete app
2. Reinstall
3. Click **Restore Previous Purchase**
4. Subscription should restore

### 5. Test Subscription Management

1. Go to System Settings > Apple ID (sandbox account)
2. View subscriptions
3. Cancel subscription
4. App should detect cancellation

---

## Freemium Limits Summary

### Free Tier (No Subscription)

**Daily Limits** (Reset at midnight):
- ✅ **Unlimited**: Smart Cleanup (can clean unlimited files)
- ❌ **3 reveals/day**: Hidden Files Browser
- ❌ **3 sessions/day**: Network Monitor
- ❌ **2 scans/day**: Security Scanner
- ❌ **Privacy Level 1-3 only**
- ❌ **No Recovery Tools**

**Conversion Triggers**:
1. On 4th hidden file reveal → Show "Daily Limit Reached" modal
2. On 4th network monitoring session → Show limit modal
3. On 3rd security scan → Show limit modal
4. When clicking Privacy Level 4+ → Show upgrade modal
5. When clicking Recovery Tools → Show premium feature modal
6. Persistent banner showing remaining uses

### Premium Tier ($9.99/month or $95.99/year)

**Unlocked Features**:
- ✅ **Unlimited hidden file reveals**
- ✅ **Unlimited network monitoring**
- ✅ **Unlimited security scans**
- ✅ **Privacy Levels 1-9**
- ✅ **Recovery Tools access**
- ✅ **Priority email support**

### Elite Tier ($19.99/month or $191.99/year)

**All Premium Features +**:
- ✅ **Privacy Level 10** (MAXIMUM PARANOIA mode)
- ✅ **Advanced threat detection**
- ✅ **Real-time network filtering** (when NetworkExtension implemented)
- ✅ **Telemetry blocking & privacy hardening**
- ✅ **Priority live chat support**

---

## Implementation Details

### Usage Tracking System

Location: `Models/UsageLimits.swift`

**How it works**:
- Tracks usage in `UserDefaults`
- Automatically resets at midnight local time
- Persists across app launches
- Updates in real-time via `@Published` properties

**Usage Flow**:
```swift
// When user clicks "Reveal" on hidden file:
if subscriptionManager.tier == .free {
    if !usageLimits.canRevealHiddenFile() {
        // Show upgrade modal
        return
    }
    usageLimits.recordHiddenFileReveal() // Decrements counter
}
```

### Compelling Upgrade UI Components

1. **UsageLimitBanner** (HiddenFilesView.swift:178)
   - Shows "X of Y reveals remaining today"
   - Visual progress bar (green → orange → red)
   - Shows time until reset
   - Upgrade button when limit reached

2. **LimitReachedAlert** (HiddenFilesView.swift:249)
   - Modal dialog on limit exceeded
   - Lists benefits of upgrading
   - "Maybe Later" vs "Upgrade Now" buttons
   - Beautiful Aero theme styling

3. **LimitationsCard** (UpgradeView.swift:285)
   - Shows in upgrade view
   - Real-time display of current limits
   - Creates urgency with countdown
   - Highlights what user is missing

---

## Testing Checklist

### Before Release

- [ ] All 4 products created in App Store Connect
- [ ] Pricing set for all territories
- [ ] Product IDs match code exactly
- [ ] Screenshots uploaded for subscriptions
- [ ] Subscription terms and privacy policy linked
- [ ] Tested purchases with sandbox account
- [ ] Tested restore purchases
- [ ] Tested subscription cancellation detection
- [ ] Verified usage limits reset at midnight
- [ ] Verified premium users have unlimited access
- [ ] Tested upgrade flow from all limit modals
- [ ] Verified compelling messaging displays correctly

### Post-Release Monitoring

- [ ] Monitor subscription conversion rate (target: 5-15%)
- [ ] Track which features trigger most upgrades
- [ ] Monitor subscription churn rate
- [ ] A/B test different price points
- [ ] Gather user feedback on limits
- [ ] Adjust limits if conversion too low/high

---

## Pricing Strategy Recommendations

### Current Pricing
- **Premium**: $9.99/month, $95.99/year (20% off)
- **Elite**: $19.99/month, $191.99/year (20% off)

### Alternative Strategies

**Lower Entry Price** (Maximize conversions):
- Premium: $4.99/month, $47.99/year
- Elite: $9.99/month, $95.99/year

**Higher Value Tier** (Premium positioning):
- Premium: $14.99/month, $143.99/year
- Elite: $29.99/month, $287.99/year

**Aggressive Annual Discount** (Push yearly):
- Premium: $9.99/month, $79.99/year (33% off)
- Elite: $19.99/month, $159.99/year (33% off)

### Free Trial Recommendations

1. **7-Day Free Trial**: Best for new apps
   - Gives users time to see value
   - Higher conversion rate
   - Apple promotes apps with trials

2. **30-Day Free Trial**: If very confident in value
   - Users get hooked on unlimited features
   - Higher risk of gaming the system
   - Better for established apps

3. **Intro Pricing**: $0.99 for first month
   - Lower barrier than trial
   - Immediate revenue
   - Good middle ground

---

## Analytics to Track

### Conversion Metrics

Monitor in App Analytics:
1. **Free → Premium conversion rate**
   - Target: 5-10% within 30 days
2. **Premium → Elite upgrade rate**
   - Target: 10-20%
3. **Limit trigger → purchase rate**
   - Track which limits convert best
4. **Time to first purchase**
   - Optimize limit timing if too long

### Engagement Metrics

1. **Daily limit hit rate**
   - If >80% hit limits → increase limits
   - If <20% hit limits → decrease limits
2. **Feature usage distribution**
   - Which features drive value?
3. **Churn rate**
   - Monthly: Target <5%
   - Yearly: Target <20%

---

## Support Resources

- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [In-App Purchase Best Practices](https://developer.apple.com/app-store/in-app-purchase/)
- [Subscription Pricing Guide](https://developer.apple.com/app-store/subscriptions/)
- [App Store Review Guidelines (Subscriptions)](https://developer.apple.com/app-store/review/guidelines/#subscriptions)

---

## Troubleshooting

### Products not loading

```swift
// Add logging to see what's happening
await subscriptionManager.loadProducts()
print("Loaded products: \(subscriptionManager.getStoreKitManager().products)")
```

**Common causes**:
- Product IDs don't match App Store Connect exactly
- Products not approved yet in App Store Connect
- Network connection issue
- Not signed in with sandbox account

### Purchases not completing

**Check**:
- Sandbox account is valid
- Not using production Apple ID
- Product is available in current region
- StoreKit configuration is correct

### Subscription not restoring

**Verify**:
- Using same Apple ID as original purchase
- Calling `restoreSubscription()` correctly
- Checking transaction updates listener

---

## Next Steps

1. **Create products in App Store Connect** (Use guide above)
2. **Test with StoreKit Configuration file** (Local testing)
3. **Test with Sandbox account** (Real flow testing)
4. **Monitor first week of users** (Adjust limits based on data)
5. **Add analytics** (Track conversion funnels)
6. **Optimize pricing** (A/B test after 30 days)

Your freemium conversion system is ready to drive subscriptions! 🚀

