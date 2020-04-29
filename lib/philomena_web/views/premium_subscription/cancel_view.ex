defmodule PhilomenaWeb.PremiumSubscription.CancelView do
  use PhilomenaWeb, :view

  def cancel_reasons do
    [
      "---": "na",
      "I am no longer interested in astrophotography": "uninterested",
      "I am moving to a new image sharing platform": "moving",
      "I don't like the site": "dislike",
      "The subscription is too expensive": "expensive",
      "There aren't enough features for premium users": "features",
      "I am having technical issues with the site": "issues"
    ]
  end
end
