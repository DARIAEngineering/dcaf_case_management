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
      "Thank you so much for everyone you help!",
      "Outstanding job! Keep up the hard work!",
      "¡Trabajo destacado! ¡Mantener el trabajo duro!",
      "Keep up the Good Work",
      "Mantener el Trabajo Duro",
      "You're a 🌟! You're awesome! Muchas Gracias!",
      "Another case, another human being helped. Keep it up!",
      "Merci beaucoup!",
      "Thank you for taking the time to be the most thoughtful CM that you can be! <3",
      "Você é demais!",
      "Your work is so valuable and you're doing a wonderful job! <3",
      "Your work empowers people to make decisions about their own bodies. Bravo!",
      "Thank you to be using your time to help the others. Your work is precious.",
      "Challenging but rewarding at the same time. Keep it up!!!",
      "Thank you for the good work! We appreciate all your efforts.",
      "Love, all the good people you have helped.",
      "Hang in there! You're an inspiration to us all.",
      "Keep on keepin' on!",
      "Thank you for all that you do!",
      "Not all superheroes wear capes, some are DCAF case managers! <3",
      "Thank you for being awesome!",
      "You are amazing! 👏👏👏",
      "You are doing wonderful things! Thank you so much for your support and help during these trying times.",
      "We appreciate all that you're doing. Keep up the good work!",
      "Thank you so much. If you're ok with hugs and if I could hug you in real life, I would hug you! Your work is so important.",
      "Proud to be a part of this incredible project - keep up the great work!",
      "You are a complete and total UNICORN! 🦄✨",
      "You guys rock! Proud to be working on this project.",
      "Thank you for contributing your time and energy in doing this important work.",
      "HOWDY! Thanks for the amazing work you do!",
      "We're so grateful for you and all you do!",
      "Thank you for all the great work that you do! Hang in there!",
      "You are appreciated, you are loved, your work makes a differnces! Thank you for all you do! 👏👏👏",
      "Thank you for the critical, wonderful work you do. You're awesome!",
      "Keep on crushing it! You are awesome.",
      "Thank you! You ARE APPRECIATED! :)",
      "Thank you for your incredible work!",
      "My body, my choice. Thanks for fighting for reproductive justice!",
      "Whoever saves a single life is considered by scripture to have saved the whole world. Thank you for your work!",
      "You're doing amazing, sweetie.",
      "Thanks for being the gem that you are!"
    ]
  end
end
