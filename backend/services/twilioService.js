const twilio = require('twilio');

class TwilioService {
  constructor() {
    this.client = null;
    this.enabled = false;
    this.fromNumber = process.env.TWILIO_PHONE_NUMBER;

    // Initialize Twilio client if credentials are provided
    if (
      process.env.TWILIO_ACCOUNT_SID &&
      process.env.TWILIO_AUTH_TOKEN &&
      process.env.TWILIO_PHONE_NUMBER
    ) {
      try {
        this.client = twilio(
          process.env.TWILIO_ACCOUNT_SID,
          process.env.TWILIO_AUTH_TOKEN
        );
        this.enabled = true;
        console.log('✓ Twilio SMS service initialized');
      } catch (error) {
        console.warn('⚠ Twilio initialization failed:', error.message);
        this.enabled = false;
      }
    } else {
      console.warn('⚠ Twilio credentials not configured - SMS notifications disabled');
    }
  }

  /**
   * Send SMS notification to a phone number
   * @param {string} to - Recipient phone number (must include country code, e.g., +1234567890)
   * @param {string} message - SMS message content
   * @returns {Promise<Object>} Twilio message response
   */
  async sendSMS(to, message) {
    if (!this.enabled) {
      console.log(`[SMS DISABLED] Would send to ${to}: ${message}`);
      return { status: 'disabled', message: 'Twilio not configured' };
    }

    try {
      // Format phone number if needed (ensure it starts with +)
      const formattedTo = to.startsWith('+') ? to : `+${to}`;

      const response = await this.client.messages.create({
        body: message,
        from: this.fromNumber,
        to: formattedTo,
      });

      console.log(`✓ SMS sent to ${formattedTo}: ${response.sid}`);
      return {
        status: 'sent',
        sid: response.sid,
        to: formattedTo,
      };
    } catch (error) {
      console.error(`✗ Failed to send SMS to ${to}:`, error.message);
      throw new Error(`SMS delivery failed: ${error.message}`);
    }
  }

  /**
   * Send 'Your turn is coming up' notification
   * @param {string} phoneNumber - Customer phone number
   * @param {string} customerName - Customer name
   * @param {string} businessName - Business name
   * @returns {Promise<Object>}
   */
  async sendTurnNotification(phoneNumber, customerName, businessName) {
    const message = `Hi ${customerName}! 🎉 Your turn is coming up at ${businessName}. Please head to the counter. Thank you for using SmartQueue!`;
    return this.sendSMS(phoneNumber, message);
  }

  /**
   * Send queue joined confirmation
   * @param {string} phoneNumber - Customer phone number
   * @param {string} customerName - Customer name
   * @param {number} position - Queue position
   * @param {number} estimatedWait - Estimated wait time in minutes
   * @returns {Promise<Object>}
   */
  async sendQueueConfirmation(phoneNumber, customerName, position, estimatedWait) {
    const message = `Hi ${customerName}! You're #${position} in line. Estimated wait: ${estimatedWait} min. We'll notify you when it's your turn. SmartQueue`;
    return this.sendSMS(phoneNumber, message);
  }

  /**
   * Check if Twilio is enabled
   * @returns {boolean}
   */
  isEnabled() {
    return this.enabled;
  }
}

// Export singleton instance
module.exports = new TwilioService();
