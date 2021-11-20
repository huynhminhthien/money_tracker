import 'package:money_tracker/core/themes/colors_utility.dart';
import 'package:money_tracker/core/helpers/parse_data_helper.dart';
import 'package:money_tracker/data/models/item.dart';
import 'package:money_tracker/data/repositories/repository.dart';
import 'package:money_tracker/logic/cubit/catalog_cubit.dart';
import 'package:money_tracker/presentation/router/app_router.dart';
import 'package:money_tracker/presentation/widget/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatalogItem extends StatelessWidget {
  const CatalogItem({Key? key, required this.item, required this.type})
      : super(key: key);
  final Catalog item;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Wrap(
              children: [
                ListTile(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.editCatalog,
                      arguments: <String, String>{
                        'name': item.name,
                        'icon': item.icon,
                        'type': type.toShortString(),
                      },
                    );
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.edit),
                  title: Text('Edit ${item.name}'),
                ),
                ListTile(
                  onTap: () async {
                    await showWarningMessage(
                      context: context,
                      message:
                          "${item.name} category will be removed if you accept",
                      onAccept: () {
                        BlocProvider.of<CatalogCubit>(context)
                            .deleteCatalog(item);
                      },
                    );
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.delete),
                  title: Text('Delete ${item.name}'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 100,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(25, 0, 0, 0),
              blurRadius: 4.0,
              spreadRadius: 0.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadiantGradientMask(
              child: Icon(
                item.icon.toIconData(),
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              item.name,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      ),
    );
  }
}
