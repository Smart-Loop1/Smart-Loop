import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/extensions/app_extensions.dart';
import 'package:finalproject/extensions/location_icon_extensions.dart';
import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:finalproject/screens/loop_dashboard_screen.dart';
import 'package:finalproject/screens/notifications_screen.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:finalproject/widgets/loop_offer_banner.dart';
import 'package:finalproject/widgets/water_drop_mark.dart';
import 'package:flutter/material.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  AppDataController get _appData => AppDataScope.read(context);
  List<DeviceLocation> get _locations => _appData.locations;

  @override
  Widget build(BuildContext context) {
    final appData = AppDataScope.of(context);
    final locations = appData.locations;
    final ungroupedDevices = appData.ungroupedDevices;
    final isEmpty = locations.isEmpty && ungroupedDevices.isEmpty;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'My Water Devices',
        leading: IconButton(
          tooltip: 'Back to welcome',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                context.pushScreen<void>(const NotificationsScreen()),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const LoopOfferBanner(),
          const SizedBox(height: 26),
          if (isEmpty)
            const _EmptyDevicesView()
          else ...[
            if (ungroupedDevices.isNotEmpty) ...[
              const _SectionTitle(title: 'Devices'),
              const SizedBox(height: 10),
              ...ungroupedDevices.map(
                (device) => _DeviceCard(
                  device: device,
                  onTap: () => _openDashboard(device),
                  onRename: () => _renameDevice(device),
                  onDelete: () => _deleteDevice(device),
                ),
              ),
            ],
            if (locations.isNotEmpty) ...[
              if (ungroupedDevices.isNotEmpty) const SizedBox(height: 20),
              const _SectionTitle(title: 'Locations'),
              const SizedBox(height: 10),
              ...locations.map(
                (location) => _LocationCard(
                  location: location,
                  onOpenDevice: _openDashboard,
                  onAddDevice: () => _addDevice(initialLocationId: location.id),
                  onRename: () => _editLocation(location),
                  onDelete: () => _deleteLocation(location),
                  onRenameDevice: _renameDevice,
                  onDeleteDevice: _deleteDevice,
                ),
              ),
            ],
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        tooltip: 'Add device or location',
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  void _openDashboard(WaterLoop device) {
    context.pushScreen<void>(LoopDashboardScreen(loop: device));
  }

  Future<void> _showAddMenu() async {
    final selection = await showModalBottomSheet<_AddItemType>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const _AddOptionIcon(icon: Icons.sensors_rounded),
                  title: const Text(
                    'Add Device',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Add a water device to your home',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext, _AddItemType.device);
                  },
                ),
                ListTile(
                  leading: const _AddOptionIcon(
                    icon: Icons.add_location_alt_rounded,
                  ),
                  title: const Text(
                    'Add Location',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Group devices by floor or area',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext, _AddItemType.location);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selection == null) return;

    switch (selection) {
      case _AddItemType.device:
        await _addDevice();
      case _AddItemType.location:
        await _addLocation();
    }
  }

  Future<void> _addLocation() async {
    final input = await _showLocationDialog();
    if (!mounted || input == null) return;

    _appData.addLocation(
      DeviceLocation(
        id: _createId(),
        name: input.name,
        iconType: input.iconType,
      ),
    );
  }

  Future<void> _addDevice({String? initialLocationId}) async {
    final input = await _showDeviceDialog(initialLocationId: initialLocationId);
    if (!mounted || input == null) return;

    final device = WaterLoop(id: _createId(), name: input.name);

    _appData.addDevice(device, locationId: input.locationId);
  }

  Future<void> _editLocation(DeviceLocation location) async {
    final input = await _showLocationDialog(location: location);
    if (!mounted || input == null) return;

    _appData.updateLocation(
      id: location.id,
      name: input.name,
      iconType: input.iconType,
    );
  }

  Future<void> _deleteLocation(DeviceLocation location) async {
    final confirmed = await _confirmDelete(
      title: 'Delete Location?',
      message: location.devices.isEmpty
          ? 'The location "${location.name}" will be deleted.'
          : 'The location "${location.name}" will be deleted. Its devices will be moved to the main Devices list.',
    );

    if (!mounted || !confirmed) return;

    _appData.deleteLocation(location.id);
  }

  Future<void> _renameDevice(WaterLoop device) async {
    final newName = await _showNameDialog(
      title: 'Rename Device',
      label: 'Device name',
      hint: 'Enter a device name',
      initialValue: device.name,
      actionLabel: 'Save',
    );

    if (!mounted || newName == null || newName == device.name) return;

    _appData.renameDevice(device.id, newName);
  }

  Future<void> _deleteDevice(WaterLoop device) async {
    final confirmed = await _confirmDelete(
      title: 'Delete Device?',
      message: 'The device "${device.name}" will be removed.',
    );

    if (!mounted || !confirmed) return;

    _appData.deleteDevice(device.id);
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<_LocationInput?> _showLocationDialog({
    DeviceLocation? location,
  }) async {
    var locationName = location?.name ?? '';
    var selectedIcon = location?.iconType ?? LocationIconType.water;
    var showError = false;

    final result = await showDialog<_LocationInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                location == null ? 'Add Location' : 'Edit Location',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: locationName,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      textCapitalization: TextCapitalization.words,
                      decoration: _dialogInputDecoration(
                        label: 'Location name',
                        hint: 'Example: First Floor',
                        showError: showError,
                      ),
                      onChanged: (value) => locationName = value,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Choose an icon',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: LocationIconType.values.map((iconType) {
                        final isSelected = selectedIcon == iconType;

                        return ChoiceChip(
                          selected: isSelected,
                          backgroundColor: AppColors.white,
                          checkmarkColor: AppColors.primaryAccent,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.primaryAccent.withValues(
                                    alpha: 0.28,
                                  ),
                          ),
                          avatar: iconType.iconWidget(
                            size: 18,
                            color: isSelected ? AppColors.primaryAccent : null,
                          ),
                          label: Text(
                            iconType.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          selectedColor: AppColors.primaryAccent.withValues(
                            alpha: 0.16,
                          ),
                          onSelected: (_) {
                            setDialogState(() => selectedIcon = iconType);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = locationName.trim();
                    if (name.isEmpty) {
                      setDialogState(() => showError = true);
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _LocationInput(name: name, iconType: selectedIcon),
                    );
                  },
                  child: Text(location == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<String?> _showNameDialog({
    required String title,
    required String label,
    required String hint,
    String? initialValue,
    String actionLabel = 'Add',
  }) async {
    var name = initialValue ?? '';
    var showError = false;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              content: TextFormField(
                initialValue: name,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                textCapitalization: TextCapitalization.words,
                decoration: _dialogInputDecoration(
                  label: label,
                  hint: hint,
                  showError: showError,
                ),
                onChanged: (value) => name = value,
                onFieldSubmitted: (value) => _submitName(
                  dialogContext,
                  value,
                  () => setDialogState(() => showError = true),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => _submitName(
                    dialogContext,
                    name,
                    () => setDialogState(() => showError = true),
                  ),
                  child: Text(actionLabel),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  void _submitName(
    BuildContext dialogContext,
    String value,
    VoidCallback showError,
  ) {
    final name = value.trim();
    if (name.isEmpty) {
      showError();
      return;
    }

    Navigator.pop(dialogContext, name);
  }

  Future<_DeviceInput?> _showDeviceDialog({String? initialLocationId}) async {
    var deviceName = '';
    var selectedLocationId = initialLocationId;
    var showError = false;

    final result = await showDialog<_DeviceInput>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Add Device',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: deviceName,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    textCapitalization: TextCapitalization.words,
                    decoration: _dialogInputDecoration(
                      label: 'Device name',
                      hint: 'Example: Kitchen Sensor',
                      showError: showError,
                    ),
                    onChanged: (value) => deviceName = value,
                  ),
                  if (_locations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedLocationId,
                      dropdownColor: AppColors.white,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _dialogInputDecoration(label: 'Location'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'No location',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        ..._locations.map(
                          (location) => DropdownMenuItem<String?>(
                            value: location.id,
                            child: Text(
                              location.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedLocationId = value);
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = deviceName.trim();
                    if (name.isEmpty) {
                      setDialogState(() => showError = true);
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _DeviceInput(name: name, locationId: selectedLocationId),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  InputDecoration _dialogInputDecoration({
    required String label,
    String? hint,
    bool showError = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: showError ? 'Please enter a name' : null,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryAccent),
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.primaryAccent.withValues(alpha: 0.28),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryAccent, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  String _createId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class _EmptyDevicesView extends StatelessWidget {
  const _EmptyDevicesView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 102,
            height: 102,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const WaterDropMark(size: 44),
          ),
          const SizedBox(height: 22),
          Text(
            'No devices yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the + button to add a device or create a location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onOpenDevice,
    required this.onAddDevice,
    required this.onRename,
    required this.onDelete,
    required this.onRenameDevice,
    required this.onDeleteDevice,
  });

  final DeviceLocation location;
  final ValueChanged<WaterLoop> onOpenDevice;
  final VoidCallback onAddDevice;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final ValueChanged<WaterLoop> onRenameDevice;
  final ValueChanged<WaterLoop> onDeleteDevice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deviceCount = location.devices.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.primaryAccent.withValues(alpha: 0.14),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: location.iconType.iconWidget(color: AppColors.primaryAccent),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  location.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _EditMenuButton(
                tooltip: 'Edit location',
                onRename: onRename,
                onDelete: onDelete,
              ),
            ],
          ),
          subtitle: Text(
            '$deviceCount ${deviceCount == 1 ? 'device' : 'devices'}',
          ),
          children: [
            const Divider(height: 1),
            if (location.devices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'No devices in this location yet.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              ...location.devices.map(
                (device) => _DeviceTile(
                  device: device,
                  onTap: () => onOpenDevice(device),
                  onRename: () => onRenameDevice(device),
                  onDelete: () => onDeleteDevice(device),
                ),
              ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryAccent,
              ),
              title: const Text(
                'Add device to this location',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: onAddDevice,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final WaterLoop device;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.primaryAccent.withValues(alpha: 0.14),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _DeviceTile(
          device: device,
          onTap: onTap,
          onRename: onRename,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final WaterLoop device;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.sensors_rounded,
          color: AppColors.primaryAccent,
        ),
      ),
      title: Text(
        device.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Waiting for cloud connection',
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _EditMenuButton(
            tooltip: 'Edit device',
            onRename: onRename,
            onDelete: onDelete,
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EditMenuButton extends StatelessWidget {
  const _EditMenuButton({
    required this.tooltip,
    required this.onRename,
    required this.onDelete,
  });

  final String tooltip;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_EditAction>(
      tooltip: tooltip,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) {
        switch (action) {
          case _EditAction.rename:
            onRename();
          case _EditAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _EditAction.rename,
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 12),
              Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _EditAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              const SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddOptionIcon extends StatelessWidget {
  const _AddOptionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primaryAccent),
    );
  }
}

enum _AddItemType { device, location }

enum _EditAction { rename, delete }

class _LocationInput {
  const _LocationInput({required this.name, required this.iconType});

  final String name;
  final LocationIconType iconType;
}

class _DeviceInput {
  const _DeviceInput({required this.name, this.locationId});

  final String name;
  final String? locationId;
}
