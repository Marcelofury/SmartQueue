const AfricasTalking = require('africastalking');

class AfricasTalkingService {
  constructor() {
    this.client = null;
    this.sms = null;
    this.enabled = false;
    this.username = process.env.AT_USERNAME || 'sandbox';
    this.senderId = process.env.AT_SENDER_ID;

    // Initialize Africa's Talking client if credentials are provided
    if (process.env.AT_API_KEY) {
      try {
        this.client = AfricasTalking({
          apiKey: process.env.AT_API_KEY,
          username: this.username,
        });
        this.sms = this.client.SMS;
        this.enabled = true;
        console.log('✓ Africa\'s Talking SMS service initialized');
      } catch (error) {
        console.warn('⚠ Africa\'s Talking initialization failed:', error.message);
        this.enabled = false;
      }
    } else {
      console.warn('⚠ Africa\'s Talking credentials not configured - SMS notifications disabled');
    }
  }

  /**
   * Send SMS notification to a phone number
   * @param {string} to - Recipient phone number (must include country code, e.g., +256701234567)
   * @param {string} message - SMS message content
   * @returns {Promise<Object>} Africa's Talking message response
   */
  async sendSMS(to, message) {
    if (!this.enabled) {
      console.log(`[SMS DISABLED] Would send to ${to}: ${message}`);
      return { status: 'disabled', message: 'Africa\'s Talking not configured' };
    }

    try {
      // Format phone number - Africa's Talking expects + prefix
      const formattedTo = to.startsWith('+') ? to : `+${to}`;

      const options = {
        to: [formattedTo],
        message: message,
      };

      // Add sender ID if configured
      if (this.senderId) {
        options.from = this.senderId;
      }

      const response = await this.sms.send(options);

      // Africa's Talking returns an array of recipients
      const recipient = response.SMSMessageData.Recipients[0];
      
      if (recipient.status === 'Success') {
        console.log(`✓ SMS sent to ${formattedTo}: ${recipient.messageId}`);
        return {
          status: 'sent',
          messageId: recipient.messageId,
          to: formattedTo,
          cost: recipient.cost,
        };
      } else {
        console.error(`✗ Failed to send SMS to ${to}:`, recipient.status);
        throw new Error(`SMS delivery failed: ${recipient.status}`);
      }
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
    const message = `Hi ${customerName}! Your turn is coming up at ${businessName}. Please head to the counter. Thank you for using SmartQueue!`;
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
   * Check if Africa's Talking is enabled
   * @returns {boolean}
   */
  isEnabled() {
    return this.enabled;
  }

  /**
   * Get USSD client for handling USSD sessions
   * @returns {Object} USSD client
   */
  getUSSDClient() {
    if (!this.enabled) {
      return null;
    }
    return this.client.USSD;
  }
}

// Export singleton instance
module.exports = new AfricasTalkingService();
