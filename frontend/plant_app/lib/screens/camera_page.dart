import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/qr_overlay.dart';

class Camerapage extends StatefulWidget {
  const Camerapage({super.key});

  @override
  State<Camerapage> createState() => _CamerapageState();
}

class _CamerapageState extends State<Camerapage> {

  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
          onDetect: (barcodes) {
            if(barcodes.raw == null){
              debugPrint('Failed to scan barcode');
            } else {
              final String code = barcodes.raw!;
              debugPrint('Barcode found $code');
              }
            },
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
          // appbar
          Positioned(
            top: 71.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  // x button
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: Constant.primaryColor.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                // torch button
                Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Constant.primaryColor.withOpacity(0.2),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: (){
                      cameraController.toggleTorch();
                    },
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController.torchState,
                      builder: (context, state, child) {
                        switch (state){
                          case TorchState.off:
                            return const Icon(Icons.flash_off, color: Colors.white,);
                          case TorchState.on:
                            return const Icon(Icons.flash_on, color: Colors.yellow,);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}