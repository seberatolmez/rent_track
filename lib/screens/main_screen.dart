import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/rental.dart';
import '../providers/rental_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/rental_card.dart';
import 'add_rental_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<RentalProvider>().loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kiralama Takip',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<RentalProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                height: 120,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: SummaryCard(
                          title: 'Toplam Kazanç',
                          amount: '₺${provider.totalEarnings.toStringAsFixed(2)}',
                          color: Colors.green,
                          icon: Icons.account_balance_wallet,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: SummaryCard(
                          title: 'Beklenen Gelir',
                          amount: '₺${provider.expectedIncome.toStringAsFixed(2)}',
                          color: Colors.blue,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: SummaryCard(
                          title: 'Gecikmiş Ödemeler',
                          amount: '₺${provider.overduePayments.toStringAsFixed(2)}',
                          color: Colors.red,
                          icon: Icons.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Aktif Kiralamalar'),
                  Tab(text: 'Geçmiş Kiralamalar'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRentalList(provider.activeRentals),
                    _buildRentalList(provider.inactiveRentals),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Kiralama'),
      ),
    );
  }

  Widget _buildRentalList(List<Rental> rentals) {
    if (rentals.isEmpty) {
      return Center(
        child: Text(
          'Henüz kiralama bulunmuyor',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: rentals.length,
        itemBuilder: (context, index) {
          return RentalCard(rental: rentals[index]);
        },
      ),
    );
  }
} 