import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_bloc.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_event.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_state.dart';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserInfoFormScreen extends StatefulWidget {
  const UserInfoFormScreen({super.key});

  @override
  State<UserInfoFormScreen> createState() => _UserInfoFormScreenState();
}

class _UserInfoFormScreenState extends State<UserInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  File? _avatarImage;
  String? _gender;
  DateTime? _dateOfBirth;
  bool _isLoading = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      context.read<ProfileBloc>().add(LoadProfile(userId: user.id));
    }
  }

  void _populateFormWithCurrentData(UserProfile profile) {
    setState(() {
      _fullNameController.text = profile.fullName ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
      _gender = profile.gender;
      _dateOfBirth = profile.dateOfBirth;
      _currentAvatarUrl = profile.avatarUrl;

      if (_dateOfBirth != null) {
        _dateOfBirthController.text =
            "${_dateOfBirth!.toLocal()}".split(' ')[0];
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        _showErrorSnackBar('Người dùng chưa đăng nhập');
        return;
      }

      final UserProfile updatedProfile = UserProfile(
        id: user.id,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        avatarUrl:
            _currentAvatarUrl, // Keep current URL, will be updated in bloc
      );

      context.read<ProfileBloc>().add(UpdateProfile(
            updatedProfile: updatedProfile,
            imageAvatar: _avatarImage,
          ));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // Populate form when profile is loaded
          _populateFormWithCurrentData(state.userProfile);
          setState(() {
            _isLoading = false;
          });
        } else if (state is ProfileUpdateSuccess) {
          setState(() {
            _isLoading = false;
          });
          _showSuccessSnackBar(state.message);
          Navigator.of(context).pop(); // Go back to profile screen
        } else if (state is ProfileError) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(state.message);
        } else if (state is ProfileUpdating || state is ProfileLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Thông tin cá nhân'),
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatarSection(theme),
                          const SizedBox(height: 30),
                          _buildFullNameField(),
                          const SizedBox(height: 18),
                          _buildPhoneField(),
                          const SizedBox(height: 18),
                          _buildGenderDropdown(),
                          const SizedBox(height: 18),
                          _buildDateOfBirthField(),
                          const SizedBox(height: 32),
                          _buildSaveButton(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.secondary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: _avatarImage != null
                    ? Image.file(_avatarImage!, fit: BoxFit.cover)
                    : _currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                        ? Image.network(
                            _currentAvatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person,
                                    size: 50, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person,
                                size: 50, color: Colors.grey),
                          ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Nhấn để thay đổi ảnh đại diện',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: 'Họ và Tên',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập họ và tên';
        }
        if (value.trim().length < 2) {
          return 'Họ tên phải có ít nhất 2 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Số điện thoại',
        prefixIcon: const Icon(Icons.phone),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
      ),
      keyboardType: TextInputType.phone,
      maxLength: 15,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        if (value.trim().length < 10) {
          return 'Số điện thoại phải có ít nhất 10 chữ số';
        }
        // Basic phone number validation
        if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim())) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        prefixIcon: const Icon(Icons.wc),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'male',
          child: Row(
            children: [
              Icon(Icons.male, color: Colors.blue[300]),
              const SizedBox(width: 8),
              const Text('Nam'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Row(
            children: [
              Icon(Icons.female, color: Colors.pink[300]),
              const SizedBox(width: 8),
              const Text('Nữ'),
            ],
          ),
        ),
        const DropdownMenuItem(
          value: 'other',
          child: Text('Khác'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      validator: (value) => value == null ? 'Vui lòng chọn giới tính' : null,
    );
  }

  Widget _buildDateOfBirthField() {
    return TextFormField(
      controller: _dateOfBirthController,
      decoration: InputDecoration(
        labelText: 'Ngày sinh',
        prefixIcon: const Icon(Icons.cake_outlined),
        suffixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      onTap: _pickDateOfBirth,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn ngày sinh';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          _isLoading ? 'Đang lưu...' : 'Lưu thông tin',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: _isLoading ? null : _submitForm,
      ),
    );
  }
}
