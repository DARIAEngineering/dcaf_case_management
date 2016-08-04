module WelcomeMessageHelper
  def random_welcome_message
    welcome_messages.sample
  end

  private

  def welcome_messages
    [
      'Thank you! -DCAF Case Management Team',
      'You are making choice a reality for the people you serve.',
      "<img src='http://placekitten.com/300/300' />"
    ]
  end
end
