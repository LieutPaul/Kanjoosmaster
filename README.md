# Kanjoosmaster
 One stop app to manage your expenses, budgets and a lot more.

## Features

#### Adding Expenses
- The first page gives us quick access to the current week (From last Sunday to next Saturday). We can add a transaction (expense or an earning) to the current day (along with the category). We can view the transactions of the current week on this page, by choosing the day of the week.
- We can view more details on a transaction by clicking on the transaction tile (which opens a pop up box). Here we can delete the transaction, add a receipt (Image/ PDF) to the transaction as well as add another user (by email) to the transaction (by splitting the cost).
- Whenever we add an expense that crosses a budget, a collapsable dialog box (reminder) is brought up which provides details of the budget that was exceeded.

#### Spending Charts

- On the second page, we can view spending trends for the last 4 months.
There are two bar charts for each month: 
- The first denotes the cumulative expenses and earnings as we go through the different days of the month. 
- The second denotes the day to day total expenditure as we go through the different days of the month.

#### Setting Budgets and Viewing All Transactions and Budgets
- On the third page, we can add a budget for an expense category between two dates.
- We also have access to all budgets and transactions (grouped by category) which occurred between two dates that can be set by the user (By default they are set to the beginning and end of the current month).
- The budget wheel indicates how much of the budget has been spent as a percentage. On clicking the budget wheel, a page is opened which has a list of all the expenses that come under the dates and the category of the budget (i.e which contributed to spending money from the budget). The budget can also be deleted from this page.
- There are also two pie charts which indicate the sum of amounts from the different expense and earning categories.

#### Profile Page
- Here, we can add new custom expense and earning categories.
- These categories will then show up whenever the user wants to add an expense/earning.
- We can also add the name of an expense that we are trying to buy over a longer stretch of time in the future. To each of these "large" expenses, we can change the amount of money we have saved up for the purchase and also add links to any e-commerce page that contains the product.
- This Page also has the logout button which takes the user back to the welcome page.

## File Structure

- lib:
	- main.dart : Contains the main function which will run when the app starts.
	- firebase_options.dart : Contains the firebase credentials and keys required to access firebaese services.
	- constants.dart : Certian constant colours and themes that are exported and used throughout the app.
	- helper.dart : Contains certain helper functions which are used throughout the app in multiple functions.
- lib/screens
	- welcome.dart : Contains the welcome page which provides two screens : Register and Login (register_page.dart and signin_page.dart)
	- home_page.dart : Contains the home page and initialises the bottom navigation bar and renders 4 pages based on which option is chosen.
	- daily_page.dart : Contains the daily expenses of the week and calls components/add_expense.dart to allow user to add a transaction. Each transaction tile calls /components/expense_component.dart when pressed to expand the transaction tile. This expanded expense allows user to see all information about the expense, add a receipt(PDF/Image) and add another user to the expense. In the expanded expense tile, it calls components/add_user_to_expense.dart tile when they try to add a user to the expense.
	- stats_page.dart : Shows the spending trends of the month in the form of two line charts. Calls components/analysis_chart.dart to render the graphs.
	- budgets_page.dart : Shows all budgets and transactions between two dates as well as a pie chart of all expenses and earnings summed by category. Calls components/budget_wheels.dart to render the budgets and the transaction tiles. It also calls widgets/pie_chart.dart to render the pie charts. On adding a budget, it calls components/add_budget.dart. On clicking a budget, to expand it and view more info, it calls pages/expanded_budget_page.dart.
	- profile_page.dart : Shows the user's name by calling components/get_username.dart. Then it shows the list of expense categories by calling components/get_expense_categories.dart and also provides the option of adding an expense category. Similarly for earning categories by calling components/get_earning_categories.dart. Finally, it shows the large expenses by calling components/get_large_expenses.dart. It then calls components/large_expense_component.dart which provides options of adding a new large expense, adding a link to an existing one or changing the amount of money saved for an existing one.

## Tech Frameworks

Kanjoosmaster uses the following frameworks:

- Flutter (To build the android App)
- Google Firebase:
    - Firebase Authentication for User Authentication and Authorisation
    - Firebase Firestore to store collections of data
    - Firebase Storage to store the receipts of the transactions.


And of course Kanjoosmaster itself is open source with a repository on GitHub.

## Running

Kanjoosmaster requires [Flutter](https://docs.flutter.dev/get-started/install) to be working on the system.
After cloning the repo, Run the following command to fetch the project dependencies:
```sh
flutter pub get
```
Then, run
```sh
flutter build apk --split-per-abi
```
at the root of the repo, to generate the apk.
After running this command, the apk can be found in kanjoosmaster/build/app/outputs/flutter-apk. Choose the appropriate apk to run on your android device.

## Demo Video

Demo Video Link - https://youtu.be/4BIsd6bBBcY