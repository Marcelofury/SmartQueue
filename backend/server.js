require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const twilioService = require('./services/twilioService');

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// Middleware
app.use(cors());
app.use(express.json());

// ==================== UTILITY FUNCTIONS ====================

/**
 * Calculate wait time based on position and average service time
 * @param {number} position - Position in queue
 * @param {number} avgServiceTime - Average service time in minutes
 * @returns {number} Estimated wait time in minutes
 */
function calculateWaitTime(position, avgServiceTime) {
  return (position - 1) * avgServiceTime;
}

/**
 * Update positions for all waiting customers after a change
 * @param {string} businessId - Business ID
 */
async function updateQueuePositions(businessId) {
  const { data: waitingQueue, error } = await supabase
    .from('queues')
    .select('id')
    .eq('business_id', businessId)
    .eq('status', 'waiting')
    .order('created_at', { ascending: true });

  if (error) throw error;

  // Update positions sequentially
  for (let i = 0; i < waitingQueue.length; i++) {
    await supabase
      .from('queues')
      .update({ position: i + 1 })
      .eq('id', waitingQueue[i].id);
  }
}

// ==================== ROUTES ====================

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'SmartQueue API is running' });
});

/**
 * JOIN QUEUE
 * POST /api/queue/join
 * Body: { business_id, customer_name, phone_number }
 */
app.post('/api/queue/join', async (req, res) => {
  try {
    const { business_id, customer_name, phone_number } = req.body;

    // Validate required fields
    if (!business_id || !customer_name || !phone_number) {
      return res.status(400).json({ 
        error: 'Missing required fields: business_id, customer_name, phone_number' 
      });
    }

    // Get business details
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', business_id)
      .single();

    if (businessError || !business) {
      return res.status(404).json({ error: 'Business not found' });
    }

    // Get current queue count to determine position
    const { count, error: countError } = await supabase
      .from('queues')
      .select('id', { count: 'exact' }) // More robust counting
      .eq('business_id', business_id)
      .eq('status', 'waiting');

    if (countError) {
      console.error('Error counting queue:', countError);
      return res.status(500).json({ error: 'Failed to determine queue position.', details: countError.message });
    }

    const position = (count || 0) + 1;

    // Calculate wait time
    const waitTime = calculateWaitTime(position, business.avg_service_time);

    // Add customer to queue
    const { data: queueEntry, error: insertError } = await supabase
      .from('queues')
      .insert({
        business_id,
        customer_name,
        phone_number,
        position,
        status: 'waiting'
      })
      .select()
      .single();

    if (insertError) {
      return res.status(500).json({ error: 'Failed to join queue', details: insertError.message });
    }

    res.status(201).json({
      message: 'Successfully joined the queue',
      queue_entry: queueEntry,
      estimated_wait_time: waitTime,
      wait_time_unit: 'minutes'
    });

  } catch (error) {
    console.error('Error joining queue:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET STATUS
 * GET /api/queue/status/:queue_id
 */
app.get('/api/queue/status/:queue_id', async (req, res) => {
  try {
    const { queue_id } = req.params;

    // Get queue entry
    const { data: queueEntry, error } = await supabase
      .from('queues')
      .select(`
        *,
        businesses (
          name,
          avg_service_time
        )
      `)
      .eq('id', queue_id)
      .single();

    if (error || !queueEntry) {
      return res.status(404).json({ error: 'Queue entry not found' });
    }

    // Calculate current wait time
    let waitTime = 0;
    if (queueEntry.status === 'waiting') {
      waitTime = calculateWaitTime(
        queueEntry.position,
        queueEntry.businesses.avg_service_time
      );
    }

    res.json({
      queue_id: queueEntry.id,
      customer_name: queueEntry.customer_name,
      phone_number: queueEntry.phone_number,
      position: queueEntry.position,
      status: queueEntry.status,
      business_name: queueEntry.businesses.name,
      estimated_wait_time: waitTime,
      wait_time_unit: 'minutes',
      created_at: queueEntry.created_at
    });

  } catch (error) {
    console.error('Error getting status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * CALL NEXT
 * POST /api/queue/next/:business_id
 * Moves the first waiting customer to 'serving' status
 */
app.post('/api/queue/next/:business_id', async (req, res) => {
  try {
    const { business_id } = req.params;

    // Get the first person in queue
    const { data: nextCustomer, error: fetchError } = await supabase
      .from('queues')
      .select('*')
      .eq('business_id', business_id)
      .eq('status', 'waiting')
      .order('position', { ascending: true })
      .limit(1)
      .single();

    if (fetchError || !nextCustomer) {
      return res.status(404).json({ error: 'No customers in queue' });
    }

    // Update status to serving
    const { data: updatedCustomer, error: updateError } = await supabase
      .from('queues')
      .update({ status: 'serving' })
      .eq('id', nextCustomer.id)
      .select()
      .single();

    if (updateError) {
      return res.status(500).json({ error: 'Failed to update queue', details: updateError.message });
    }

    // Update positions for remaining customers
    await updateQueuePositions(business_id);

    // Send SMS notification to customer
    try {
      // Get business name for SMS
      const { data: business } = await supabase
        .from('businesses')
        .select('name')
        .eq('id', business_id)
        .single();

      if (twilioService.isEnabled()) {
        await twilioService.sendTurnNotification(
          nextCustomer.phone_number,
          nextCustomer.customer_name,
          business?.name || 'the service center'
        );
      }
    } catch (smsError) {
      console.error('SMS notification failed:', smsError.message);
      // Don't fail the request if SMS fails
    }

    res.json({
      message: 'Next customer called',
      customer: updatedCustomer,
      sms_sent: twilioService.isEnabled()
    });

  } catch (error) {
    console.error('Error calling next customer:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * COMPLETE SERVICE
 * POST /api/queue/complete/:queue_id
 * Marks a customer as done
 */
app.post('/api/queue/complete/:queue_id', async (req, res) => {
  try {
    const { queue_id } = req.params;

    const { data, error } = await supabase
      .from('queues')
      .update({ status: 'done' })
      .eq('id', queue_id)
      .select()
      .single();

    if (error || !data) {
      return res.status(404).json({ error: 'Queue entry not found' });
    }

    res.json({
      message: 'Service completed',
      customer: data
    });

  } catch (error) {
    console.error('Error completing service:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET CURRENT QUEUE
 * GET /api/queue/list/:business_id
 * Get all waiting customers for a business
 */
app.get('/api/queue/list/:business_id', async (req, res) => {
  try {
    const { business_id } = req.params;

    const { data: queue, error } = await supabase
      .from('queues')
      .select('*')
      .eq('business_id', business_id)
      .eq('status', 'waiting')
      .order('position', { ascending: true });

    if (error) {
      return res.status(500).json({ error: 'Failed to fetch queue' });
    }

    // Get business info for wait time calculation
    const { data: business } = await supabase
      .from('businesses')
      .select('avg_service_time')
      .eq('id', business_id)
      .single();

    const queueWithWaitTimes = queue.map(entry => ({
      ...entry,
      estimated_wait_time: calculateWaitTime(entry.position, business?.avg_service_time || 15)
    }));

    res.json({
      queue: queueWithWaitTimes,
      total_waiting: queue.length
    });

  } catch (error) {
    console.error('Error fetching queue:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`SmartQueue server running on port ${PORT}`);
});
