defmodule Bank.Hsbc do
  defstruct balance: 0, pin: nil, account_no: nil, deposits: [], withdrawals: []

  use Bank.BankGen,
    bank_name: :hsbc,
    daily_withdrawal_limit: 8000.00,
    accounts: %{
      "4134-0612-3456-7890" => %{
        balance: 8244.22,
        pin: "0021",
        account_no: 33_358_879,
        deposits: [],
        withdrawals: []
      }
    },
    bank_bin: "4134-06"
end
