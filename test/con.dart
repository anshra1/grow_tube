void main() {}

base class SomeFeatureBaseBloc {
  final int s;

  SomeFeatureBaseBloc(this.s);
  void dispose() {
    print('dispose SomeFeatureBaseBloc');
  }
}

base class SomeFeatureBlocMixin1 extends SomeFeatureBaseBloc {
  SomeFeatureBlocMixin1(super.s);
  @override
  void dispose() {
    print('dispose SomeFeatureBlocMixin1');
    super.dispose();
  }
}
