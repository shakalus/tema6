// ignore_for_file: cast_nullable_to_non_nullable

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tema6/src/data/movie_api.dart';
import 'package:tema6/src/models/movie.dart';
import 'package:tema6/src/models/torrent.dart';

Future<void> main() async {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.lightBlue,
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        '/movieDetails': (BuildContext context) => const DetailsPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Movie> _movie = <Movie>[];
  final ScrollController _controller = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getMovies();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      _getMovies();
    }
  }

  Future<void> _getMovies() async {
    final Client client = Client();
    final MovieApi movieApi = MovieApi(client);
    final List<Movie> response = await movieApi.getMovies(1);

    setState(() {
      _movie.addAll(response);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(
            child: Text(
          'Movies',
          style: TextStyle(color: Colors.white),
        )),
        leading: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: _movie.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (_movie.length == index) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
          final Movie movie = _movie[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/movieDetails',
                arguments: movie,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.network(
                movie.mediumImage,
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${movie.title} (${movie.year})',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  movie.mediumImage,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: <Widget>[
                  Text(
                    ' rating: ${movie.rating.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    ' runtime: ${movie.runtime.toString()} minutes',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                movie.summary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
              child: Text(
            'Available in:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          )),
          for (final Torrent torrent in movie.torrents)
            ListTile(
              title: Column(
                children: <Widget>[
                  Text(
                    '${torrent.quality} ${torrent.type}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 50),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                    child: const Text(
                      'Download',
                      style: TextStyle(color: Colors.white),
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
