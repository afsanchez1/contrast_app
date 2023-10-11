defmodule NewspaperScraper.Boundary.Validator do
  def mandatory(errors, fields, field_name, validator) do
    is_present = Map.has_key?(fields, field_name)
    check_mandatory_field(is_present, fields, errors, field_name, validator)
  end

  defp check_mandatory_field(true, fields, errors, field_name, check_fun) do
    try do
      fields
      |> Map.fetch!(field_name)
      |> check_fun.()
      |> check_field(errors, field_name)
    rescue
      e -> {:error, e}
    end
  end

  defp check_mandatory_field(false, _fields, errors, field_name, _check_fun) do
    errors ++ [{field_name, "is mandatory"}]
  end

  defp check_field(:ok, errors, _field_name), do: errors

  defp check_field({:error, message}, errors, field_name) do
   errors ++ [{field_name, message}]
  end

  def optional(errors, fields, field_name, validator) do
    case Map.has_key?(fields, field_name) do
      true -> mandatory(errors, fields, field_name, validator)
      false -> errors
    end
  end

  def check(true, _message), do: :ok
  def check(false, message), do: message

  def has_errors([]), do: :ok
  def has_errors(errors), do: {:error, errors}
end
