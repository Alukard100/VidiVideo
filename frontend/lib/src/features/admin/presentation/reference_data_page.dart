import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../../categories/models/category.dart';
import '../../countries/models/country.dart';
import 'admin_navigation.dart';
import 'widgets/admin_profile_menu.dart';

class ReferenceDataPage
    extends StatelessWidget {
  const ReferenceDataPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Reference Data',

      navigationItems:
          adminNavigationItems(
        AppRoutes.adminReferenceData,
      ),
      navigationFooter: const AdminProfileMenu(),

      body: const Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reference Data Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage countries and categories used throughout VidiVideo.',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              _CountriesSection(),
              SizedBox(height: 18),
              _CategoriesSection(),
            ],
          ),
        ),
      ) 
    );
  }
}

// =============================================================================
// Countries
// =============================================================================

class _CountriesSection
    extends StatefulWidget {
  const _CountriesSection();

  @override
  State<_CountriesSection> createState() =>
      _CountriesSectionState();
}

class _CountriesSectionState
    extends State<_CountriesSection> {
  static const int _pageSize = 10;

  final _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  late Future<PagedResult<Country>>
      _future;

  int _page = 1;
  String? _search;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResult<Country>> _load() {
    return AppServices.countryService
        .getPage(
      search: _search,
      page: _page,
      pageSize: _pageSize,
    );
  }

  void _refresh({
    bool firstPage = false,
  }) {
    setState(() {
      if (firstPage) {
        _page = 1;
      }

      _future = _load();
    });
  }

  void _onSearchChanged(
    String value,
  ) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _search =
              value.trim().isEmpty
                  ? null
                  : value.trim();

          _page = 1;
          _future = _load();
        });
      },
    );
  }

  Future<void> _create() async {
    final result =
        await showDialog<_CountryFormData>(
      context: context,
      builder: (_) =>
          const _CountryDialog(
        title: 'Add country',
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      await AppServices.countryService
          .create(
        name: result.name,
        code: result.code,
      );

      if (!mounted) {
        return;
      }

      _refresh(firstPage: true);
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not add country',
      );
    }
  }

  Future<void> _edit(
    Country country,
  ) async {
    final result =
        await showDialog<_CountryFormData>(
      context: context,
      builder: (_) => _CountryDialog(
        title: 'Edit country',
        initialName: country.name,
        initialCode: country.code,
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      await AppServices.countryService
          .update(
        id: country.id,
        name: result.name,
        code: result.code,
      );

      if (!mounted) {
        return;
      }

      _refresh();
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not update country',
      );
    }
  }

  Future<void> _delete(
    Country country,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
        title:
            const Text('Delete country?'),
        content: Text(
          'Delete ${country.name} (${country.code})?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(false),
            child:
                const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(true),
            child:
                const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      await AppServices.countryService
          .delete(country.id);

      if (!mounted) {
        return;
      }

      // Ako obrišemo jedini item
      // na zadnjoj stranici, vrati se
      // jednu stranicu nazad.
      final current =
          await AppServices.countryService
              .getPage(
        search: _search,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      if (current.items.isEmpty &&
          _page > 1) {
        _page--;
      }

      _refresh();
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not delete country',
      );
    }
  }

  void _showApiError(
    ApiException exception, {
    required String title,
  }) {
    AppServices.errorHandler
        .showApiException(
      exception,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(
          Icons.public_outlined,
        ),
        title: const Text(
          'Countries',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'Manage available countries.',
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            _searchController,
                        onChanged:
                            _onSearchChanged,
                        decoration:
                            const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          hintText:
                              'Search countries by name or code...',
                          border:
                              OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    FilledButton.icon(
                      onPressed: _create,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add country',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                FutureBuilder<
                    PagedResult<Country>>(
                  future: _future,
                  builder:
                      (context, snapshot) {
                    if (snapshot
                            .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Padding(
                        padding:
                            EdgeInsets.all(
                          32,
                        ),
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _InlineError(
                        message: snapshot
                            .error
                            .toString(),
                        onRetry: _refresh,
                      );
                    }

                    final result =
                        snapshot.data;

                    if (result == null ||
                        result.items
                            .isEmpty) {
                      return const Padding(
                        padding:
                            EdgeInsets.all(
                          28,
                        ),
                        child: Text(
                          'No countries found.',
                        ),
                      );
                    }

                    return Column(
                      children: [
                        _CountryTable(
                          countries:
                              result.items,
                          onEdit: _edit,
                          onDelete:
                              _delete,
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        _PaginationBar(
                          page:
                              result.page,
                          pageSize:
                              result.pageSize,
                          totalCount:
                              result
                                  .totalCount,
                          onPageChanged:
                              (page) {
                            setState(() {
                              _page =
                                  page;
                              _future =
                                  _load();
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryTable
    extends StatelessWidget {
  const _CountryTable({
    required this.countries,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Country> countries;

  final ValueChanged<Country> onEdit;
  final ValueChanged<Country> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const _TableHeader(
            columns: [
              Expanded(
                flex: 4,
                child: Text('Name'),
              ),
              Expanded(
                flex: 2,
                child: Text('Code'),
              ),
              SizedBox(
                width: 180,
                child: Text('Actions'),
              ),
            ],
          ),
          for (var index = 0;
              index < countries.length;
              index++) ...[
            if (index > 0)
              const Divider(height: 1),
            _countryRow(
              countries[index],
            ),
          ],
        ],
      ),
    );
  }

  Widget _countryRow(
    Country country,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              country.name,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              country.code,
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      onEdit(country),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                      const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () =>
                      onDelete(country),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                  label: const Text(
                    'Delete',
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

// =============================================================================
// Categories
// =============================================================================

class _CategoriesSection
    extends StatefulWidget {
  const _CategoriesSection();

  @override
  State<_CategoriesSection>
      createState() =>
          _CategoriesSectionState();
}

class _CategoriesSectionState
    extends State<_CategoriesSection> {
  static const int _pageSize = 10;

  final _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  late Future<PagedResult<Category>>
      _future;

  int _page = 1;
  String? _search;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResult<Category>> _load() {
    return AppServices.categoryService
        .getPage(
      search: _search,
      page: _page,
      pageSize: _pageSize,
    );
  }

  void _refresh({
    bool firstPage = false,
  }) {
    setState(() {
      if (firstPage) {
        _page = 1;
      }

      _future = _load();
    });
  }

  void _onSearchChanged(
    String value,
  ) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _search =
              value.trim().isEmpty
                  ? null
                  : value.trim();

          _page = 1;
          _future = _load();
        });
      },
    );
  }

  Future<void> _create() async {
    final name =
        await showDialog<String>(
      context: context,
      builder: (_) =>
          const _CategoryDialog(
        title: 'Add category',
      ),
    );

    if (name == null || !mounted) {
      return;
    }

    try {
      await AppServices.categoryService
          .create(
        name: name,
      );

      if (!mounted) {
        return;
      }

      _refresh(firstPage: true);
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not add category',
      );
    }
  }

  Future<void> _edit(
    Category category,
  ) async {
    final name =
        await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(
        title: 'Edit category',
        initialName: category.name,
      ),
    );

    if (name == null || !mounted) {
      return;
    }

    try {
      await AppServices.categoryService
          .update(
        id: category.id,
        name: name,
      );

      if (!mounted) {
        return;
      }

      _refresh();
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not update category',
      );
    }
  }

  Future<void> _delete(
    Category category,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
        title:
            const Text('Delete category?'),
        content: Text(
          'Delete ${category.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(false),
            child:
                const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop(true),
            child:
                const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      await AppServices.categoryService
          .delete(category.id);

      if (!mounted) {
        return;
      }

      final current =
          await AppServices.categoryService
              .getPage(
        search: _search,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      if (current.items.isEmpty &&
          _page > 1) {
        _page--;
      }

      _refresh();
    } on ApiException catch (exception) {
      _showApiError(
        exception,
        title:
            'Could not delete category',
      );
    }
  }

  void _showApiError(
    ApiException exception, {
    required String title,
  }) {
    AppServices.errorHandler
        .showApiException(
      exception,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(
          Icons.category_outlined,
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'Manage video categories.',
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            _searchController,
                        onChanged:
                            _onSearchChanged,
                        decoration:
                            const InputDecoration(
                          prefixIcon:
                              Icon(
                            Icons.search,
                          ),
                          hintText:
                              'Search categories...',
                          border:
                              OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    FilledButton.icon(
                      onPressed: _create,
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add category',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                FutureBuilder<
                    PagedResult<Category>>(
                  future: _future,
                  builder:
                      (context, snapshot) {
                    if (snapshot
                            .connectionState ==
                        ConnectionState
                            .waiting) {
                      return const Padding(
                        padding:
                            EdgeInsets.all(
                          32,
                        ),
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _InlineError(
                        message: snapshot
                            .error
                            .toString(),
                        onRetry: _refresh,
                      );
                    }

                    final result =
                        snapshot.data;

                    if (result == null ||
                        result.items
                            .isEmpty) {
                      return const Padding(
                        padding:
                            EdgeInsets.all(
                          28,
                        ),
                        child: Text(
                          'No categories found.',
                        ),
                      );
                    }

                    return Column(
                      children: [
                        _CategoryTable(
                          categories:
                              result.items,
                          onEdit: _edit,
                          onDelete:
                              _delete,
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        _PaginationBar(
                          page:
                              result.page,
                          pageSize:
                              result.pageSize,
                          totalCount:
                              result
                                  .totalCount,
                          onPageChanged:
                              (page) {
                            setState(() {
                              _page =
                                  page;
                              _future =
                                  _load();
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTable
    extends StatelessWidget {
  const _CategoryTable({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Category> categories;

  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const _TableHeader(
            columns: [
              Expanded(
                child: Text('Name'),
              ),
              SizedBox(
                width: 180,
                child: Text('Actions'),
              ),
            ],
          ),
          for (var index = 0;
              index < categories.length;
              index++) ...[
            if (index > 0)
              const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      categories[index]
                          .name,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              onEdit(
                            categories[
                                index],
                          ),
                          icon:
                              const Icon(
                            Icons
                                .edit_outlined,
                            size: 18,
                          ),
                          label:
                              const Text(
                            'Edit',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              onDelete(
                            categories[
                                index],
                          ),
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                            size: 18,
                          ),
                          label:
                              const Text(
                            'Delete',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Shared UI
// =============================================================================

class _PaginationBar
    extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int page;
  final int pageSize;
  final int totalCount;

  final ValueChanged<int>
      onPageChanged;

  @override
  Widget build(BuildContext context) {
    final totalPages =
        totalCount == 0
            ? 1
            : (totalCount / pageSize)
                .ceil();

    return Row(
      children: [
        Text(
          '$totalCount total',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed:
              page > 1
                  ? () =>
                      onPageChanged(
                        page - 1,
                      )
                  : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Text(
          'Page $page of $totalPages',
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed:
              page < totalPages
                  ? () =>
                      onPageChanged(
                        page + 1,
                      )
                  : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }
}

class _TableHeader
    extends StatelessWidget {
  const _TableHeader({
    required this.columns,
  });

  final List<Widget> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: columns,
      ),
    );
  }
}

class _InlineError
    extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign:
                TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Dialogs
// =============================================================================

class _CountryDialog
    extends StatefulWidget {
  const _CountryDialog({
    required this.title,
    this.initialName,
    this.initialCode,
  });

  final String title;
  final String? initialName;
  final String? initialCode;

  @override
  State<_CountryDialog>
      createState() =>
          _CountryDialogState();
}

class _CountryDialogState
    extends State<_CountryDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _codeController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.initialName ?? '',
    );

    _codeController =
        TextEditingController(
      text: widget.initialCode ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState
            ?.validate() !=
        true) {
      return;
    }

    Navigator.of(context).pop(
      _CountryFormData(
        name:
            _nameController.text
                .trim(),
        code:
            _codeController.text
                .trim()
                .toUpperCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                    _nameController,
                autofocus: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Country name',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim()
                          .isEmpty) {
                    return 'Country name is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 14,
              ),
              TextFormField(
                controller:
                    _codeController,
                maxLength: 4,
                textCapitalization:
                    TextCapitalization
                        .characters,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Country code',
                  hintText: 'BA',
                ),
                validator: (value) {
                  final code =
                      value?.trim() ?? '';

                  if (code.isEmpty) {
                    return 'Country code is required.';
                  }

                  if (code.length > 4) {
                    return 'Maximum 4 characters.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CountryFormData {
  const _CountryFormData({
    required this.name,
    required this.code,
  });

  final String name;
  final String code;
}

class _CategoryDialog
    extends StatefulWidget {
  const _CategoryDialog({
    required this.title,
    this.initialName,
  });

  final String title;
  final String? initialName;

  @override
  State<_CategoryDialog>
      createState() =>
          _CategoryDialogState();
}

class _CategoryDialogState
    extends State<_CategoryDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.initialName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState
            ?.validate() !=
        true) {
      return;
    }

    Navigator.of(context).pop(
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller:
                _nameController,
            autofocus: true,
            decoration:
                const InputDecoration(
              labelText:
                  'Category name',
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Category name is required.';
              }

              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}