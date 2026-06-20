# covers: package.python_ontology.mix_project package.python_ontology.specled_dependency
defmodule PythonOntology.MixProject do
  use Mix.Project

  def project do
    [
      app: :python_ontology,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:spec_led_ex,
       github: "specleddev/specled_ex",
       ref: "301fad7cd490ea7328d47ec2f46c3d3f0c20a225",
       only: [:dev, :test],
       runtime: false}
    ]
  end
end
