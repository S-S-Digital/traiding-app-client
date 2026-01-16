
  import 'package:aspiro_trade/ui/ui.dart';
import 'package:flutter/material.dart';

Future<bool?> showDeleteTickerDialog(BuildContext context) {
    return showGeneralDialog<bool>(
                        context: context,
                        barrierLabel: "DeleteTickerDialog",
                        barrierDismissible: false,
                        barrierColor: Colors.black54,
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder:
                            (context, animation, secondaryAnimation) {
                              return const DeleteTickerDialog();
                            },
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                              final offsetAnimation =
                                  Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                    ),
                                  );
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                      );
  }
