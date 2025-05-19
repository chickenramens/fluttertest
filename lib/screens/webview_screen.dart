import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart'; // 追加
import 'package:pdf/pdf.dart'; // 追加

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final int printPdf;

  const WebViewScreen({
    Key? key,
    required this.url,
    this.title = 'WebView',
    this.printPdf = 0,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // ウェブビューコントローラーを初期化
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              if(this.widget.printPdf == 0) {
                // PDFファイルを印刷
                return NavigationDecision.navigate;
              } else if(this.widget.printPdf == 1) {
                // PDFファイルを印刷
                _downloadAndPrintPdf(request.url);
              } else {
                // PDFファイルをダウンロードして保存
                _downloadAndSavePdf(request.url);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            if(url.endsWith('.pdf')) {
              // PDFファイルの場合は、デフォルトのブラウザで開く
              print('Opening PDF in external browser: $url');
              launchUrl(Uri.parse(url));
            }
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // 更新ボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }


  Future<void> _downloadAndPrintPdf(String url) async {
    try {
      // PDFファイルをダウンロード
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // ダウンロードディレクトリを取得
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${url.split('/').last}';
        final file = File(filePath);

        // ファイルに保存
        await file.writeAsBytes(response.bodyBytes);

        // ユーザーに通知
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDFを保存しました: $filePath')),
          );
        }

        // PDFを印刷
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => response.bodyBytes,
        );
      } else {
        throw Exception('PDFのダウンロードに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      // エラーハンドリング
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  Future<void> _downloadAndSavePdf(String url) async {
    try {
      // PDFファイルをダウンロード
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // ダウンロードディレクトリを取得
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${url.split('/').last}';
        final file = File(filePath);

        // ファイルに保存
        await file.writeAsBytes(response.bodyBytes);

        // ユーザーに通知
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDFを保存しました: $filePath')),
          );
        }

        // 保存したPDFを開く
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('PDFを開くことができませんでした: ${result.message}');
        }
      } else {
        throw Exception('PDFのダウンロードに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      // エラーハンドリング
      debugPrint('Error downloading PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }
}
