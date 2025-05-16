import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'screens/webview_screen.dart'; // 追加: WebViewScreen のインポート

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'レンタカー料金明細書',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RentalReceiptPage(),
    );
  }
}

class RentalReceiptPage extends StatelessWidget {
  const RentalReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('レンタカー料金明細書'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'トヨタレンタカー料金精算明細書をPDFで表示します',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfPreviewPage(),
                  ),
                );
              },
              child: const Text('PDF表示'),
            ),
            const SizedBox(height: 20),
            // ウェブビュー画面へのナビゲーションボタンを追加
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://toyota.jp/',
                      title: 'Webviewサンプル',
                      printPdf: false,
                    ),
                  ),
                );
              },
              child: const Text('ウェブサイト表示'),
            ),
            const SizedBox(height: 20),
            // ウェブビュー画面へのナビゲーションボタンを追加
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://toyota.jp/',
                      title: 'Webviewサンプル(印刷)',
                      printPdf: true,
                    ),
                  ),
                );
              },
              child: const Text('ウェブサイト表示(印刷)'),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF プレビュー'),
      ),
      body: PdfPreview(
        build: (format) => generateRentalReceiptPdf(format),
      ),
    );
  }

  Future<Uint8List> generateRentalReceiptPdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    // 日本語フォントを読み込む
    final fontData = await rootBundle.load('assets/fonts/NotoSansJP-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    
    // 太字フォントを読み込む
    final boldFontData = await rootBundle.load('assets/fonts/NotoSansJP-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

    // A4サイズのページを作成（横向きに変更） 
    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: 10.0,
      marginBottom: 10.0,
      marginLeft: 10.0,
      marginRight: 10.0,
    );
    
    // テーマを設定
    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: boldTtf,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        theme: theme,
        maxPages: 2,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ヘッダー部分
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('貸渡料金精算明細書（兼 ご請求書）',
                              style: pw.TextStyle(
                                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('Rental Agreement'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        alignment: pw.Alignment.topRight,
                        child: pw.Text('お客様控',
                            style: pw.TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // 貸渡人情報
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('貸渡人',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.Text('株式会社トヨタレンタリース札幌',
                              style: pw.TextStyle(
                                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('新千歳空港ポプラ店',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.Text('千歳市美々758-137',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.Text('電話番号 0123-23-0100',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('発行年月日: 令和 2年 8月 1日',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.Text('貸渡No.: 1238543',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(top: 5),
                            child: pw.Text('RA610R',
                                style: pw.TextStyle(fontSize: 8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // 借受人情報
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('借受人',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Row(
                          children: [
                            pw.Text('氏名 ',
                                style: pw.TextStyle(fontSize: 10)),
                            pw.Text('鈴木 弘之 様',
                                style: pw.TextStyle(
                                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Text('住所 ',
                                style: pw.TextStyle(fontSize: 10)),
                            pw.Container(
                              width: 200,
                              height: 15,
                              color: PdfColors.grey300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // 車両情報
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('<お貸しする車両>',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('貸渡車両 ハイエースZG',
                                    style: pw.TextStyle(fontSize: 10)),
                                pw.Text('登録No 札幌 303わ0885',
                                    style: pw.TextStyle(fontSize: 10)),
                                pw.Text('料金クラス V3-K    車両クラス W4-K',
                                    style: pw.TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('燃料 ガソリン',
                                    style: pw.TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // 利用内容
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('<ご利用内容>',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                          2: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('予定貸渡日時',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('予定返還日時',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('メーター(km)',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('8月1日15時00分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('8月1日18時42分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('60,205',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('実',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('7月30日11時00分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('7月30日11時00分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('利用分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('2日 5時間00分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2),
                                child: pw.Text('2日 4時間42分',
                                    style: pw.TextStyle(fontSize: 8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Text('料金種別 一般料金',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(width: 20),
                          pw.Text('料金割引率 10%',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text('添付品 安心Wプラン',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(width: 20),
                          pw.Text('ETCカード（有償）1',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        children: [
                          pw.Text('乗車人数 0名',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text('返却営業店舗 新千歳空港ポプラ店',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(width: 10),
                          pw.Text('0123-23-0100',
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(width: 10),
                          pw.Text('返却府県内',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text('運転者氏名 鈴木 弘之 様',
                              style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // 料金明細表
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // 左側（トヨタレンタカーマイル情報）
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(),
                            ),
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('<トヨタレンタカーマイル>',
                                    style: pw.TextStyle(fontSize: 10)),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Text('会員番号',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.SizedBox(width: 10),
                                    pw.Container(
                                      width: 100,
                                      height: 10,
                                      color: PdfColors.black,
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Text('利用マイル',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.SizedBox(width: 10),
                                    pw.Text('0',
                                        style: pw.TextStyle(fontSize: 10)),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text('付与マイル',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.SizedBox(width: 10),
                                    pw.Text('83',
                                        style: pw.TextStyle(fontSize: 10)),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text('8月1日獲得マイル',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.SizedBox(width: 10),
                                    pw.Text('83',
                                        style: pw.TextStyle(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Center(
                            child: pw.Text('TOYOTA Rent a Car',
                                style: pw.TextStyle(
                                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Center(
                            child: pw.Text('トヨタレンタカー予約センター',
                                style: pw.TextStyle(fontSize: 12)),
                          ),
                          pw.Center(
                            child: pw.Text('0800-7000-111（通話料無料）',
                                style: pw.TextStyle(
                                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Center(
                            child: pw.Text('http://rent.toyota.co.jp',
                                style: pw.TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 10),

                    // 右側（料金明細表）
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('料金明細表',
                                style: pw.TextStyle(
                                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(1),
                                1: const pw.FlexColumnWidth(1),
                                2: const pw.FlexColumnWidth(1),
                              },
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('項　　　目',
                                          style: pw.TextStyle(fontSize: 10)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('予定料金',
                                          style: pw.TextStyle(fontSize: 10)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('精算料金',
                                          style: pw.TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('基 本 料 金', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('61,050', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('61,050', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('カード割引額（0%）', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('その他割引額（10%）', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('6,105', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('6,105', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('小　　　計', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('70,785', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('70,785', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('免 責 補 償 料', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('3,300', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('3,300', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('特 別 装 備 料', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('待 合 送 迎 料', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('1,980', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('1,980', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('ワンウェイ料金', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('代　　　替', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('引 取 配 車 料', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('E T C 利 用 額', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('7,480', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('合　　　計', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('76,065', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('83,545', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('サービス車代替', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('N　　　O', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('免 責 補 償 料', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('お 支 払 額', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('76,065', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('83,545', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(width: 1),
                                    ),
                                  ),
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('消 費 税 額', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('6,915', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('7,595', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border(
                                      bottom: pw.BorderSide(width: 2),
                                    ),
                                  ),
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                        children: [
                                          pw.Text('合',
                                              style: pw.TextStyle(fontSize: 8)),
                                          pw.Text('計',
                                              style: pw.TextStyle(fontSize: 8)),
                                          pw.Text('金',
                                              style: pw.TextStyle(fontSize: 8)),
                                          pw.Text('額',
                                              style: pw.TextStyle(fontSize: 8)),
                                        ],
                                      )
                                    ),
                                    //右寄せ
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.fromLTRB(2, 2, 5, 2),
                                      child: pw.Text('38,115', style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                                    ),
/*
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('予　　約　　金', style: pw.TextStyle(fontSize: 8)),
                                    ),*/
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.fromLTRB(2, 2, 5, 2),
                                      child: pw.Text('38,115', style: pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                                    ),
/*
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('38,115', style: pw.TextStyle(fontSize: 8)),
                                    ),
*/
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('Webクレジット', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('Webクレジット決済', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('旅 客 乗 車 券', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('当 日 預 り 金', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('37,950', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('37,950', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('クレジット', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('JCBカード', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('当 日 預 り 計', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('76,065', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('76,065', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('マイル・ポイント利用', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('返 還 金 額', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('0', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(2),
                                      child: pw.Text('7,480', style: pw.TextStyle(fontSize: 8)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text('税率ごとに合計した対価の額',
                                  style: pw.TextStyle(fontSize: 10)),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Row(
                                children: [
                                  pw.Text('10%対象',
                                      style: pw.TextStyle(fontSize: 10)),
                                  pw.SizedBox(width: 20),
                                  pw.Text('税込金額',
                                      style: pw.TextStyle(fontSize: 10)),
                                  pw.SizedBox(width: 20),
                                  pw.Text('83,545',
                                      style: pw.TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // クレジット決済情報
                pw.Container(
                  width: 200,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        color: PdfColors.grey200,
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('クレジット',
                            style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Row(
                          children: [
                            pw.Text('7,480',
                                style: pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(width: 5),
                            pw.Text('Webクレジット決済',
                                style: pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      pw.Divider(),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('この明細の',
                                style: pw.TextStyle(fontSize: 8)),
                            pw.Text('お支払',
                                style: pw.TextStyle(fontSize: 8)),
                            pw.Text('金額',
                                style: pw.TextStyle(fontSize: 8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // 領収書
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: double.infinity,
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('領　収　書',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Row(
                          children: [
                            pw.Text('牛久市議会',
                                style: pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(width: 10),
                            pw.Text('様',
                                style: pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(width: 20),
                            pw.Text('領収書No. 0028583',
                                style: pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Row(
                          children: [
                            pw.Text('令和 2年 8月 1日',
                                style: pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(width: 20),
                            pw.Text('Receipt',
                                style: pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Row(
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Text('領 収 金 額',
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(width: 10),
                                    pw.Text('83,545 円',
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold)),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    pw.Text('（内消費税等',
                                        style: pw.TextStyle(fontSize: 8)),
                                    pw.SizedBox(width: 5),
                                    pw.Text('7,595 円）',
                                        style: pw.TextStyle(fontSize: 8)),
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(width: 20),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('内訳：小切手',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('　　　現　金',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('　　　振込等',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('　　　交通系IC',
                                    style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                            pw.SizedBox(width: 10),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text('0 円',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('83,545 円',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('0 円',
                                    style: pw.TextStyle(fontSize: 8)),
                                pw.Text('0 円',
                                    style: pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                            pw.SizedBox(width: 20),
                            pw.Container(
                              width: 100,
                              height: 60,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    style: pw.BorderStyle.dashed),
                              ),
                              child: pw.Center(
                                child: pw.Text('収 入 印 紙',
                                    style: pw.TextStyle(fontSize: 10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ];
        },
      ),
    );

    return pdf.save();
  }
}

