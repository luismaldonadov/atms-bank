defmodule Atm do
  @bank_bins %{
    "4101-77" => :bancomer,
    "4134-06" => :hsbc,
    "4331-26" => :santander
  }

  use GenServer

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def start_link(atm_name) do
    with {:ok, _} <-
           GenServer.start_link(__MODULE__, %{pin: nil, card_digits: nil, is_logged: false},
             name: atm_name
           ) do
      IO.puts("Atm started with name #{atm_name}")
    else
      {:error, {:already_started, _}} -> "Atm already running"
    end
  end

  @spec login(atom(), %{card_digits: String, pin: String}) :: :ok
  def login(process_name, input) do
    login_try = input |> Enum.into(%{is_logged: false})
    GenServer.cast(process_name, {:login, login_try})
  end

  @spec logout(atom()) :: :ok
  def logout(process_name) do
    GenServer.cast(process_name, :logout)
  end

  @spec get_balance(atom()) :: :ok
  def get_balance(process_name) do
    GenServer.cast(process_name, :get_balance)
  end

  def withdraw(process_name, amount) do
    GenServer.cast(process_name, {:withdrawal, amount})
  end

  def deposit(process_name, amount) do
    GenServer.cast(process_name, {:deposit, amount})
  end

  def get_transactions(process_name) do
    GenServer.cast(process_name, :get_transactions)
  end

  defp get_bank_from_bin(<<bin::binary-size(7), _rest::binary>>) do
    case Map.fetch(@bank_bins, bin) do
      {:ok, value} -> {:bank, value}
      :error -> {:error, "BIN does not exist"}
    end
  end

  @impl true
  def handle_cast(
        {:login, %{pin: _pin, card_digits: card_digits, is_logged: _is_logged} = input},
        state
      ) do
    with {:bank, bank_process} <- get_bank_from_bin(card_digits) do
      GenServer.cast(bank_process, {:validate_pin, input, self()})
      {:noreply, state}
    else
      {:error, message} ->
        GenServer.cast(self(), {:unexistent_bank, message})
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:login, _input}, %{pin: nil, card_digits: nil, is_logged: false} = state) do
    GenServer.cast(
      self(),
      {:not_authenticated, "Please provide a PIN and 16 card digits"}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(:logout, _state) do
    GenServer.cast(
      self(),
      {:logout, "Succesful logout"}
    )

    {:noreply, %{pin: nil, card_digits: nil, is_logged: false}}
  end

  @impl true
  def handle_cast(
        :get_balance,
        %{pin: _pin, card_digits: card_digits, is_logged: true} = state
      ) do
    {:bank, bank_process} = get_bank_from_bin(card_digits)
    GenServer.cast(bank_process, {:get_balance, state, self()})
    {:noreply, state}
  end

  @impl true
  def handle_cast(
        :get_balance,
        %{pin: _pin, card_digits: _card_digits, is_logged: false} = state
      ) do
    GenServer.cast(
      self(),
      {:not_authenticated, "Proceed to login to get balance"}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:withdrawal, _amount},
        %{pin: _pin, card_digits: _card_digits, is_logged: false} = state
      ) do
    GenServer.cast(
      self(),
      {:not_authenticated, "Proceed to login to withdraw"}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:withdrawal, amount},
        %{pin: _pin, card_digits: card_digits, is_logged: true} = state
      ) do
    {:bank, bank_process} = get_bank_from_bin(card_digits)
    GenServer.cast(bank_process, {:withdrawal, state, amount, self()})
    {:noreply, state}
  end

  @impl true
  def handle_cast(
        :get_transactions,
        %{pin: _pin, card_digits: card_digits, is_logged: true} = state
      ) do
    {:bank, bank_process} = get_bank_from_bin(card_digits)
    GenServer.cast(bank_process, {:get_transactions, state, self()})
    {:noreply, state}
  end

  @impl true
  def handle_cast(
        :get_transactions,
        %{pin: _pin, card_digits: _card_digits, is_logged: false} = state
      ) do
    GenServer.cast(
      self(),
      {:not_authenticated, "Proceed to login to get transactions"}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:deposit, _amount},
        %{pin: _pin, card_digits: _card_digits, is_logged: false} = state
      ) do
    GenServer.cast(
      self(),
      {:not_authenticated, "Proceed to login to deposit"}
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:deposit, amount},
        %{pin: _pin, card_digits: card_digits, is_logged: true} = state
      ) do
    {:bank, bank_process} = get_bank_from_bin(card_digits)
    GenServer.cast(bank_process, {:deposit, state, amount, self()})
    {:noreply, state}
  end

  # ###
  # # Internal posted back messages
  # ###

  @impl true
  def handle_cast({:not_authenticated, message}, state) do
    IO.puts("✕ ✕ ✕ #{message} ✕ ✕ ✕")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:unexistent_bank, message}, state) do
    IO.puts("✕ ✕ ✕ #{message} ✕ ✕ ✕")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:logout, message}, state) do
    IO.puts("✌ ✌ ✌ #{message} ✌ ✌ ✌")
    {:noreply, state}
  end

  # ###
  # # Messages back from banks
  # ###

  @impl true
  def handle_cast({:valid_pin, logged_state}, _state) do
    IO.puts("✓ ✓ ✓ Succesful login ✓ ✓ ✓")
    {:noreply, Map.put(logged_state, :is_logged, true)}
  end

  @impl true
  def handle_cast({:invalid_pin, message}, state) do
    IO.puts("✕ ✕ ✕ #{message} ✕ ✕ ✕")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:unexistent_account, message}, state) do
    IO.puts("✕ ✕ ✕ #{message} ✕ ✕ ✕")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:invalid_bank_operation, message}, state) do
    IO.puts("✕ ✕ ✕ #{message} ✕ ✕ ✕")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:bank_operation, message}, state) do
    IO.puts("◉ ◉ ◉ #{inspect(message)} ◉ ◉ ◉")
    {:noreply, state}
  end
end
