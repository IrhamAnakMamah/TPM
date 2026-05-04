import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthArticlesScreen extends StatefulWidget {
  const HealthArticlesScreen({super.key});

  @override
  State<HealthArticlesScreen> createState() => _HealthArticlesScreenState();
}

class _HealthArticlesScreenState extends State<HealthArticlesScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }
  
  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Using /everything endpoint with health keyword in Indonesian
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/everything?q=kesehatan OR farmasi OR obat&language=id&sortBy=publishedAt&pageSize=20&apiKey=efd06f6edfac4298ad5a116e79224bf1'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_articles.length} health articles');
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat artikel (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server: $e';
        _isLoading = false;
      });
      print('❌ Error fetching articles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tips & Artikel Kesehatan'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArticles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D9488),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchArticles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _articles.isEmpty
                  ? const Center(
                      child: Text('Tidak ada artikel tersedia'),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchArticles,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _articles.length + 1, // +1 for featured article
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Featured article (first article)
                            if (_articles.isEmpty) return const SizedBox();
                            final article = _articles[0];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFeaturedArticle(
                                  context,
                                  article['urlToImage'] ?? 'https://via.placeholder.com/500x300?text=No+Image',
                                  article['title'] ?? 'No Title',
                                  article['source']['name'] ?? 'Unknown',
                                  article['url'] ?? '',
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  'Artikel Terbaru',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 15),
                              ],
                            );
                          }
                          
                          // Regular articles (skip first one as it's featured)
                          // index 1 -> _articles[1], index 2 -> _articles[2], etc.
                          // So we use index directly (not index-1) because we want to skip _articles[0]
                          // But itemCount is _articles.length + 1, so max index is _articles.length
                          // When index = _articles.length, we try to access _articles[_articles.length] which is out of bounds
                          // FIX: We should use index-1 to skip the first article OR change itemCount
                          
                          // Better approach: just show all articles starting from index 1
                          if (index >= _articles.length) return const SizedBox();
                          
                          final article = _articles[index];
                          return _buildArticleTile(
                            article['title'] ?? 'No Title',
                            article['source']['name'] ?? 'Unknown',
                            _formatDate(article['publishedAt']),
                            article['url'] ?? '',
                            article['urlToImage'],
                          );
                        },
                      ),
                    ),
    );
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inHours < 1) {
        return '${diff.inMinutes} menit yang lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam yang lalu';
      } else if (diff.inDays == 1) {
        return 'Kemarin';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} hari lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildFeaturedArticle(BuildContext context, String imgUrl, String title, String category, String articleUrl) {
    return GestureDetector(
      onTap: () {
        // TODO: Open article URL in browser or webview
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(imgUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Handle image load error
            },
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  category,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleTile(String title, String category, String time, String articleUrl, String? imageUrl) {
    return GestureDetector(
      onTap: () {
        // TODO: Open article URL in browser or webview
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Thumbnail image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.article, color: Colors.teal),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article, color: Colors.teal, size: 24),
              ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}