import 'dart:convert';
import 'package:eatch_cuisine/service/getCommande.dart';
import 'package:eatch_cuisine/service/multipart.dart';
import 'package:eatch_cuisine/service/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
//import 'package:http/http.dart' as http;

class CommandeCuisineS extends ConsumerStatefulWidget {
  const CommandeCuisineS({Key? key}) : super(key: key);

  @override
  CommandeCuisineState createState() => CommandeCuisineState();
}

class CommandeCuisineState extends ConsumerState<CommandeCuisineS> {
  MediaQueryData mediaQueryData(BuildContext context) {
    return MediaQuery.of(context);
  }

  Size size(BuildContext buildContext) {
    return mediaQueryData(buildContext).size;
  }

  double width(BuildContext buildContext) {
    return size(buildContext).width;
  }

  double height(BuildContext buildContext) {
    return size(buildContext).height;
  }

  bool traitement = false;
  bool waited = false;
  bool filtre = false;
  List<CommandeCuisine> listCommande = [];
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(getDataCommandeCuisineFuture);
    //if (filtre == false) {
    listCommande.addAll(viewModel.listCommandeTraitement);
    listCommande.addAll(viewModel.listCommandeWaited);

    //}

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return horizontalView(height(context), width(context), context);
          } else {
            return verticalView(height(context), width(context), context);
          }
        },
      ),
    );
  }

  Widget horizontalView(
    double height,
    double width,
    context,
  ) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Palette.yellowColor,
        height: height,
        width: width,
        child: Stack(
          children: [
            Container(
              height: height,
              width: width,
              child: listCommande.isEmpty
                  ? Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: listCommande.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          child: Container(
                            height: 200,
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 200,
                                  width: 50,
                                  color: Colors.black,
                                  child: Text(
                                    'N° ${index + 1}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${listCommande[index].products!.length} produits ',
                                        style: const TextStyle(
                                            fontFamily: 'Righteous',
                                            fontSize: 15,
                                            color: Palette.yellowColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Divider(
                                        color: Colors.black,
                                      ),
                                      Container(
                                        height: 150,
                                        child: ListView.builder(
                                            itemExtent: 70,
                                            itemCount: listCommande[index]
                                                .products!
                                                .length,
                                            itemBuilder: (context, indexx) {
                                              return Container(
                                                padding: EdgeInsets.only(
                                                    right: 10, left: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${indexx + 1} - ${listCommande[index].products![indexx].productName!}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    listCommande[index]
                                                                .products![
                                                                    indexx]
                                                                .recette!
                                                                .description !=
                                                            null
                                                        ? Text(listCommande[
                                                                index]
                                                            .products![indexx]
                                                            .recette!
                                                            .description!)
                                                        : Text('Rien')
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 400,
                                  child: Row(
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: Size(91, 100),
                                            backgroundColor: Colors.red),
                                        onPressed: () {},
                                        icon: Icon(Icons.close),
                                        label: Text('Annulez'),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      listCommande[index].status != 'TREATMENT'
                                          ? ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  minimumSize: Size(91, 100),
                                                  backgroundColor:
                                                      Colors.amber),
                                              onPressed: () {
                                                modificationCommande(
                                                    context,
                                                    'TREATMENT',
                                                    listCommande[index].sId!);
                                              },
                                              icon: Icon(Icons.watch),
                                              label: Text('Traitement'),
                                            )
                                          : Container(),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: Size(91, 100),
                                            backgroundColor: Colors.green),
                                        onPressed: () {
                                          modificationCommande(context, 'DONE',
                                              listCommande[index].sId!);
                                        },
                                        icon: Icon(Icons.done),
                                        label: Text('Terminer'),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      listCommande[index].status == 'TREATMENT'
                                          ? Container(
                                              alignment: Alignment.center,
                                              child:
                                                  const Text('En traitement'),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
            ),
            Positioned(
                right: 5,
                width: 75,
                height: 75,
                child: InkWell(
                  child: CircleAvatar(
                    child: IconButton(
                        tooltip: 'Refresh',
                        onPressed: () {
                          listCommande.clear();
                          print(
                              'refesh commande**************************************************************');
                          ref.refresh(getDataCommandeCuisineFuture);
                        },
                        icon: const Icon(
                          Icons.refresh,
                        )),
                  ),
                  onTap: () {
                    listCommande.clear();
                    print(
                        'refesh commande**************************************************************');
                    ref.refresh(getDataCommandeCuisineFuture);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget verticalView(double height, double width, context) {
    return Scaffold();
  }

  Future<void> modificationCommande(
    BuildContext context,
    String status,
    String idCommande,
  ) async {
    ////////////

    //String adressUrl = prefs.getString('ipport').toString();
    //print(idMenu);

    var url = Uri.parse(
        "http://13.39.81.126:4004/api/orders/update/$idCommande"); //$adressUrl
    final request = MultipartRequest(
      'PUT',
      url,
      // ignore: avoid_returning_null_for_void
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        print('progress: $progress ($bytes/$total)');
      },
    );
//'restaurant': restaurantId,
//'_creator': id,
    var json = {
      'status': status,
    };
    var body = jsonEncode(json);

    request.headers.addAll({
      "body": body,
    });

    request.fields['form_key'] = 'form_value';
    //request.headers['authorization'] = 'Bearer $token';

    print("RESPENSE SEND STEAM FILE REQ");
    //var responseString = await streamedResponse.stream.bytesToString();
    var response = await request.send();
    print("Upload Response$response");
    print(response.statusCode);
    print(request.headers);

    print("Je me situe maintenant ici");
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        await response.stream.bytesToString().then((value) {
          print(value);
        });
        listCommande.clear();
        ref.refresh(getDataCommandeCuisineFuture);

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.info(
            backgroundColor: Palette.greenColors,
            message: "La Commande est à un status : $status",
          ),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            backgroundColor: Palette.deleteColors,
            message: "Erreur status de commande ",
          ),
        );
        print("Error Create Programme  !!!");
      }
    } catch (e) {
      rethrow;
    }
  }
}
