import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/services_api_service.dart';
import 'package:frontend_seminario/services/api/notifications_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class UserServicesPage extends StatefulWidget {
  const UserServicesPage({Key? key}) : super(key: key);

  @override
  State<UserServicesPage> createState() => _UserServicesPageState();
}

class _UserServicesPageState extends State<UserServicesPage> {
  final StorageService storageService = StorageService();

  List<dynamic> services = [];
  List<dynamic> consortiums = [];
  int? selectedConsortiumId;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchConsortiums();
  }

  Future<void> _fetchUserData() async {
    final user = await storageService.getUserData();
    if (user != null) {
      setState(() {
        currentUserId = user['ID'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener el usuario actual')),
      );
    }
  }

  Future<void> _fetchConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        consortiums = jsonDecode(response.body);
        if (consortiums.isNotEmpty) {
          selectedConsortiumId = consortiums[0]['ID'];
          _fetchServicesByConsortium(selectedConsortiumId!);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener consorcios')),
      );
    }
  }

  Future<void> _fetchServicesByConsortium(int consortiumId) async {
    final response = await ServicesApiService.getServicesByConsortium(consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        services = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener servicios por consorcio')),
      );
    }
  }

  void _openAddServiceModal() {
    String? name;
    String? description;
    String? expirationDate;
    String status = 'active';
    int? consortiumId = selectedConsortiumId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Servicio', style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Expiración (YYYY-MM-DD)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Dejar en blanco si no aplica',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    expirationDate = value;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  style: AppTheme.bodyMedium,
                  items: ['active', 'inactive'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'active' ? 'Activa' : 'Inactiva',
                        style: AppTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name == null ||
                    name!.isEmpty ||
                    description == null ||
                    description!.isEmpty ||
                    consortiumId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }
                Map<String, dynamic> serviceData = {
                  'name': name,
                  'description': description,
                  'consortium_id': consortiumId,
                  'expiration_date': expirationDate != null && expirationDate!.isNotEmpty
                      ? expirationDate
                      : ' ',
                  'status': status,
                };
                final response = await ServicesApiService.createService(serviceData);
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Servicio creado con éxito')),
                  );
                  _fetchServicesByConsortium(consortiumId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear el servicio')),
                  );
                }
              },
              child: const Text('Agregar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  void _deleteService(int serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación', style: AppTheme.titleMedium),
          content: const Text(
            '¿Está seguro de que desea eliminar este servicio?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final response = await ServicesApiService.deleteService(serviceId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio eliminado con éxito')),
        );
        _fetchServicesByConsortium(selectedConsortiumId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el servicio')),
        );
      }
    }
  }

  void _editService(Map<String, dynamic> service) {
    String? name = service['name'];
    String? description = service['description'];
    String? expirationDate = service['expiration_date'];
    String status = service['status'];
    int? consortiumId = service['consortium_id'];
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController descriptionController = TextEditingController(text: description);
    TextEditingController expirationDateController = TextEditingController(text: expirationDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Servicio', style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: expirationDateController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Expiración (YYYY-MM-DD)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Dejar en blanco si no aplica',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    expirationDate = value;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  style: AppTheme.bodyMedium,
                  items: ['active', 'inactive'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'active' ? 'Activa' : 'Inactiva',
                        style: AppTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name == null ||
                    name!.isEmpty ||
                    description == null ||
                    description!.isEmpty ||
                    consortiumId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }
                Map<String, dynamic> serviceData = {
                  'name': name,
                  'description': description,
                  'expiration_date': expirationDate != null && expirationDate!.isNotEmpty
                      ? expirationDate
                      : ' ',
                  'status': status,
                  'consortium_id': consortiumId,
                };
                final response = await ServicesApiService.updateService(service['ID'], serviceData);
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Servicio actualizado con éxito')),
                  );
                  _fetchServicesByConsortium(selectedConsortiumId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al actualizar el servicio')),
                  );
                }
              },
              child: const Text('Guardar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  void _sendNotification(Map<String, dynamic> service) {
    // Get the service name and consortium ID
    String serviceName = service['name'] ?? 'Servicio';
    int? consortiumId = service['consortium_id'];

    // Set the default title
    String defaultTitle = 'Notificación sobre $serviceName';

    // TextEditingController for the message
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(defaultTitle, style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: messageController,
                  style: AppTheme.bodyMedium,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                String message = messageController.text.trim();

                if (message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, ingrese un mensaje')),
                  );
                  return;
                }

                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al obtener el usuario actual')),
                  );
                  return;
                }

                // Construct the notification data
                Map<String, dynamic> notificationData = {
                  'title': defaultTitle,
                  'message': message,
                  'sender_user_id': currentUserId,
                  'target_consortium_id': consortiumId,
                  'target_role': 'admin',
                  'target_unit_id': null,
                  'target_user_id': null,
                };

                final response = await NotificationsApiService.createNotification(notificationData);
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificación enviada con éxito')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al enviar la notificación')),
                  );
                }
              },
              child: const Text('Enviar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  void _filterServicesByConsortium(int consortiumId) {
    setState(() {
      selectedConsortiumId = consortiumId;
      _fetchServicesByConsortium(consortiumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Servicios',
      isAdmin: false,
      storageService: storageService,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedConsortiumId,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Consorcio',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: AppTheme.bodyMedium,
              items: consortiums.map<DropdownMenuItem<int>>((consortium) {
                return DropdownMenuItem<int>(
                  value: consortium['ID'],
                  child: Text(
                    consortium['name'] ?? 'Sin Nombre',
                    style: AppTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                _filterServicesByConsortium(newValue!);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: services.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay servicios disponibles',
                        style: AppTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        String expirationDate = service['expiration_date'] ?? '';
                        if (expirationDate.isNotEmpty) {
                          try {
                            DateTime date = DateTime.parse(expirationDate);
                            expirationDate = DateFormat('dd/MM/yyyy').format(date);
                          } catch (e) {
                            expirationDate = 'No programado';
                          }
                        } else {
                          expirationDate = 'No programado';
                        }
                        String statusDisplay = '';
                        if (service['status'] == 'activa' ||
                            service['status'] == 'active') {
                          statusDisplay = 'Funcional';
                        } else if (service['status'] == 'inactiva' ||
                            service['status'] == 'inactive') {
                          statusDisplay = 'No Funcionando';
                        } else {
                          statusDisplay = service['status'] ?? '';
                        }

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'] ?? 'Sin Nombre',
                                  style: AppTheme.titleSmall.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Descripción: ${service['description'] ?? ''}',
                                  style: AppTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fecha de próximo mantenimiento: $expirationDate',
                                  style: AppTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estado: $statusDisplay',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: statusDisplay == 'Funcional'
                                        ? AppTheme.successColor
                                        : AppTheme.dangerColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: constraints.maxWidth < 400
                                              ? double.infinity
                                              : (constraints.maxWidth - 16) / 3,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _sendNotification(service);
                                            },
                                            icon: const Icon(Icons.notifications),
                                            label: const Text('Notificar',
                                                style: AppTheme.textSmall),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.alertColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
