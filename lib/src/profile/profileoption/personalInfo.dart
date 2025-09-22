import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:securetradeai/src/Service/otp_service.dart';

import '../../../method/methods.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({
    Key? key,
  }) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  var name = TextEditingController();
  var oldpass = TextEditingController();
  var newpasswrod = TextEditingController();
  var conformPassord = TextEditingController();
  var email = TextEditingController();
  var walletAddress = TextEditingController();
  var password = TextEditingController();
  // OTP state for Wallet Address change
  final TextEditingController walletOtpController = TextEditingController();
  bool isWalletOtpSending = false;
  bool isWalletOtpSent = false;
  bool isWalletOtpVerifying = false;
  bool isWalletOtpVerified = false;

  Future<void> _sendWalletChangeOtp() async {
    setState(() { isWalletOtpSending = true; });
    try {
      OtpService.clearRequestId();
      final res = await OtpService.sendOtpToEmail(
        email: commonEmail,
        type: "withdrawal", // same type as Withdrawal flow
        context: context,
      );
      setState(() { isWalletOtpSent = res.isSuccess; });
    } finally {
      setState(() { isWalletOtpSending = false; });
    }
  }

  Future<void> _verifyWalletChangeOtp() async {
    setState(() { isWalletOtpVerifying = true; });
    try {
      final res = await OtpService.verifyOtpCode(
        email: commonEmail,
        otp: walletOtpController.text,
        context: context,
      );
      setState(() { isWalletOtpVerified = res.isSuccess; });
    } finally {
      setState(() { isWalletOtpVerifying = false; });
    }
  }

  bool isAPIcalle = false;
  var minedata = [];
  var finalData;
  File? imageFile;
  String filePath = '';
  _getData() async {
    try {
      setState(() {
        isAPIcalle = true;
      });
      final data = await CommonMethod().getMineData();
      if (data.status == "success") {
        setState(() {
          minedata = data.data;
          minedata.forEach((e) {
            finalData = e;
            setState(() {
              name.text = finalData.name;
            });
          });
          isAPIcalle = false;
        });
      } else {
        showtoast(data.message, context);
      }
    } catch (e) {
      print(e);
      setState(() {
        isAPIcalle = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2234),
      appBar: CommonAppBar.basic(
        title: "personalinfo".tr,
      ),
      body: isAPIcalle
          ? Center(
              child: CircularProgressIndicator(
                color: securetradeaicolor,
              ),
            )
          : Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "nickname".tr,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          Row(
                            children: [
                              Text(
                                finalData.name,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _displayTextInputDialog(
                                      context,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Colors.white,
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "uuid".tr,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          Row(
                            children: [
                              Text(
                                finalData.referralCode,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: finalData.referralCode,
                                      ),
                                    );
                                    showtoast("Copy", context);
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 15,
                                    color: Colors.white,
                                  ))
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "avatar".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () => showsnakbar(context),
                            child: ClipOval(
                              child: Image.network(
                                (finalData.image == "" ||
                                        finalData.image == null)
                                    ? imagepath + "default.jpg"
                                    : imagepath + finalData.image,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "email".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                finalData.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _changeEmail(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Mobile",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            finalData.mobile,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "location".tr,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          Text(
                            finalData.country,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "changePassword".tr,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                _changePassword(context);
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Wallet Address",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width : 100,
                                child: Text(
                                  finalData.walletAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _changeWalletAddress(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _changeWalletAddress(
    BuildContext context,
  ) async {
    // reset OTP state each time dialog opens
    setState(() {
      isWalletOtpSending = false;
      isWalletOtpSent = false;
      isWalletOtpVerifying = false;
      isWalletOtpVerified = false;
      walletOtpController.clear();
    });

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSB) {
              return AlertDialog(
            backgroundColor: const Color(0xFF1A2234),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Text(
              'Update Wallet Address',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Enter your wallet address",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  controller: walletAddress,
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Enter password",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  controller: password,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (!isWalletOtpSent) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isWalletOtpSending ? null : () async {
                        await _sendWalletChangeOtp();
                        setSB(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0B90B),
                        foregroundColor: Colors.black,
                      ),
                      child: isWalletOtpSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Send OTP'),
                    ),
                  ),
                ] else if (isWalletOtpSent && !isWalletOtpVerified) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xfff3f3f4)),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: walletOtpController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter OTP',
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isWalletOtpVerifying ? null : () async {
                          await _verifyWalletChangeOtp();
                          setSB(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0B90B),
                          foregroundColor: Colors.black,
                        ),
                        child: isWalletOtpVerifying
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text('Verify'),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.verified, color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Text('OTP Verified', style: TextStyle(color: Colors.green)),
                    ],
                  )
                ],
              ],
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () {
                    if (!isWalletOtpVerified) {
                      showtoast("Please verify OTP first", context);
                      return;
                    }
                    _updateWalletAddress();
                  },
                  child: const Text("Update",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 20,
              ),
            ],
          );
            },
          );
        });
  }

  Future<void> _displayTextInputDialog(
    BuildContext context,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A2234),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Text(
              'Enter Your Name',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: name,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  _update();
                },
                child: const Text(
                  "Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  Future<void> _changePassword(
    BuildContext context,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A2234),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Text(
              'Change your Password',
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              height: 150,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter old password",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    controller: oldpass,
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter new password",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    controller: newpasswrod,
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    controller: conformPassord,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () {
                    _updatePassword();
                  },
                  child: const Text("Change",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 10,
              ),
            ],
          );
        });
  }

  Future<void> _changeEmail(
    BuildContext context,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A2234),
            contentPadding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 10),
            title: const Text(
              'Change your Email',
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              height: 100,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter New  Email",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    controller: email,
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Enter  password",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    controller: password,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () {
                    _updateEmail();
                  },
                  child: const Text("Update",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 20,
              ),
            ],
          );
        });
  }

  Future _updatePassword() async {
    try {
      if (oldpass.text == "") {
        showtoast("Old password field is empty", context);
      } else if (newpasswrod.text == "") {
        showtoast("New password field is empty", context);
      } else if (conformPassord.text == "") {
        showtoast("New password field is empty", context);
      } else if (newpasswrod.text != conformPassord.text) {
        showtoast("Newpassword or Confirm Password not match", context);
      } else {
        showLoading(context);
        var bodydata = jsonEncode({
          "user_id": commonuserId,
          "old_password": oldpass.text,
          "password": newpasswrod.text,
          "conf_password": conformPassord.text
        });
        final response =
            await http.post(Uri.parse(updatepassword), body: bodydata);
        if (response.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          _getData();
          var data = jsonDecode(response.body);
          oldpass.clear();
          newpasswrod.clear();
          conformPassord.clear();
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future _updateEmail() async {
    try {
      if (email.text == "") {
        showtoast("Email field is empty", context);
      } else if (password.text == "") {
        showtoast(" password field is empty", context);
      } else {
        showLoading(context);
        var bodydata = jsonEncode({
          "user_id": commonuserId,
          "email": email.text,
          "password": password.text
        });
        print(bodydata);
        final response =
            await http.post(Uri.parse(updateEmail), body: bodydata);
        if (response.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          _getData();
          var data = jsonDecode(response.body);
          print(data);
          password.clear();
          setState(() {
            commonEmail = email.text;
          });
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future _updateWalletAddress() async {
    try {
      if (walletAddress.text == "") {
        showtoast("Email field is empty", context);
      } else if (password.text == "") {
        showtoast(" password field is empty", context);
      } else {
        showLoading(context);
        var bodydata = jsonEncode({
          "user_id": commonuserId,
          "wallet_address": walletAddress.text,
          "password": password.text
        });
        print(bodydata);
        final response =
            await http.post(Uri.parse(updateWallet), body: bodydata);

        showtoast(response.statusCode.toString(), context);

        if (response.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          _getData();
          var data = jsonDecode(response.body);
          print(data);
          password.clear();
          setState(() {
            commonEmail = walletAddress.text;
          });
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _update() async {
    try {
      showLoading(context);
      if (name.text == "") {
        showtoast("Name Field is empty ", context);
      } else {
        var bodydata = jsonEncode({
          "user_id": commonuserId,
          "name": name.text,
        });
        final response = await http.post(Uri.parse(updatename), body: bodydata);
        if (response.statusCode != 200) {
          showtoast("Server Error", context);
          Navigator.pop(context);
        } else {
          _getData();
          var data = jsonDecode(response.body);
          name.clear();
          showtoast(data['message'], context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  showsnakbar(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2234),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          IconButton(
                              onPressed: () {
                                _getFromGallery(ImageSource.gallery);
                              },
                              icon: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.white,
                              )),
                          const Text(
                            "Gallery",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              _getFromGallery(ImageSource.camera);
                            },
                            icon: const Icon(Icons.camera,
                                size: 40, color: Colors.white),
                          ),
                          const Text(
                            "Camera",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )
                    ],
                  )),
            ),
          );
        });
  }

  _getFromGallery(ImageSource source) async {
    var pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _updateProfile();
        filePath = File(pickedFile.path).toString();
      });
    }
  }

  _updateProfile() async {
    var bytes = await imageFile!.readAsBytesSync();
    var base = await base64Encode(bytes);
    final response = await http.post(
      Uri.parse(updateUserProfile),
      body: jsonEncode({
        'user_id': commonuserId,
        'profile_image': base,
      }),
    );
    switch (response.statusCode) {
      case 200:
        var data = jsonDecode(response.body);
        print(data);
        if (data['responsecode'] == '200') {
          Navigator.pop(context);
          _getData();
        }
        break;
      case 401:
        print('Invalid Details');
        break;
      default:
        print('Exception');
    }
  }
}
