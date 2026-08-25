import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../countries/models/country.dart';
import '../../models/user_profile.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late Future<List<Country>> _countriesFuture;
  String? _selectedCountryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _selectedCountryId = widget.profile.countryId;
    _countriesFuture = AppServices.countryService.getAll();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AppServices.profileService.updateMyProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        countryId: _selectedCountryId,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage('Profile update failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Profile update failed: $exception');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }



  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Edit profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayNameController,
              enabled: !_isSaving,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (text.isEmpty) {
                  return 'Display name is required.';
                }

                if (text.length > 100) {
                  return 'Display name must not be longer than 100 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Country>>(
              future: _countriesFuture,
              builder: (context, snapshot) {
                final countries =
                    snapshot.data ?? const <Country>[];

                final selectedCountryId = countries.any(
                  (country) => country.id == _selectedCountryId,
                )
                    ? _selectedCountryId
                    : null;

                return DropdownButtonFormField<String?>(
                  initialValue: selectedCountryId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No country selected'),
                    ),
                    for (final country in countries)
                      DropdownMenuItem<String?>(
                        value: country.id,
                        child: Text(
                          country.code.isEmpty
                              ? country.name
                              : '${country.name} (${country.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged:
                      _isSaving ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCountryId = value;
                              });
                            },
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              enabled: !_isSaving,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Bio'),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (text.length > 500) {
                  return 'Bio must not be longer than 500 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}