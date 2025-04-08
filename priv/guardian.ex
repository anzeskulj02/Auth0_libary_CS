defmodule <%= app_module %>Web.Guardian do
  use Guardian, otp_app: :aurora

  alias <%= app_module %>.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user(id)
    {:ok, user}
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  # Custom function to create a session token with tenant info
  def create_session_token(user) do
    claims = %{
      tenant_id: user.tenant_id,
      auth0_id: user.auth0_id
    }

    encode_and_sign(user, claims, ttl: {1, :day})
  end

  def check_sign(token) do
    decode_and_verify(token)
  end
end
