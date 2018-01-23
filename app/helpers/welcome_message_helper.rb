# Renders nice message on the login screen!
module WelcomeMessageHelper
  def random_welcome_message
    welcome_messages.sample
  end

  private

  def welcome_messages
    [
      "Thank you! - Team CM",
      "You are making choice a reality for the people you serve.",
      "Keep up the good work, you're doing great!",
      "We're all rooting for you!",
      'We appreciate all that you do!',
      "From San Francisco with love!",
      "You're a real gem - the client_finder gem team",
      "You're rad and your work is much appreciated!",
      "From San Francisco with love!",
      "You're a real gem - the client_finder gem team",
      "You're rad and your work is much appreciated!",
      "Thanks for rocking our socks!",
      "You are amazing and we all appreciate you!",
      "Have no fear, Team CM is here!",
      "The work that you do is essential and helps so many people!",
      "Thank you for fighting the good fight!",
      'You rock!',
      "You are invaluable - keep it up!!",
      "You're a real gem - the client_finder gem team",
      "Outstanding job! Keep up the hard work!",
      "Keep up the Good Work",
      "Another case, another human being helped. Keep it up!"
    ]
  end
end
