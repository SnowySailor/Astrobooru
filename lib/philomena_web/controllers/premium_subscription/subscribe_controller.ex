defmodule PhilomenaWeb.PremiumSubscription.SubscribeController do
  use PhilomenaWeb, :controller
  import Phoenix.Controller
  alias Philomena.Paypal.API
  alias Philomena.Users.User
  alias Philomena.PremiumSubscription.Subscription
  alias Philomena.Repo
  require Logger

  def create(conn, %{"premium_subscription_id" => plan_id}) do
    conn
    |> create_new_subscription(plan_id)
    |> (&(redirect(conn, external: &1))).()
  end

  def index(conn, %{"premium_subscription_id" => id}) do
    url = Routes.premium_subscription_subscribe_path(conn, :create, id)
    csrf = get_csrf_token()
    
    html(conn, """
      <html>
        <body>
          <form id="autopost" method="POST" action=#{url}>
            <input type="hidden" name="_csrf_token" value="#{csrf}"/>
          </form>
          <script type="text/javascript">
            function ready(f) {
              if (document.readyState == "complete" || document.readyState == "interactive") {
                setTimeout(f, 1);
              } else {
                document.addEventListener("DOMContentLoaded", f);
              }
            }
            ready(function() {
              document.getElementById("autopost").submit();
            });
          </script>
        </body>
      </html>
      """)
  end

  defp create_new_subscription(conn, plan_id) do
    subscription = %{
      plan_id: plan_id,
      quantity: 1,
      subscriber: %{
        name: %{
          given_name: conn.assigns.current_user.name
        },
        email_address: conn.assigns.current_user.email
      },
      application_context: %{
        brand_name: "Astrobooru",
        shipping_preference: "NO_SHIPPING",
        payment_method: %{
          payer_selected: "PAYPAL",
          payee_preferred: "IMMEDIATE_PAYMENT_REQUIRED"
        },
        return_url: "https://astrobooru.com" <> Routes.activity_path(conn, :index),
        cancel_url: "https://astrobooru.com" <> Routes.premium_subscription_path(conn, :index)
      }
    }
    
    API.create_subscription(subscription)
    |> associate_user_with_subscription(plan_id, conn.assigns.current_user)
    |> get_approval_link()
  end

  defp get_approval_link(%{links: links}) do
    Enum.filter(links, fn link -> link.rel == "approve" end)
    |> Enum.fetch!(0)
    |> (fn %{href: link} -> link end).()
  end

  defp associate_user_with_subscription({:ok, %{id: id} = subscription}, plan_id, %User{id: user_id}) do
    _ = %Subscription{
      id: id,
      billing_plan_id: plan_id,
      user_id: user_id
    }
    |> Subscription.changeset(%{})
    |> Repo.insert(on_conflict: :nothing)
    subscription
  end

  defp associate_user_with_subscription(error, plan_id, user),
    do: Logger.error("error associating user (#{user.id}) with subscription (plan: #{plan_id}): #{inspect(error)}")
end