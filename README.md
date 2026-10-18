# 🌐 Waseem Net Service (WNS)
### Enterprise-Grade Internet Fee & Collection Management System

**Waseem Net Service (WNS)** is a production-level, cross-platform Flutter application (Mobile & Web) built specifically for Internet Service Providers (ISPs) to manage customer subscriptions, internet packages, monthly fee collections (Wasooli), Bluetooth thermal POS receipt printing, and revenue financial analytics.

---

## 🌟 Key Features

1. **Role-Based Authentication & Access Control**
   - **Admin Role**: Full control over user management, package pricing, financial analytics, monthly billing reset, and reports.
   - **Collection Agent (Wasooli) Role**: Field-staff view to search customers by ID/Name, record full or partial payments, and print POS thermal receipts.
   - **Quick Demo Mode**: Instant 1-tap role switching for rapid client demonstrations.

2. **Customer Directory & WAS ID Format**
   - Unique customer IDs (`WAS1`, `WAS2`, `WAS3`...)
   - Detailed subscriber records (Name, Phone, Address, Assigned Package).
   - Real-time payment statuses with color-coded badges: **Paid** (Green), **Partial** (Amber), and **Unpaid** (Red).
   - Auto-calculated remaining balance (e.g., Fee = Rs 1700, Paid = Rs 1000 $\rightarrow$ Balance = Rs 700).

3. **Revenue Analytics Dashboard & Web Portal**
   - Total Expected Revenue vs. Collected Revenue vs. Pending Balance.
   - Interactive Collection Progress Bar & Donut Chart (`fl_chart`).
   - Active user count and paid/partial/unpaid ratios.
   - Fully responsive **Web Portal Mode** for desktop/tablet browser dashboards.

4. **Month-Wise Billing & Data Management**
   - Independent monthly ledgers (`October 2023`, `November 2023`, etc.).
   - Month Selector dropdown to inspect past billing cycles and collection history.
   - **Monthly Collection Reset**: Archives previous month records and rolls over customers with zero balance for the new billing month.

5. **POS Bluetooth Thermal Slip Printing**
   - Direct ESC/POS byte command printing via Bluetooth.
   - Prints professional thermal slips with company header, WAS ID, customer name, billing month, paid amount, remaining balance, and collector details.
   - Compatible with affordable 58mm/80mm Bluetooth thermal printers.

6. **Comprehensive Financial Reporting & CSV Export**
   - Filterable billing tables by status and package.
   - 1-Tap **CSV Export** optimized for Excel & Google Sheets.
   - Built-in App Exit Confirmation dialog and clean Material 3 Enterprise Light Theme.

---

## 🔐 Default Login Credentials

| Role | Username | Password |
| :--- | :--- | :--- |
| **Admin** | `admin` | `123` |
| **Collection Agent** | `wasooli` | `123` |

---

## 🖨️ Recommended Bluetooth Thermal Printer (Pakistan Market)
* **Model**: **GOOJPRT PT-210** or **MPT-II** (58mm Handheld Bluetooth Thermal Printer)
* **Price Range**: ~PKR 4,500 – 6,500 (Available on Daraz or local computer markets like Hafeez Center Lahore, Saddar Karachi).
* **Paper Roll**: Standard 58mm thermal paper roll (~Rs 50-70 per roll).

---

## 🛠️ Tech Stack
* **Framework**: Flutter (Dart 3.x)
* **State Management**: Provider (`ChangeNotifier`)
* **Local Storage**: `shared_preferences` (Offline-first & Cloud-ready for Supabase)
* **Charts**: `fl_chart`
* **Thermal Printing**: `print_bluetooth_thermal`

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/waseem-net-service.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on mobile or web:
   ```bash
   flutter run
   ```
   Or for web browser:
   ```bash
   flutter run -d chrome
   ```
