# Renders nice message on the login screen!
module WelcomeMessageHelper
  def random_welcome_message
    welcome_messages.sample
  end

  private

  def welcome_messages
    [
      "Thank you! - Team CM",
      "¡Gracias! - Equipo CM",
      "You are making choice a reality for the people you serve.",
      "Keep up the good work, you're doing great!",
      "¡Sigan con el buen trabajo, lo están haciendo muy bien!",
      "We're all rooting for you!",
      "Estamos todos apoyando para usted!",
      'We appreciate all that you do!',
      "From San Francisco with love!",
      "You're a real gem - the client_finder gem team",
      "You're rad and your work is much appreciated!",
      "Thanks for rocking our socks!",
      "You are amazing and we all appreciate you!",
      "Eres increíble y todos te apreciamos!",
      "Have no fear, Team CM is here!",
      "The work that you do is essential and helps so many people!",
      "Thank you for fighting the good fight!",
      "¡Gracias por pelear la buena pelea!",
      'You rock!',
      "You are invaluable - keep it up!!",
      "Outstanding job! Keep up the hard work!",
      "¡Trabajo destacado! ¡Mantener el trabajo duro!",
      "Keep up the Good Work",
      "Mantener el Trabajo Duro",
      "Another case, another human being helped. Keep it up!"
    ]
  end
end
