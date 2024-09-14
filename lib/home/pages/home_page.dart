import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:qr_earth/home/widgets/safe_padding.dart';
import 'package:qr_earth/utils/colors.dart';
import 'package:qr_earth/utils/constants.dart';
import 'package:qr_earth/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        leadingWidth: 60,
        titleSpacing: 0,
        leading: Center(child: Image.asset("assets/images/logo.png")),
        title: const Text(
          'QR Earth',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: keyColor,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('scanner'),
        label: const Text("Scan QR"),
        icon: const Icon(Icons.qr_code_scanner_rounded),
      ),
      body: SafePadding(
        child: RefreshIndicator.adaptive(
          onRefresh: _refreshUser,
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                "assets/images/asset1.png",
                height: 200,
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'USERNAME',
                        style: TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        Global.user.username,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 2.0,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        'BOTTLES RECYCLED',
                        style: TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        Global.user.redeemedCodeCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 2.0,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      const Text(
                        'POINTS',
                        style: TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            Global.user.points.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 2.0,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () async {
                              if (Global.user.points > 100) {
                                context.pushNamed('redeem');
                              } else {
                                await HapticFeedback.selectionClick();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "You need at least 100 points to redeem."),
                                  ),
                                );
                              }
                            },
                            label: const Text("Redeem"),
                            icon: const Icon(Icons.redeem),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshUser() async {
    var response = await http.get(
      Uri.parse(
          "${AppConfig.serverBaseUrl}${ApiRoutes.userInfo}?user_id=${Global.user.id}"),
    );

    if (response.statusCode == HttpStatus.ok) {
      Global.user.setFromJson(jsonDecode(response.body));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Unhandled Exception: ${response.statusCode} - ${response.body}"),
        ),
      );
    }
  }
}
