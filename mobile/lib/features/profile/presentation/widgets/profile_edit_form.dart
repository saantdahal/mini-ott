import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/responsive_query.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    super.key,
    required this.fullName,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.country,
    required this.onSave,
    required this.isLoading,
  });

  final String fullName;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? country;
  final Function(Map<String, dynamic>) onSave;
  final bool isLoading;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _countryController;
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  String? _selectedAvatarPath;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _phoneController = TextEditingController(text: widget.phone ?? '');
    _dateOfBirthController = TextEditingController(
      text: widget.dateOfBirth ?? '',
    );
    _countryController = TextEditingController(text: widget.country ?? '');

    _selectedGender = widget.gender?.toLowerCase();

    // Parse date of birth if provided
    if (widget.dateOfBirth != null && widget.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDateOfBirth = DateTime.parse(widget.dateOfBirth!);
        _dateOfBirthController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDateOfBirth!);
      } catch (_) {
        _dateOfBirthController.text = widget.dateOfBirth!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
            : null,
        'country': _countryController.text.trim(),
        'avatarPath': _selectedAvatarPath,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.paddingAllEdgeInsets,
            vertical: screen.spacing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: screen.isMobile ? 20.sp : 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screen.spacing * 1.5),

              // Avatar Upload Section
              _buildAvatarUploadSection(context, screen),
              SizedBox(height: screen.spacing * 2),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: screen.spacing),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: '+977-xxx-xxx-xxxx',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: screen.spacing),

              // Gender Selection
              _buildGenderSelector(context, screen),
              SizedBox(height: screen.spacing),

              // Date of Birth Picker
              _buildDateOfBirthPicker(context, screen),
              SizedBox(height: screen.spacing),

              _buildTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'Your country',
                prefixIcon: Icons.public,
              ),
              SizedBox(height: screen.spacing * 2),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSave,
                  child: widget.isLoading
                      ? SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text('Save Changes', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarUploadSection(BuildContext context, ScreenHelper screen) {
    final cs = Theme.of(context).colorScheme;
    final hasImage = _selectedAvatarPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Avatar',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: screen.isMobile ? 13.sp : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: widget.isLoading ? null : _pickAvatar,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: cs.outlineVariant, width: 1.5),
            ),
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.10),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.30),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.file(
                              File(_selectedAvatarPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.broken_image_rounded,
                                color: cs.error,
                                size: 28.sp,
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 38.sp,
                              color: cs.primary,
                            ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                          border: Border.all(
                            color: cs.surfaceContainer,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          hasImage
                              ? Icons.edit_rounded
                              : Icons.add_a_photo_rounded,
                          size: 14.sp,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasImage ? 'Avatar selected' : 'Add a profile photo',
                        style: TextStyle(
                          fontSize: screen.isMobile ? 14.sp : 15.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        hasImage
                            ? 'Tap to change'
                            : 'Tap to pick from your device',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (hasImage) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _selectedAvatarPath!.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasImage)
                  IconButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => setState(() => _selectedAvatarPath = null),
                    icon: Icon(
                      Icons.close_rounded,
                      color: cs.onSurfaceVariant,
                      size: 20.sp,
                    ),
                    tooltip: 'Remove',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(BuildContext context, ScreenHelper screen) {
    final genderOptions = ['male', 'female', 'other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: screen.isMobile ? 13.sp : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButton<String?>(
            value: _selectedGender,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Select Gender'),
              ),
              ...genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender[0].toUpperCase() + gender.substring(1)),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthPicker(BuildContext context, ScreenHelper screen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: screen.isMobile ? 13.sp : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectDateOfBirth(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: screen.isMobile ? 14.sp : 15.sp,
                      color: _selectedDateOfBirth != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final screen = ScreenHelper(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: screen.isMobile ? 13.sp : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: screen.isMobile ? 14.sp : 15.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAvatarPath = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
