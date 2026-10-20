import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static const pessoasCollection = 'pessoas';
  static const avaliacoesCollection = 'avaliacoes';

  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> listar(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((document) => {...document.data(), 'id': document.id})
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> buscar(
      String collection, String documentId) async {
    final document =
        await _firestore.collection(collection).doc(documentId).get();
    final data = document.data();
    return data == null ? null : {...data, 'id': document.id};
  }

  Future<String> criar(String collection, Map<String, dynamic> data) async {
    final document = _firestore.collection(collection).doc();
    await document.set(data);
    return document.id;
  }

  Future<void> salvar(
      String collection, String documentId, Map<String, dynamic> data) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> atualizar(
      String collection, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> remover(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).delete();
  }

  Future<Map<String, dynamic>?> buscarAvaliacao(
      String avaliadorUid, String pessoaId) async {
    return buscar(avaliacoesCollection, '${avaliadorUid}_$pessoaId');
  }

  Future<String> salvarAvaliacao(
      String avaliadorUid, String pessoaId, Map<String, dynamic> data) async {
    final documentId = '${avaliadorUid}_$pessoaId';
    await salvar(avaliacoesCollection, documentId, data);
    return documentId;
  }
}
