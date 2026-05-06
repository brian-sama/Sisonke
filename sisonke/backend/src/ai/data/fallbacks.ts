export const systemFallbacks = {
  llm_timeout: "I'm still here, just taking a moment to process. Do you want to keep telling me what's on your mind?",
  repetition_detected: 'I may not be giving the best response right now, but I am listening carefully. Please go on.',
  toxic_output_caught_by_filter: "I want to support you safely. Could you tell me a little more about how you're feeling right now?",
  db_connection_error: "Hey, I'm having a quick glitch on my end, but I don't want to lose you. Please send that again.",
};

export const greetings = {
  calm: [
    "Hey. I'm here with you today. What's been on your mind?",
    "Hi there. I'm glad you reached out. How are things feeling right now?",
    "Hey. Take a deep breath. I'm here to listen whenever you're ready.",
    "Hello. You don't have to carry it all alone today. What's going on?",
  ],
  warm_local: [
    'Sawubona. How is your heart today?',
    "Mhoroi. I'm here. What's been feeling heavy lately?",
    'Hey friend. How are we doing today?',
  ],
  return_user: [
    "Hey again. I'm here. How have things been since we last spoke?",
    'Welcome back. Are we continuing from last time, or is there something new on your mind?',
    "Hi. I've got time for you today. How are you holding up?",
  ],
};

export function deterministicGreeting(turnsElapsed = 0) {
  const bank = turnsElapsed > 0 ? greetings.return_user : greetings.calm;
  return bank[Math.floor(Math.random() * bank.length)];
}
