import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_manager.dart';
import 'guest_start_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // ===== In‑App Purchase (IAP) =====
  static const String _kProductId = 'minutes_30_twd'; // 30 分鐘（NT$50）
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _available = false;
  bool _loading = true;
  List<ProductDetails> _products = const [];
  int _packs30 = 0; // 尚餘的 30 分鐘套餐數

  @override
  void initState() {
    super.initState();
    _initIAP();
    _loadPacks();
  }

  Future<void> _initIAP() async {
    // 檢查可用性並查詢產品
    final available = await _iap.isAvailable();
    setState(() => _available = available);

    _purchaseSub = _iap.purchaseStream.listen(_onPurchaseUpdate, onDone: () {
      _purchaseSub?.cancel();
    }, onError: (e) {
      // 這裡可上報錯誤
    });

    if (available) {
      final resp = await _iap.queryProductDetails({_kProductId});
      setState(() {
        _products = resp.productDetails;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPacks() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _packs30 = sp.getInt('packs_30') ?? 0;
    });
  }

  Future<void> _addPackTrick() async {
    final sp = await SharedPreferences.getInstance();
    _packs30 = (sp.getInt('packs_30') ?? 0) + 1;
    await sp.setInt('packs_30', _packs30);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已充值：+1 套 30 分鐘（測試）')),
      );
      Navigator.maybePop(context); // 關閉彈窗（若存在）
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> detailsList) async {
    for (final pd in detailsList) {
      switch (pd.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // TODO: 在你的服務端驗證收據（強烈建議）
          // 交付權益：增加 30 分鐘配額等
          if (pd.pendingCompletePurchase) {
            await _iap.completePurchase(pd);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('購買成功：已解鎖 30 分鐘')),
            );
          }
          break;
        case PurchaseStatus.error:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('購買失敗：${pd.error}')),
            );
          }
          break;
        case PurchaseStatus.canceled:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已取消購買')),
            );
          }
          break;
        case PurchaseStatus.pending:
          // 顯示 pending 狀態可選
          break;
      }
    }
  }

  Future<void> _buy30Min() async {
    if (!_available || _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購買不可用，請稍後再試')),
      );
      return;
    }
    final product = _products.firstWhere((p) => p.id == _kProductId);
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  void _showPurchaseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;
        final h = size.height; final fsBody = h * 0.018; final fsTitle = h * 0.022;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('購買時長', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '30 分鐘對話時長（NT50）\n用於語音對話、識別與背景效果等所有功能。',
                style: TextStyle(color: Colors.white70, fontSize: fsBody, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ))
              else
                SizedBox(
                  width: double.infinity,
                  height: h * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA7C7E7),
                      foregroundColor: const Color(0xFF143343),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _addPackTrick, // 暫用本地充值（測試）
                    child: Text('購買 30 分鐘（NT\$50）', style: TextStyle(fontSize: fsBody, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthManager.getEmail(),
      builder: (context, snap) {
        final email = snap.data ?? '';
        final size = MediaQuery.of(context).size;
        final h = size.height;
        final s = math.min(size.width, h);
        final fsTitle = h * 0.022;
        final fsBody  = h * 0.018;
        final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

        return Scaffold(
          backgroundColor: const Color(0xFF0C1C24),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        iconSize: h * 0.028,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: s * 0.1,
                    backgroundColor: const Color(0xFFA7C7E7),
                    child: Text(initial,
                        style: TextStyle(
                          fontSize: s * 0.08,
                          color: const Color(0xFF143343),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(height: h * 0.02),
                  Text(
                    email.isEmpty ? '未綁定郵箱' : email,
                    style: TextStyle(fontSize: fsTitle, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: h * 0.01),
                  Text('已登入', style: TextStyle(fontSize: fsBody, color: Colors.white70)),
                  const Spacer(),

                  // 配額狀態卡片（顯示剩餘 30 分鐘套餐與總分鐘）
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: h * 0.014),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102431),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Color(0xFFA7C7E7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '剩餘套餐：$_packs30 個（每個 30 分鐘）',
                                style: TextStyle(color: Colors.white, fontSize: fsBody, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '合計可用：${_packs30 * 30} 分鐘',
                                style: TextStyle(color: Colors.white70, fontSize: fsBody * 0.9),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _addPackTrick,
                          child: const Text('充值 1 組（測試）'),
                        ),
                      ],
                    ),
                  ),

                  // 購買按鈕（NT$50 / 30 分鐘）
                  SizedBox(
                    width: double.infinity,
                    height: h * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showPurchaseSheet,
                      child: Text('購買 30 分鐘（NT\$50）', style: TextStyle(fontSize: fsBody, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: h * 0.012),

                  SizedBox(
                    width: double.infinity,
                    height: h * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7C7E7),
                        foregroundColor: const Color(0xFF143343),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await AuthManager.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const GuestStartPage()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text('退出登入', style: TextStyle(fontSize: fsBody, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}