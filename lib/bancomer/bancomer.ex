defmodule Bancomer do
  defstruct balance: 0, pin: nil, account_no: nil, deposits: [], withdrawals: []

  use Bank.BankGen,
    bank_name: :bancomer,
    daily_withdrawal_limit: 8000.00,
    accounts: %{
      "4101-7712-3456-7890" => %{
        balance: 8244.22,
        pin: "0021",
        account_no: 33_358_879,
        deposits: [],
        withdrawals: []
      }
    },
    bank_bin: "410177"
end
