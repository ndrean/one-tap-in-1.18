defmodule ExGoogleCerts do
  @moduledoc """
  This module provides functions to verify Google identity tokens using the Google public keys.
  """

  def verified_identity(%{jwt: jwt}) do
    with {:ok, profile} <- check_identity_v1(jwt),
         :ok <- run_checks(profile) do
      {:ok, profile}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  # @iss "https://accounts.google.com"
  defp iss, do: "https://accounts.google.com"
  defp app_id, do: System.get_env("GOOGLE_CLIENT_ID")

  #### PEM version ####

  # @pem_certs "https://www.googleapis.com/oauth2/v1/certs"
  defp pem_certs, do: "https://www.googleapis.com/oauth2/v1/certs"

  defp check_identity_v1(jwt) do
    with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, body} <- fetch(pem_certs()) do
      {true, %{fields: fields}, _} =
        body
        |> Map.get(kid)
        |> JOSE.JWK.from_pem()
        |> JOSE.JWT.verify_strict([alg], jwt)

      {:ok, fields}
    else
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  ##### JWK version #####

  # @jwk_certs "https://www.googleapis.com/oauth2/v3/certs"
  # defp jwk_certs, do: "https://www.googleapis.com/oauth2/v3/certs"

  # def check_identity_v3(jwt) do
  #   with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
  #        {:ok, body} <- fetch(@jwk_certs) do
  #     %{"keys" => certs} = @json_lib.decode!(body)
  #     cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
  #     signer = Joken.Signer.create(alg, cert)
  #     Joken.verify(jwt, signer, [])
  #   else
  #     {:error, reason} -> {:error, inspect(reason)}
  #   end
  # end

  # default HTTP client Req (already parses the body as JSON)
  defp fetch(url) do
    case Req.get(url) do
      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  defp run_checks(claims) do
    %{
      "exp" => exp,
      "aud" => aud,
      "azp" => azp,
      "iss" => iss
    } = claims

    with {:ok, true} <- not_expired(exp),
         {:ok, true} <- check_iss(iss),
         {:ok, true} <- check_user(aud, azp) do
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  defp not_expired(exp) do
    case exp > DateTime.to_unix(DateTime.utc_now()) do
      true -> {:ok, true}
      false -> {:error, :expired}
    end
  end

  defp check_user(aud, azp) do
    case aud == app_id() || azp == app_id() do
      true -> {:ok, true}
      false -> {:error, :wrong_id}
    end
  end

  defp check_iss(iss) do
    case iss == iss() do
      true -> {:ok, true}
      false -> {:ok, :wrong_issuer}
    end
  end
end
