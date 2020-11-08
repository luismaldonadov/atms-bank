searchNodes=[{"doc":"Atm module that creates and interacts with an Atm GenServer process. Atm communicates with a process generated by Bank.BankGen module matching against the bank_bin determined by the given card digits on login.1.- In the app root folder through your cli, execute the interactive elixir cli. &gt; iex -S mix Erlang/OTP 23 [erts-11.0] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe] Bank bancomer connection established Bank santander connection established Bank hsbc connection established As documented here, by starting the project, the 3 Bank process are started and supervised automatically 2.- You can start by creating an Atm process by: iex&gt; Atm.start_link(:atm1) {:ok, #PID&lt;0.198.0&gt;} 3.- After that you cant pass the atom Atm process name to execute any function documented herein.","ref":"Atm.html","title":"Atm","type":"module"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"Atm.html#child_spec/1","title":"Atm.child_spec/1","type":"function"},{"doc":"Deposits money for the provided logged-in account for the Atm GenServer processExamplesiex&gt; Atm.deposit(:atm1, 1250.54) :ok ◉ ◉ ◉ &quot;Deposited $1250.54 succesfully&quot; ◉ ◉ ◉","ref":"Atm.html#deposit/2","title":"Atm.deposit/2","type":"function"},{"doc":"Get the balance for the provided logged-in account for the Atm GenServer processExamplesiex&gt; Atm.get_balance(:atm1) :ok ◉ ◉ ◉ &quot;Your account balance is 8244.22&quot; ◉ ◉ ◉","ref":"Atm.html#get_balance/1","title":"Atm.get_balance/1","type":"function"},{"doc":"Get the deposits and withdrawalsfor the provided logged-in account for the Atm GenServer processExamplesiex&gt; Atm.deposit(:atm1, 1250.54) :ok ◉ ◉ ◉ &quot;Deposits [1250.54]&quot; ◉ ◉ ◉ ◉ ◉ ◉ &quot;Withdrawals []&quot; ◉ ◉ ◉","ref":"Atm.html#get_transactions/1","title":"Atm.get_transactions/1","type":"function"},{"doc":"Login with the specified card digits matching the bank bin with the provided GenServer named process and pinExamplesiex&gt; Atm.login(:atm1, %{card_digits: &quot;4101-7712-3456-7890&quot;, pin: &quot;0021&quot;}) :ok ✓ ✓ ✓ Succesful login ✓ ✓ ✓ iex&gt; Atm.login(:atm1, %{card_digits: &quot;4101-7712-3456-7812&quot;, pin: &quot;0021&quot;}) ✕ ✕ ✕ Account does not exist ✕ ✕ ✕ :ok iex&gt; Atm.login(:atm1, %{card_digits: &quot;4101-7712-3456-7890&quot;, pin: &quot;1235&quot;}) ✕ ✕ ✕ Invalid PIN ✕ ✕ ✕ :ok","ref":"Atm.html#login/2","title":"Atm.login/2","type":"function"},{"doc":"Logout from the existing session for the provided Atm GenServer process.Examplesiex&gt; Atm.logout(:atm1) ✌ ✌ ✌ Succesful logout ✌ ✌ ✌ :ok","ref":"Atm.html#logout/1","title":"Atm.logout/1","type":"function"},{"doc":"Starts an Atm GenServer supervised process with a given atom process nameExamplesiex&gt; Atm.start_link(:atm1) {:ok, #PID&lt;0.198.0&gt;} iex&gt; Atm.start_link(:atm1) {:already_started, #PID&lt;0.198.0&gt;}","ref":"Atm.html#start_link/1","title":"Atm.start_link/1","type":"function"},{"doc":"Withdraws money for the provided logged-in account for the Atm GenServer processExamplesiex&gt; Atm.withdraw(:atm1, 8000) :ok ◉ ◉ ◉ &quot;Please take $: 8000 from the drawer Balance $: 244.21999999999935&quot; ◉ ◉ ◉iex&gt; Atm.withdraw(:atm1, 8000) ✕ ✕ ✕ Can&#39;t exceed daily withdrawal total. Try with a smaller withdraw amount ✕ ✕ ✕ :ok iex&gt; Atm.withdraw(:atm1, 80001) ✕ ✕ ✕ Can&#39;t withdraw more than current balance ✕ ✕ ✕ :ok iex&gt; Atm.withdraw(:atm1, 80001) ✕ ✕ ✕ Proceed to login to withdraw ✕ ✕ ✕ :ok","ref":"Atm.html#withdraw/2","title":"Atm.withdraw/2","type":"function"},{"doc":"Entry application point that starts the GenSever process for Bancomer, Santander and Hsbc banks.","ref":"Atm.Application.html","title":"Atm.Application","type":"module"},{"doc":"Callback implementation for Application.start/2.","ref":"Atm.Application.html#start/2","title":"Atm.Application.start/2","type":"function"},{"doc":"Bancomer Bank generated by the macro on module Bank.BankGenbank_bin: &quot;4101-77&quot;","ref":"Bancomer.html","title":"Bancomer","type":"module"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"Bancomer.html#child_spec/1","title":"Bancomer.child_spec/1","type":"function"},{"doc":"Creates an account on the bank_name GenServer process with an optional intial balanceExamplesiex(1)&gt; __MODULE__.create_account(5000.12) :ok iex(2)&gt; VISA Debit account created: 4101-7731-7410-8792 %{account_no: 137343541081659130, balance: 5000.12, deposits: [5000.12], pin: &quot;1355&quot;, withdrawals: []}","ref":"Bancomer.html#create_account/1","title":"Bancomer.create_account/1","type":"function"},{"doc":"","ref":"Bancomer.html#start_link/0","title":"Bancomer.start_link/0","type":"function"},{"doc":"Module that generates a GenServer Bank by a macro with the predefined and required options opts as a keyword listbank_name: atom, daily_withdrawal_limit: float(), accounts: %{ &quot;4101-7712-3456-7890&quot; =&gt; %{ balance: float(), pin: String, account_no: integer, deposits: List, withdrawals: List } }, bank_bin: String","ref":"Bank.BankGen.html","title":"Bank.BankGen","type":"module"},{"doc":"Hsbc Bank generated by the macro on module Bank.BankGenbank_bin: &quot;4134-06&quot;","ref":"Hsbc.html","title":"Hsbc","type":"module"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"Hsbc.html#child_spec/1","title":"Hsbc.child_spec/1","type":"function"},{"doc":"Creates an account on the bank_name GenServer process with an optional intial balanceExamplesiex(1)&gt; __MODULE__.create_account(5000.12) :ok iex(2)&gt; VISA Debit account created: 4101-7731-7410-8792 %{account_no: 137343541081659130, balance: 5000.12, deposits: [5000.12], pin: &quot;1355&quot;, withdrawals: []}","ref":"Hsbc.html#create_account/1","title":"Hsbc.create_account/1","type":"function"},{"doc":"","ref":"Hsbc.html#start_link/0","title":"Hsbc.start_link/0","type":"function"},{"doc":"Santander Bank generated by the macro on module Bank.BankGenbank_bin: &quot;4331-26&quot;","ref":"Santander.html","title":"Santander","type":"module"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"Santander.html#child_spec/1","title":"Santander.child_spec/1","type":"function"},{"doc":"Creates an account on the bank_name GenServer process with an optional intial balanceExamplesiex(1)&gt; __MODULE__.create_account(5000.12) :ok iex(2)&gt; VISA Debit account created: 4101-7731-7410-8792 %{account_no: 137343541081659130, balance: 5000.12, deposits: [5000.12], pin: &quot;1355&quot;, withdrawals: []}","ref":"Santander.html#create_account/1","title":"Santander.create_account/1","type":"function"},{"doc":"","ref":"Santander.html#start_link/0","title":"Santander.start_link/0","type":"function"},{"doc":"AtmTODO: Add description","ref":"readme.html","title":"Atm","type":"extras"},{"doc":"If available in Hex, the package can be installed by adding atm to your list of dependencies in mix.exs:def deps do [ {:atm, &quot;~&gt; 0.1.0&quot;} ] endDocumentation can be generated with ExDoc and published on HexDocs. Once published, the docs can be found at https://hexdocs.pm/atm.","ref":"readme.html#installation","title":"Atm - Installation","type":"extras"}]