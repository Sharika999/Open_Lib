// // lib/screens/register_user_screen.dart
// import 'package:flutter/material.dart';
// import 'package:open_library_app/services/api_service.dart';
// import 'package:open_library_app/models/user.dart'; // Import the User model
//
// class RegisterUserScreen extends StatefulWidget {
//   const RegisterUserScreen({super.key});
//
//   @override
//   State<RegisterUserScreen> createState() => _RegisterUserScreenState();
// }
//
// class _RegisterUserScreenState extends State<RegisterUserScreen> {
//   final TextEditingController _mobileNoController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final ApiService _apiService = ApiService();
//   String _message = '';
//   bool _isLoading = false;
//
//   Future<void> _register() async {
//     setState(() {
//       _isLoading = true;
//       _message = 'Registering user...';
//     });
//
//     try {
//       // apiService.registerUser now returns a User object
//       final User registeredUser = await _apiService.registerUser(
//         _mobileNoController.text,
//         _nameController.text,
//         _passwordController.text, // Remember to hash this in a real app!
//         _emailController.text.isEmpty ? null : _emailController.text,
//       );
//       setState(() {
//         _message = 'Success! User "${registeredUser.userName}" registered with ID: ${registeredUser.userId}';
//         _mobileNoController.clear();
//         _nameController.clear();
//         _passwordController.clear();
//         _emailController.clear();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('User "${registeredUser.userName}" registered successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _message = 'Error: ${e.toString()}';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registration Failed: ${e.toString()}'), backgroundColor: Colors.red),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register New User'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _mobileNoController,
//               decoration: const InputDecoration(
//                 labelText: 'Mobile Number',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.phone),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Full Name',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.person),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.lock),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: 'Email (Optional)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.email),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 24),
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ElevatedButton.icon(
//                     onPressed: _register,
//                     icon: const Icon(Icons.app_registration),
//                     label: const Text('Register User', style: TextStyle(fontSize: 18)),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//             const SizedBox(height: 20),
//             Text(
//               _message,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: _message.startsWith('Error') ? Colors.red : Colors.green,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class RegisterUserScreen extends StatefulWidget {
//   const RegisterUserScreen({super.key});
//
//   @override
//   State<RegisterUserScreen> createState() => _RegisterUserScreenState();
// }
//
// class _RegisterUserScreenState extends State<RegisterUserScreen> {
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _referralCodeController = TextEditingController();
//   final _otpController = TextEditingController();
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   bool _otpSent = false;
//   bool _isLoading = false;
//   String _verificationId = '';
//   String _statusMessage = '';
//
//   Future<void> _sendOTP() async {
//     final phone = _phoneController.text.trim();
//     final email = _emailController.text.trim();
//
//     if (phone.isEmpty || phone.length != 10) {
//       _showMessage("Enter a valid 10-digit mobile number");
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Checking existing account...';
//     });
//
//     try {
//       // 🔍 Check if phone number already exists
//       final phoneCheck = await _firestore
//           .collection("Users")
//           .where("usr_mob_no", isEqualTo: int.tryParse(phone))
//           .limit(1)
//           .get();
//
//       if (phoneCheck.docs.isNotEmpty) {
//         _showMessage("Mobile number is already registered");
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // 🔍 Check if email already exists (if email is not empty)
//       if (email.isNotEmpty) {
//         final emailCheck = await _firestore
//             .collection("Users")
//             .where("usr_email_id", isEqualTo: email)
//             .limit(1)
//             .get();
//
//         if (emailCheck.docs.isNotEmpty) {
//           _showMessage("Email is already registered");
//           setState(() => _isLoading = false);
//           return;
//         }
//       }
//
//       // ✅ If all good, send OTP
//       _statusMessage = 'Sending OTP...';
//       await _auth.verifyPhoneNumber(
//         phoneNumber: "+91$phone",
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.signInWithCredential(credential);
//           _registerUser();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           _showMessage("OTP sending failed: ${e.message}");
//           setState(() => _isLoading = false);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() {
//             _verificationId = verificationId;
//             _otpSent = true;
//             _isLoading = false;
//             _statusMessage = "OTP sent to +91$phone";
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     } catch (e) {
//       _showMessage("Error while checking existing user: $e");
//       setState(() => _isLoading = false);
//     }
//   }
//
//
//   void _verifyOTPAndRegister() async {
//     final smsCode = _otpController.text.trim();
//
//     if (_verificationId.isEmpty || smsCode.isEmpty) {
//       _showMessage("Please enter the OTP");
//       return;
//     }
//
//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: smsCode,
//       );
//       await _auth.signInWithCredential(credential);
//       _registerUser();
//     } catch (e) {
//       _showMessage("Invalid OTP. Try again.");
//     }
//   }
//
//   Future<void> _registerUser() async {
//     final name = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final password = _passwordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();
//     final referralCode = _referralCodeController.text.trim();
//
//     if (name.isEmpty || phone.isEmpty || password.isEmpty || email.isEmpty) {
//       _showMessage("Name, email, phone number, and password are required");
//       return;
//     }
//
//     if (password != confirmPassword) {
//       _showMessage("Passwords do not match");
//       return;
//     }
//
//     final phoneInt = int.tryParse(phone);
//     if (phoneInt == null || phone.length != 10) {
//       _showMessage("Enter a valid 10-digit phone number");
//       return;
//     }
//
//     try {
//       // 🔍 Check Firestore for duplicate phone
//       final phoneCheck = await _firestore
//           .collection("Users")
//           .where("usr_mob_no", isEqualTo: phoneInt)
//           .limit(1)
//           .get();
//       if (phoneCheck.docs.isNotEmpty) {
//         _showMessage("Mobile number already registered");
//         return;
//       }
//
//       // 🔍 Check Firestore for duplicate email
//       final emailCheck = await _firestore
//           .collection("Users")
//           .where("usr_email_id", isEqualTo: email)
//           .limit(1)
//           .get();
//       if (emailCheck.docs.isNotEmpty) {
//         _showMessage("Email is already registered");
//         return;
//       }
//
//       // ✅ Create Firebase Auth account (email/password)
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user?.uid;
//       if (uid == null) {
//         _showMessage("Account creation failed");
//         return;
//       }
//
//       // ✅ Store user data in Firestore
//       await _firestore.collection("Users").doc(uid).set({
//         "usr_name": name,
//         "usr_email_id": email,
//         "usr_mob_no": phoneInt,
//         "usr_status": "Active",
//         "usr_created_by": "System",
//         "usr_created_on": FieldValue.serverTimestamp(),
//         "usr_updated_by": "System",
//         "usr_updated_on": FieldValue.serverTimestamp(),
//         "usr_reg_dt": FieldValue.serverTimestamp(),
//         "usr_ref_code": referralCode,
//       });
//
//       _showMessage("Registered successfully!", isSuccess: true);
//       Navigator.pop(context); // Go back to login
//
//     } catch (e) {
//       _showMessage("Error saving user: ${e.toString()}");
//     }
//   }
//
//
//
//
//   void _showMessage(String msg, {bool isSuccess = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isSuccess ? Colors.green : Colors.red,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildInputRow("First Name", _firstNameController),
//             const SizedBox(height: 12),
//             _buildInputRow("Last Name", _lastNameController),
//             const SizedBox(height: 12),
//             _buildInputRow("Email Address", _emailController),
//             const SizedBox(height: 12),
//             _buildInputRow("Phone Number", _phoneController,
//                 keyboardType: TextInputType.phone),
//             const SizedBox(height: 12),
//             _buildPasswordInput("Password", _passwordController, _isPasswordVisible,
//                     () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
//             const SizedBox(height: 12),
//             _buildPasswordInput(
//                 "Confirm Password",
//                 _confirmPasswordController,
//                 _isConfirmPasswordVisible,
//                     () => setState(() =>
//                 _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
//             const SizedBox(height: 12),
//             _buildInputRow("Referral Code (optional)", _referralCodeController),
//             const SizedBox(height: 12),
//             if (_otpSent)
//               _buildInputRow("Enter OTP", _otpController,
//                   keyboardType: TextInputType.number),
//             const SizedBox(height: 20),
//             _isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//               onPressed: _otpSent ? _verifyOTPAndRegister : _sendOTP,
//               child: Text(_otpSent ? "Verify & Register" : "Send OTP"),
//             ),
//             const SizedBox(height: 12),
//             Text(_statusMessage),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Already have an account? Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputRow(String label, TextEditingController controller,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }
//
//   Widget _buildPasswordInput(String label, TextEditingController controller,
//       bool isVisible, VoidCallback toggleVisibility) {
//     return TextField(
//       controller: controller,
//       obscureText: !isVisible,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//         suffixIcon: IconButton(
//           icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
//           onPressed: toggleVisibility,
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _otpSent = false;
  bool _isLoading = false;
  String _verificationId = '';
  String _statusMessage = '';
  String _enteredOtp = '';

  // === Validators ===
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~]').hasMatch(password);
  }

  Future<void> _sendOTP() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("Please fill all required fields");
      return;
    }

    if (!isValidPhone(phone)) {
      _showMessage("Enter a valid 10-digit mobile number");
      return;
    }

    if (email.isNotEmpty && !isValidEmail(email)) {
      _showMessage("Enter a valid email address");
      return;
    }

    if (!isStrongPassword(password)) {
      _showMessage("Password must be 8+ chars with upper, lower, digit & special char");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking user...';
    });

    try {
      final phoneExists = await _firestore
          .collection("Users")
          .where("usr_mob_no", isEqualTo: int.tryParse(phone))
          .limit(1)
          .get();

      if (phoneExists.docs.isNotEmpty) {
        _showMessage("Phone number already registered");
        setState(() => _isLoading = false);
        return;
      }

      if (email.isNotEmpty) {
        final emailExists = await _firestore
            .collection("Users")
            .where("usr_email_id", isEqualTo: email)
            .limit(1)
            .get();

        if (emailExists.docs.isNotEmpty) {
          _showMessage("Email already registered");
          setState(() => _isLoading = false);
          return;
        }
      }

      _statusMessage = 'Sending OTP...';
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _registerUser();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMessage("OTP failed: ${e.message}");
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
            _statusMessage = "OTP sent to +91$phone";
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showMessage("Error sending OTP: $e");
      setState(() => _isLoading = false);
    }
  }

  void _verifyOTPAndRegister() async {
    if (_verificationId.isEmpty || _enteredOtp.isEmpty) {
      _showMessage("Please enter the OTP");
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _enteredOtp,
      );
      await _auth.signInWithCredential(credential);
      _registerUser();
    } catch (e) {
      _showMessage("Invalid OTP. Try again.");
    }
  }

  Future<void> _registerUser() async {
    final name = "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        _showMessage("Account creation failed");
        return;
      }

      await _firestore.collection("Users").doc(uid).set({
        "usr_name": name,
        "usr_email_id": email,
        "usr_mob_no": int.parse(phone),
        "usr_status": "Active",
        "usr_created_by": "System",
        "usr_created_on": FieldValue.serverTimestamp(),
        "usr_updated_by": "System",
        "usr_updated_on": FieldValue.serverTimestamp(),
        "usr_reg_dt": FieldValue.serverTimestamp(),
      });

      _showMessage("Registered successfully!", isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      _showMessage("Registration error: ${e.toString()}");
    }
  }

  void _showMessage(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  // === UI ===
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A237E); // Indigo
    const accentColor = Color(0xFF64B5F6);  // Blue
    const textColor = Colors.black87;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputRow("First Name", _firstNameController),
            const SizedBox(height: 12),
            _buildInputRow("Last Name", _lastNameController),
            const SizedBox(height: 12),
            _buildInputRow("Email Address", _emailController),
            const SizedBox(height: 12),
            _buildInputRow("Phone Number", _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildPasswordInput("Password", _passwordController, _isPasswordVisible,
                    () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
            const SizedBox(height: 4),
            Text(
              isStrongPassword(_passwordController.text)
                  ? "Strong Password"
                  : "Password must have 8+ chars, upper, lower, digit, special char",
              style: TextStyle(
                fontSize: 12,
                color: isStrongPassword(_passwordController.text) ? Colors.green : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildPasswordInput("Confirm Password", _confirmPasswordController,
                _isConfirmPasswordVisible,
                    () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
            const SizedBox(height: 20),
            if (_otpSent)
              Column(
                children: [
                  const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: primaryColor,
                    focusedBorderColor: accentColor,
                    showFieldAsBox: true,
                    onCodeChanged: (String code) {},
                    onSubmit: (String code) {
                      _enteredOtp = code;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _otpSent ? _verifyOTPAndRegister : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_otpSent ? "Verify & Register" : "Send OTP"),
              ),
            ),
            const SizedBox(height: 12),
            Text(_statusMessage),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black54),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}

