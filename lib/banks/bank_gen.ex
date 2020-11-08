defmodule Bank.BankGen do
  @moduledoc """
     Module that generates a GenServer Bank by a macro with the predefined and required
     options

    opts as a keyword list
      bank_name: atom,
      daily_withdrawal_limit: float(),
      accounts: %{
        "4101-7712-3456-7890" => %{
          balance: float(),
          pin: String,
          account_no: integer,
          deposits: List,
          withdrawals: List
        }
      },
      bank_bin: String
  """

  defmacro __using__(opts) do
    quote do
      use GenServer
      unquote(opts)[:bank_name] || raise(":bank_name atom was not provided to init a bank")
      unquote(opts)[:accounts] || raise(":accounts map was not provided to init a bank")
      unquote(opts)[:bank_bin] || raise(":bank_bin value was not provided to init a bank")

      unquote(opts)[:daily_withdrawal_limit] ||
        raise(":daily_withdrawal_limit value was not provided to init a bank")

      def start_link do
        bank_name = unquote(opts)[:bank_name]
        acounts = unquote(opts)[:accounts]

        with {:ok, pid} <-
               GenServer.start_link(
                 __MODULE__,
                 %{accounts: acounts},
                 name: bank_name
               ) do
          IO.puts("Bank #{bank_name} connection established")
          {:ok, pid}
        else
          {:error, {:already_started, _pid}} ->
            IO.puts("Bank #{bank_name} is already connected")

          _ ->
            {:error, "Unexepcted error when connecting"}
        end
      end

      @impl true
      def init(initial_state) do
        {:ok, initial_state.accounts}
      end

      def create_account(initial_balance) do
        GenServer.cast(unquote(opts)[:bank_name], {:create_account, initial_balance})
      end

      defp commit_withdrawal(account, withdrawal_amount) do
        has_enough_balance = withdrawal_amount <= account.balance

        previous_total_withdraws =
          Enum.reduce(account.withdrawals, 0, fn withdrawal, acc -> acc + withdrawal end)

        cond do
          !has_enough_balance ->
            {:error, "Can't withdraw more than current balance"}

          previous_total_withdraws + withdrawal_amount > unquote(opts)[:daily_withdrawal_limit] ->
            {:error, "Can't exceed daily withdrawal total. Try with a smaller withdraw amount"}

          true ->
            new_balance = account.balance - withdrawal_amount
            new_withdrawals = [withdrawal_amount | account.withdrawals]

            {:ok, new_balance, new_withdrawals,
             "Please take $: #{withdrawal_amount} from the drawer \nBalance $: #{new_balance}"}
        end
      end

      @impl true
      def handle_cast({:validate_pin, account_atm, atm}, state) do
        with {:ok, account} <- Map.fetch(state, account_atm.card_digits) do
          if account.pin !== account_atm.pin do
            GenServer.cast(atm, {:invalid_pin, "Invalid PIN"})
            {:noreply, state}
          else
            GenServer.cast(atm, {:valid_pin, account_atm})
            {:noreply, state}
          end
        else
          :error ->
            GenServer.cast(atm, {:unexistent_account, "Account does not exist"})
            {:noreply, state}
        end
      end

      @impl true
      def handle_cast({:get_balance, account, atm}, state) do
        {:ok, account} = Map.fetch(state, account.card_digits)
        GenServer.cast(atm, {:bank_operation, "Your account balance is #{account.balance}"})
        {:noreply, state}
      end

      def handle_cast({:withdrawal, account_atm, amount, atm}, state) do
        {:ok, account} = Map.fetch(state, account_atm.card_digits)

        with {:ok, new_balance, withdrawals, message} <- commit_withdrawal(account, amount) do
          GenServer.cast(atm, {:bank_operation, message})

          {:ok, account_to_update} = Map.fetch(state, account_atm.card_digits)
          updated_account = Map.put(account_to_update, :balance, new_balance)
          updated_account = Map.put(updated_account, :withdrawals, withdrawals)

          {:noreply, Map.put(state, account_atm.card_digits, updated_account)}
        else
          {:error, message} ->
            GenServer.cast(
              atm,
              {:invalid_bank_operation, message}
            )

            {:noreply, state}
        end
      end

      @impl true
      def handle_cast({:get_transactions, account_atm, atm}, state) do
        {:ok, account} = Map.fetch(state, account_atm.card_digits)

        GenServer.cast(atm, {:bank_operation, "Deposits #{inspect(account.deposits)}"})
        GenServer.cast(atm, {:bank_operation, "Withdrawals #{inspect(account.withdrawals)}"})

        {:noreply, state}
      end

      @impl true
      def handle_cast({:deposit, account_atm, amount, atm}, state) do
        {:ok, account} = Map.fetch(state, account_atm.card_digits)
        new_deposits = [amount | account.deposits]
        new_balance = account.balance + amount

        GenServer.cast(atm, {:bank_operation, "Deposited $#{amount} succesfully"})
        updated_account = Map.put(account, :deposits, new_deposits)
        updated_account = Map.put(updated_account, :balance, new_balance)

        {:noreply, Map.put(state, account_atm.card_digits, updated_account)}
      end

      @impl true
      def handle_cast({:create_account, initial_balance}, state) do
        account_no = Enum.random(100_000_000_000_000_000..200_000_000_000_000_000)

        new_account =
          cond do
            initial_balance == 0 || initial_balance == 0.0 ->
              struct(__MODULE__,
                balance: initial_balance,
                account_no: account_no,
                pin: generate_random_pin("")
              )
              |> Map.from_struct()

            true ->
              struct(__MODULE__,
                balance: initial_balance,
                account_no: account_no,
                pin: generate_random_pin(""),
                deposits: [initial_balance]
              )
              |> Map.from_struct()
          end

        new_card_digits = get_unique_card_digits(state)

        IO.puts("VISA Debit account created: #{new_card_digits} \n #{inspect(new_account)}")

        {:noreply, Map.put(state, new_card_digits, new_account)}
      end

      defp generate_random_pin(<<head::binary-size(4), _rest::binary>>), do: head

      defp generate_random_pin(pin) do
        pin = pin <> to_string(Enum.random(0..9))
        generate_random_pin(pin)
      end

      defp get_unique_card_digits(state) do
        new_number =
          Enum.reduce(1..10, unquote(opts)[:bank_bin], fn _el, acc ->
            rand_digit = Enum.random(0..9) |> to_string()
            acc <> rand_digit
          end)

        new_number =
          new_number
          |> to_charlist()
          |> Enum.chunk_every(4)
          |> Enum.join("-")

        case Map.fetch(state, new_number) do
          {:ok, _account} -> get_unique_card_digits(state)
          :error -> new_number
        end
      end
    end
  end
end
