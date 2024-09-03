defmodule Squeeze.FitRecord do
  defstruct [:kind, :fields]
end

defmodule Squeeze.RustFit do
  use Rustler, otp_app: :squeeze, crate: "rust_fit"

  # When your NIF is loaded, it will override this function.
  def parse_fit_file(_file_path), do: :erlang.nif_error(:nif_not_loaded)
end
