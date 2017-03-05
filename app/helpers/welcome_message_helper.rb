# Renders nice message on the login screen!
module WelcomeMessageHelper
  def random_welcome_message
    welcome_messages.sample
  end

  private

  def welcome_messages
    [
      'Thank you! - Team CM',
      'You are making choice a reality for the people you serve.',
      "Keep up the good work, you're doing great!",
      "We're all rooting for you!",
      'We appreciate all that you do!',
      "From San Francisco with love!",
      "You're a real gem - the client_finder gem team",
      "You're rad and your work is much appreciated!"
    ]
  end
end
