import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/factory_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateOwnerScreen extends StatefulWidget {
  const CreateOwnerScreen({super.key});

  @override
  State<CreateOwnerScreen> createState() => _CreateOwnerScreenState();
}

class _CreateOwnerScreenState extends State<CreateOwnerScreen> {
  static const Color primaryColor = Color(0xFFC4471C);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final FactoryRepository factoryRepository = FactoryRepository();

  final Set<String> selectedFactoryIds = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool passwordVisible = false;
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE OWNER ACCOUNT
  // ============================================================

  Future<void> createOwner() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedFactoryIds.isEmpty) {
      showMessage('Please select at least one factory');
      return;
    }

    setState(() => isSaving = true);

    User? newUser;

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final phone = phoneController.text.trim();
      final password = passwordController.text;

      // 1. Create Firebase Authentication account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      newUser = credential.user;

      if (newUser == null) {
        throw Exception('Unable to create owner account');
      }

      // 2. Update Firebase Auth display name
      await newUser.updateDisplayName(name);

      // 3. Save owner details in Firestore
      await _firestore.collection('users').doc(newUser.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'owner',
        'factoryIds': selectedFactoryIds.toList(),
        'mustChangePassword': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('Owner account created successfully');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'weak-password':
          message = 'Please use a stronger password';
          break;
        case 'operation-not-allowed':
          message = 'Email and password login is not enabled in Firebase';
          break;
        default:
          message = e.message ?? 'Failed to create account';
      }

      showMessage(message);
    } catch (e) {
      // If Firestore profile creation fails, remove the newly created
      // Authentication account to avoid leaving an incomplete account.
      if (newUser != null) {
        try {
          await newUser.delete();
        } catch (_) {
          // Account cleanup can fail if the authentication session changed.
        }
      }

      if (!mounted) return;

      showMessage('Failed to create owner: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFAF7F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE7DED9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF9),
      appBar: AppBar(
        title: const Text('Create Owner Account'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_add_alt_1, color: primaryColor, size: 35),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Factory Owner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create one account and assign multiple factories.',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // OWNER DETAILS
            const Text(
              'Owner Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: inputDecoration(
                label: 'Owner Name',
                icon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter owner name';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecoration(
                label: 'Email Address',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address';
                }

                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }

                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: inputDecoration(
                label: 'Mobile Number',
                icon: Icons.phone_android,
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                  return 'Enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: 5),

            TextFormField(
              controller: passwordController,
              obscureText: !passwordVisible,
              decoration: inputDecoration(
                label: 'Temporary Password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must contain at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 25),

            // FACTORY SELECTION
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Assign Factories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${selectedFactoryIds.length} selected',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Select all factories this owner is allowed to manage.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 12),

            StreamBuilder<List<FactoryModel>>(
              stream: factoryRepository.getFactories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(25),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Failed to load factories: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                final factories = snapshot.data ?? [];

                if (factories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text('No factories available.'),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: factories.map((factory) {
                      final isSelected = selectedFactoryIds.contains(
                        factory.id,
                      );

                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: primaryColor,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          factory.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(factory.location),
                        secondary: const Icon(
                          Icons.factory_outlined,
                          color: primaryColor,
                        ),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedFactoryIds.add(factory.id);
                            } else {
                              selectedFactoryIds.remove(factory.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // CREATE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : createOwner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_alt_1),
                          SizedBox(width: 10),
                          Text(
                            'CREATE OWNER ACCOUNT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
