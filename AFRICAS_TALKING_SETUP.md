# Africa's Talking Setup Guide

SmartQueue now uses **Africa's Talking** for SMS and USSD services, optimized for Uganda and East Africa.

## 🌍 Why Africa's Talking?

- **Cost-effective**: ~$0.016 per SMS in Uganda (50% cheaper than Twilio)
- **USSD support**: Enable customers without internet to access queues
- **Local infrastructure**: Better delivery rates in Africa
- **Mobile money integration**: Ready for future payment features

## 📋 Setup Instructions

### 1. Create an Africa's Talking Account

1. Go to [africastalking.com](https://africastalking.com)
2. Sign up for a free account
3. Verify your email and phone number

### 2. Get Your API Credentials

**For Testing (Sandbox):**
1. Log in to your dashboard
2. Navigate to **Sandbox** section
3. Copy your **API Key**
4. Username will be: `sandbox`

**For Production:**
1. Upgrade your account with credits
2. Go to **Settings** → **API Key**
3. Create and copy your production API key
4. Use your actual username (provided during registration)

### 3. Configure Environment Variables

Update your `.env` file with:

```bash
# Africa's Talking Configuration
AT_USERNAME=sandbox              # Use 'sandbox' for testing, your username for production
AT_API_KEY=your_api_key_here     # Your API key from the dashboard
AT_SENDER_ID=SMARTQUEUE          # Your sender ID (optional, for branded SMS)
```

### 4. Register a Sender ID (Production Only)

For production SMS with a custom sender name:

1. Go to **SMS** → **Sender IDs** in your dashboard
2. Request a sender ID (e.g., "SMARTQUEUE")
3. Wait for approval (usually 1-2 business days)
4. Add it to your `.env` as `AT_SENDER_ID`

### 5. Set Up USSD (Production Only)

1. Go to **USSD** → **Create Channel**
2. Request a USSD code (e.g., `*384*12345#`)
3. Set your callback URL: `https://your-domain.com/api/ussd`
4. Wait for approval from telecom operators (MTN, Airtel Uganda)

### 6. Test Your Integration

**Test SMS in Sandbox:**
```bash
# Use these test numbers in sandbox mode:
# +254711082XXX (Kenya)
# +256703483XXX (Uganda)
```

**Test USSD:**
```bash
# Dial your assigned USSD code on a registered test number
*384*12345#
```

## 💰 Pricing (Uganda)

| Service | Sandbox | Production |
|---------|---------|------------|
| SMS | FREE (limited) | $0.016 per SMS |
| USSD Session | FREE (limited) | $0.01 per session |
| Minimum Top-up | - | $10 |

## 🔧 API Features Used

### SMS
- Queue join confirmations
- "Your turn" notifications
- Position updates

### USSD
- Join queue without internet
- Check position in real-time
- Find nearby businesses

## 📱 USSD Menu Structure

```
*384*12345#
├── 1. Join Queue
│   ├── Select business
│   └── Enter name
├── 2. Check My Position
│   └── Shows current queue status
└── 3. Find Business
    └── Lists available businesses
```

## 🚀 Installing Dependencies

```bash
cd backend
npm install
```

This will install the `africastalking` package.

## 🔄 Migrating from Twilio

The system has been updated to use Africa's Talking. Old Twilio configuration is no longer needed:

- ❌ Remove: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`
- ✅ Add: `AT_USERNAME`, `AT_API_KEY`, `AT_SENDER_ID`

## 📞 Support

- **Documentation**: [docs.africastalking.com](https://docs.africastalking.com)
- **Support Email**: support@africastalking.com
- **Community**: [developers.africastalking.com](https://developers.africastalking.com)

## 🔐 Security Notes

- Never commit your `.env` file to version control
- Use sandbox for development and testing
- Rotate API keys periodically
- Monitor usage in the dashboard to prevent unexpected charges

## ✅ Verification Checklist

- [ ] Account created on Africa's Talking
- [ ] API key obtained and added to `.env`
- [ ] Dependencies installed (`npm install`)
- [ ] SMS tested in sandbox mode
- [ ] USSD code requested (production only)
- [ ] Callback URL configured
- [ ] Production credits topped up (when going live)

---

**Need help?** Check the [Africa's Talking documentation](https://docs.africastalking.com) or contact their support team.
