defmodule SqueezeWeb.PageView do
  use SqueezeWeb, :view

  @quotes [
    "“Only those who risk going too far, can possibly find out how far one can go.” — T.S. Elliot",
    "“Running is nothing more than a series of arguments between the part of your brain that wants to stop and the part that wants to keep going.” — Unknown",
    "“Now if you are going to win any battle you have to do one thing. You have to make the mind run the body. Never let the body tell the mind what to do. The body will always give up. It is always tired in the morning, noon and night. But the body is never tired if the mind is not tired.” — George S Patton",
    "“The voice inside your head that says you can’t do this is a liar.” — Unknown",
    "“The will to win means nothing without the will to prepare.” — Juma Ikangaa",
    "“Running is the greatest metaphor for life, because you get out of it what you put into it.” — Oprah Winfrey",
    "“We all have dreams. But in order to make dreams come into reality, it takes an awful lot of determination, dedication, self-discipline, and effort.” — Jesse Owens",
    "“I am not afraid of storms. I am learning how to sail my ship.” — Louisa May Alcott",
    "“You miss 100% of the shots you don’t take.” — Wayne Gretzky",
    "“Remember, everything you need is already inside of you.” — Unknown",
    "“Clear your mind of can’t.” — Samuel Johnson",
    "“You have a choice. You can throw in the towel, or you can use it to wipe the sweat off of your face.” — Gatoradead",
    "“You must do the thing you think you cannot do.” — Eleanor Roosevelt",
    "“Even when you have gone as far as you can, and everything hurts, and you are staring at the specter of self-doubt, you can find a bit more strength deep inside you, if you look closely enough.” — Hal Higdon",
    "“Some sessions are stars and some are stones, but in the end they are all rocks and we build upon them.” — Chrissie Wellington",
    "“Ever tried. Ever failed. No Matter. Try again. Fail again. Fail better.” — Samuel Beckett"
  ]

  def get_random_quote do
    Enum.random(@quotes)
  end
end
