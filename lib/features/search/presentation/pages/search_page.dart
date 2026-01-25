import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../webview/presentation/pages/webview_screen.dart';
import '../cubit/search_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchCubit>(),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedPlatform = 'amazon';

  // Platform options
  final List<Map<String, String>> _platforms = [
    {'id': 'amazon', 'name': 'Amazon'},
    {'id': 'aliexpress', 'name': 'AliExpress'},
    {'id': 'shein', 'name': 'SHEIN'},
    {'id': 'taobao', 'name': 'Taobao'},
    {'id': 'alibaba', 'name': 'Alibaba'},
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _queryController.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchCubit>().search(query, _selectedPlatform);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Search Products'), elevation: 0),
      body: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          if (state is SearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SearchLoaded) {
            // Navigate to WebView
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => WebViewScreen(
                      initialUrl: state.url,
                      title: 'Search Results',
                    ),
              ),
            );
            // Reset state so we can search again if we come back
            context.read<SearchCubit>().reset();
          }
        },
        builder: (context, state) {
          final isLoading = state is SearchLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Query Input
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    labelText: 'What are you looking for?',
                    hintText: 'e.g. iphone case',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  enabled: !isLoading,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                ),
                const SizedBox(height: 24),

                // Platform Selector
                const Text(
                  'Select Platform',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _platforms.map((platform) {
                        final isSelected = _selectedPlatform == platform['id'];
                        return ChoiceChip(
                          label: Text(platform['name']!),
                          selected: isSelected,
                          onSelected:
                              isLoading
                                  ? null
                                  : (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedPlatform = platform['id']!;
                                      });
                                    }
                                  },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                ),

                const Spacer(),

                // Search Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Search Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
