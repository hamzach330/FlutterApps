part of 'module.dart';

abstract class ChannelSelectorBaseState<T extends StatefulWidget> extends State<T> {


  @override
  initState() {
    super.initState();
  }
  
  void close(BuildContext context);

  void pop(BuildContext context);



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
