defmodule NewspaperScraper.Boundary.Validator do
  def mandatory(errors, fields, field_name, validator) do
    present = Map.has_key?(fields, field_name)
    check_mandatory_field(present, fields, errors, field_name, validator)
  end

  def optional(errors, fields, field_name, validator) do
    case Map.has_key?(fields, field_name) do
      true -> mandatory(errors, fields, field_name, validator)
      false -> errors
    end
  end

  def check(true, _message), do: :ok
  def check(false, message), do: message

  defp check_mandatory_field(true, fields, errors, field_name, check_fun) do
    valid =
      fields
      |> Map.fetch!(field_name)
      |> check_fun.()

    check_field(valid, errors, field_name)
  end

  defp check_mandatory_field(_present, _fields, errors, field_name, _check_fun) do
    errors ++ [{field_name, "#{field_name} is mandatory"}]
  end

  defp check_field(:ok, _errors, _field_name), do: :ok

  defp check_field({:error, message}, errors, field_name) do
    errors ++ [{field_name, message}]
  end

  defp check_field({:errors, messages}, errors, field_name) do
    errors ++ Enum.map(messages, &{field_name, &1})
  end
end
