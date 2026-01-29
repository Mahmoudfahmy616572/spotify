abstract class Usecase<type, Param> {
  Future<type> call({Param? param});
}
