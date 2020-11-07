defmodule Atm.Application do
  use Application

  @banks bancomer: Bancomer, santander: Santander, hsbc: Hsbc

  def start(_, _start_args) do
    import Supervisor.Spec

    children =
      Enum.map(@banks, fn {_bank, bank_module} ->
        supervisor(bank_module, [])
      end)

    opts = [strategy: :one_for_one, name: Bank.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
