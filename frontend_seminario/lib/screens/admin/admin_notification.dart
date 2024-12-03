import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/notifications_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  final StorageService _storageService = StorageService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showUnread = true; 

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _storageService.getUserData();
      if (user != null) {
        final userNotificationsResponse =
            await NotificationsApiService.getNotificationsByUser(user['ID']);
        final roleNotificationsResponse =
            await NotificationsApiService.getNotificationsByRole('admin');

        if (userNotificationsResponse.statusCode == 200 &&
            roleNotificationsResponse.statusCode == 200) {
          final userNotifications = List<Map<String, dynamic>>.from(
              jsonDecode(userNotificationsResponse.body));
          final roleNotifications = List<Map<String, dynamic>>.from(
              jsonDecode(roleNotificationsResponse.body));

          final Map<int, Map<String, dynamic>> notificationsMap = {};
          for (var notification in userNotifications) {
            if (notification['ID'] != null) {
              notificationsMap[notification['ID']] = notification;
            }
          }
          for (var notification in roleNotifications) {
            if (notification['ID'] != null) {
              notificationsMap[notification['ID']] = notification;
            }
          }

          final deduplicatedNotifications = notificationsMap.values.toList();

          if (mounted) {
            setState(() {
              _notifications = deduplicatedNotifications;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al cargar las notificaciones'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    }
  }

  Future<void> _createNotification(
      Map<String, dynamic> notificationData) async {
    final response =
        await NotificationsApiService.createNotification(notificationData);
    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación creada con éxito')),
        );
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la notificación')),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    final response =
        await NotificationsApiService.deleteNotification(notificationId);
    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación eliminada con éxito')),
        );
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la notificación')),
        );
      }
    }
  }

  Future<void> _markNotificationAsRead(int notificationId) async {
    final response =
        await NotificationsApiService.markNotificationAsRead(notificationId);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación marcada como leída')),
      );
      _loadNotifications();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al marcar la notificación')),
      );
    }
  }

  List<dynamic> get _filteredNotifications => _notifications
      .where((notification) =>
          notification['is_read'] == !_showUnread)
      .toList();

void _showCreateNotificationModal() {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  int? selectedConsortiumId;
  int? selectedUnitId;
  int? targetUserId;
  String? targetUserRole;

  List<dynamic> consortiums = [];
  List<dynamic> units = [];
  List<dynamic> users = [];
  List<String> roles = ['admin', 'user'];

  void loadConsortiums(StateSetter setModalState) async {
    try {
      final response = await ConsortiumApiService.getAllConsortiums();
      if (response.statusCode == 200) {
        final fetchedConsortiums = jsonDecode(response.body);
        setModalState(() {
          consortiums = fetchedConsortiums;
        });
      }
    } catch (e) {
      setModalState(() {
        consortiums = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consortiums: $e')),
        );
      }
    }
  }

  void loadUnitsByConsortium(
      int consortiumId, StateSetter setModalState) async {
    try {
      final response =
          await UnitApiService.getUnitsByConsortium(consortiumId);
      if (response.statusCode == 200) {
        final fetchedUnits = jsonDecode(response.body);
        setModalState(() {
          units = fetchedUnits;
        });
      }
    } catch (e) {
      setModalState(() {
        units = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading units: $e')),
        );
      }
    }
  }

  void loadUsers(StateSetter setModalState) async {
    try {
      final response = await UserApiService.getActiveUsers();
      if (response.statusCode == 200) {
        final fetchedUsers = jsonDecode(response.body);
        setModalState(() {
          users = fetchedUsers;
        });
      }
    } catch (e) {
      setModalState(() {
        users = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          if (consortiums.isEmpty) {
            loadConsortiums(setModalState);
          }
          if (users.isEmpty) {
            loadUsers(setModalState);
          }
          return AlertDialog(
            backgroundColor: AppTheme.lightBackground,
            title: Text(
              'Crear Notificación',
              style:
                  AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: AppTheme.textMedium,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: messageController,
                      style: AppTheme.textMedium,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un mensaje';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione un Consorcio (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: selectedConsortiumId,
                      items: consortiums
                          .map<DropdownMenuItem<int>>((consortium) {
                        return DropdownMenuItem<int>(
                          value: consortium['ID'],
                          child: Text(consortium['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedConsortiumId = value;
                          selectedUnitId = null;
                          if (value != null) {
                            loadUnitsByConsortium(value, setModalState);
                          } else {
                            units = [];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione una Propiedad',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: selectedUnitId,
                      items: units.map<DropdownMenuItem<int>>((unit) {
                        return DropdownMenuItem<int>(
                          value: unit['ID'],
                          child: Text(unit['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedUnitId = value;
                          selectedConsortiumId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione un Usuario (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: targetUserId,
                      items: users.map<DropdownMenuItem<int>>((user) {
                        return DropdownMenuItem<int>(
                          value: user['ID'],
                          child: Text('${user['name']} ${user['surname']}',
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          targetUserId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Usuario (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: targetUserRole,
                      items: roles.map<DropdownMenuItem<String>>((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role, style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          targetUserRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Cancelar',
                  style: AppTheme.textSmall
                      .copyWith(color: AppTheme.dangerColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = await _storageService.getUserData();

                    if (user != null) {
                      final notificationData = {
                        'title': titleController.text,
                        'message': messageController.text,
                        'sender_user_id': user['ID'],
                        'target_consortium_id': selectedConsortiumId,
                        'target_unit_id': selectedUnitId,
                        'target_user_id': targetUserId,
                        'target_role': targetUserRole,
                      };
                      await _createNotification(notificationData);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } else {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Error al obtener el usuario actual'),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  'Crear',
                  style: AppTheme.textSmall
                      .copyWith(color: AppTheme.successColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Notificaciones Administrativas',
      isAdmin: true,
      storageService: _storageService,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateNotificationModal,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Notificación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showUnread
                            ? 'Notificaciones No Leídas'
                            : 'Notificaciones Leídas',
                        style: AppTheme.titleMedium
                            .copyWith(color: AppTheme.primaryColor),
                      ),
                      Switch(
                        value: _showUnread,
                        onChanged: (value) {
                          setState(() {
                            _showUnread = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredNotifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay notificaciones disponibles',
                              style: AppTheme.textMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification =
                                  _filteredNotifications[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    notification['title'],
                                    style: AppTheme.textMedium,
                                  ),
                                  subtitle: Text(
                                    notification['message'],
                                    style: AppTheme.textSmall,
                                  ),
                                  trailing: _showUnread
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: AppTheme.successColor,
                                          ),
                                          onPressed: () {
                                            _markNotificationAsRead(
                                                notification['ID']);
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppTheme.dangerColor,
                                          ),
                                          onPressed: () async {
                                            final confirmDelete =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Eliminar Notificación'),
                                                content: const Text(
                                                    '¿Está seguro de que desea eliminar esta notificación?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child:
                                                        const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child:
                                                        const Text('Eliminar'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmDelete == true) {
                                              _deleteNotification(
                                                  notification['ID']);
                                            }
                                          },
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
